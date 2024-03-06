#[Some useful procs ]#

import Types

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
    result.height = 0
    result.width = 0
    result.pixels = newSeq[Color](0)
    return result

proc newHdrImage*(width,height : int): HdrImage = 
    #[Constructor with elements, initialize the variables to given values]#
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
    return ( (x >= 0) and (x <= img.width) ) and
           ( (y >= 0) and (y <= img.height) ) 

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
