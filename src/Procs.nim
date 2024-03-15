#[Some useful procs ]#

import Types
import std/streams
import std/endians
import std/strutils

### Color type constructors ###

proc newColor*(): Color =       
    #[Empty constructor, initialize all the variables to zero]#
    result.r = 0.0
    result.g = 0.0
    result.b = 0.0
    return result

proc newColor*(r,g,b : float32): Color =
    #[Constructor with elements, initialize the variables to given values]#
    result.r = r
    result.g = g
    result.b = b
    return result

### HdrImage type constructors ###

proc newHdrImage*(): HdrImage = 
    #[Empty constructor, initialize all the variables to zero]#
    new(result)
    result.height = 0
    result.width = 0
    result.pixels = newSeq[Color](0)
    return result

proc newHdrImage*(width,height : int): HdrImage = 
    #[Constructor with elements, initialize the variables to given values]#
    new(result)
    result.height = height
    result.width = width
    result.pixels = newSeq[Color](height*width)
    return result

### Color algebra ###

func `+`*(c1,c2: Color) : Color =
    #[Sum of two colors]#
    result.r = c1.r + c2.r
    result.g = c1.g + c2.g
    result.b = c1.b + c2.b
    return result

func `*`*(c1,c2: Color) : Color =
    #[Product of two colors]#
    result.r = c1.r * c2.r
    result.g = c1.g * c2.g
    result.b = c1.b * c2.b
    return result

func `*`*(a: float32, c : Color) : Color =
    #[Product of a scalar and a color]#
    result.r = a * c.r
    result.g = a * c.g
    result.b = a * c.b 
    return result

### HdrImage pixel access ###

proc valid_coordinates*(img: HdrImage, x,y: int) : bool = 
    #[Check if the given coordinates are inside the image]#
    return ( (x >= 0) and (x < img.width) ) and
           ( (y >= 0) and (y < img.height) ) 

proc pixel_offset*(img: HdrImage, x,y: int) : int = 
    #[Give the linear position of a pixel, given its x,y]#
    return y * img.width + x

proc getPixel*(img: HdrImage, x,y: int) : Color = 
    #[Get the color of the pixel at the coordinates x,y]#
    assert img.valid_coordinates(x,y)
    return img.pixels[img.pixel_offset(x,y)]

proc setPixel*(img: HdrImage, x,y: int, new_color : Color) : void =
    #[Set the color of the pixel at the coordinates x,y]#
    assert img.valid_coordinates(x,y)
    img.pixels[img.pixel_offset(x,y)] = new_color

### Print methods ###

proc print*(col: Color): void =
    echo "Color(r=", col.r, ", g=", col.g, ", b=", col.b, ")"

proc print*(img: HdrImage): void =
    echo "HdrImage(width=", img.width, ", height=", img.height, ")"

### Usefull for tests ###

proc is_close*(scal1, scal2: float32) : bool =
    return ( abs(scal1-scal2)<=1e-5 )

proc is_close*(col1, col2: Color) : bool =
    return ( is_close(col1.r, col2.r) ) and
            ( is_close(col1.g, col2.g) ) and
            ( is_close(col1.b, col2.b) )

### Write PFM file ###

proc write_float*( stream : Stream, num : float32, endianness : Endianness ) : void =
    #[write a float on a stream, with a specified endianness]#
    var tmp : int32 #int32 is to force to write the bytes on the stream
    if endianness == bigEndian :
        bigEndian32(addr tmp, addr num)     #functions to adjust the endianness
    elif endianness == littleEndian :
        littleEndian32(addr tmp, addr num)
    stream.write(tmp)

proc write_pfm*( img : HdrImage, stream : Stream, endianness = littleEndian ) : void =
    #[write the HdrImage on a file using the PFM format]#
    var 
        endianness_str : string
        header : string

    #set the endianness string 
    if endianness == littleEndian :
        endianness_str = "-1.0"
    elif endianness == bigEndian :
        endianness_str = "1.0"

    #a PFM file must have at the beginning the following lines:

    #PF
    #width height
    #endianness (positive value for bigEndian and nevative for littleEndian)

    header = "PF\n" & intToStr(img.width) & " " & intToStr(img.height) & "\n" & endianness_str & "\n"
    stream.write(header)

    #Writing the colors on the file, the PFM format is read from the bottom to the top and from the left to the right
    for y in countdown( img.height-1 , 0 ):
        for x in 0 ..< img.width: 
            var color = img.getPixel(x,y)
            write_float(stream, color.r, endianness)
            write_float(stream, color.g, endianness)
            write_float(stream, color.b, endianness)

### Read PFM files ###

proc read_float*(stream : Stream, endianness : Endianness) : float =
    #[to read a float32 from a stream of byte, given an endianness]#
    var 
        num : float32
        tmp : float32

    if endianness == littleEndian: 
        if stream.readData(addr(num),4) == 4:   
            return num
    if endianness == bigEndian:
        if stream.readData(addr(tmp),4) == 4:
            bigEndian32(addr(num),addr(tmp))    #use of bigEndian32 to revese the byte order and to obtain the right littleEndian order
            return num
    