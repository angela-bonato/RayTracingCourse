#[Some useful procs related to PFM format files]#

import Types
import Procs_methods
import std/streams
import std/endians
import std/strutils

### Write PFM file ###

proc write_float*(stream: Stream, num: float32, endianness: Endianness): void =
    #[Writes a float on a stream, with a specified endianness]#
    var tmp: int32  # int32 is used to ensure correct byte writing on the stream
    
    if endianness == bigEndian:
        bigEndian32(addr tmp, addr num)     # Convert the float to big endian
    elif endianness == littleEndian:
        littleEndian32(addr tmp, addr num)  # Convert the float to little endian
    
    stream.write(tmp)                       # Write the bytes of the converted float to the stream


proc write_pfm*(img: HdrImage, stream: Stream, endianness = littleEndian): void =
    #[write the HdrImage on a file using the PFM format]#
    var 
        endianness_str: string
        header: string

    # Set the endianness string 
    if endianness == littleEndian:
        endianness_str = "-1.0"
    elif endianness == bigEndian:
        endianness_str = "1.0"

    # PFM file header format
    header = "PF\n" & intToStr(img.width) & " " & intToStr(img.height) & "\n" & endianness_str & "\n"
    stream.write(header)

    # Writing the colors to the file, following the PFM format (bottom to top, left to right)
    for y in countdown(img.height - 1, 0):
        for x in 0 ..< img.width: 
            var color = img.getPixel(x, y)
            write_float(stream, color.r, endianness)  # Write red channel
            write_float(stream, color.g, endianness)  # Write green channel
            write_float(stream, color.b, endianness)  # Write blue channel


### Read PFM files ###

proc read_float*(stream : Stream, endianness : Endianness) : float =
    #[to read a float32 from a stream of bytes, given an endianness]#
    var 
        num : float32
        tmp : float32

    if endianness == littleEndian:                  # Check if the endianness is little endian
        if stream.readData(addr(num), 4) == 4:      # Attempt to read 4 bytes from the stream into num
            return num                              # Return the float if successful
    if endianness == bigEndian:                     # Check if the endianness is big endian
        if stream.readData(addr(tmp), 4) == 4:      # Attempt to read 4 bytes from the stream into tmp
            bigEndian32(addr(num), addr(tmp))       # Use bigEndian32 to reverse the byte order
            return num                              # Return the float with correct endianness


proc parse_img_size*(line : string) : (int, int) =   # in the main you should write let (w, h) = parse_img_size(line) 
    #[reads the line with width and height contained in the header of a PFM file and returns them as ints]#
    var 
        elements = split(line, " ")      # Split the line into elements based on space
        width, height : int

    if elements.len != 2:
       raise InvalidPfmFileFormat.newException("Invalid image size specification")  # The dimension of the image must be two
    
    try:
        width = parseInt(elements[0])    # Parse the width from the first element
        height = parseInt(elements[1])   # Parse the height from the second element
    except ValueError as e:
        raise InvalidPfmFileFormat.newException("Invalid width/height format: " & e.msg) # Error raised if it fails converting string to int

    if width >= 0 and height >= 0:
        return (width, height)          # Return the width and height as a tuple if they are non-negative
    else:
        raise InvalidPfmFileFormat.newException("Invalid width/height: width and height must be non-negative")   # The dimension of the image must be non-negative

proc parse_endianness*(line : string) : Endianness = 
    #[to understand which is the endianness of the file, it must be a positive or negative number]#
    var value : float

    try: 
        value = parseFloat(line)                                          # Attempt to parse the line as a float
    except ValueError as e:
        raise InvalidPfmFileFormat.newException("Invalid endianness format: " & e.msg)  # Error raised if it fails converting string to float

    if value > 0:                                                          
        return bigEndian                                                   # Return big endian if value is positive
    elif value < 0:
        return littleEndian                                                # Return little endian if value is negative
    else :
        raise InvalidPfmFileFormat.newException("Invalid endianness specification: it cannot be zero") # Error raised if the value is zero


proc read_pfm_image*(stream : Stream) : HdrImage =
    #[to read a pfm file and save the data in a HdrImage variable]#
    var 
        magic, img_size, endianness_line : string
        
    try:
        assert stream.readLine(magic)           # Read the magic string from the header
        assert stream.readLine(img_size)        # Read the image size from the header
        assert stream.readLine(endianness_line) # Read the endianness information from the header
    except ValueError as e:
        raise InvalidPfmFileFormat.newException("Impossible to read from file: " & e.msg)

    if magic != "PF":
        raise InvalidPfmFileFormat.newException("Invalid magic in PFM file")   # Check if the file is a PFM file

    let 
        (w, h) = parse_img_size(img_size)                   # Parse image width and height
        endianness = parse_endianness(endianness_line)      # Parse endianness information
        image = newHdrImage(w, h)                           # Create a new HDR image object

    for y in countdown( h-1 , 0 ):                          # Iterate over the image rows
        for x in 0 ..< w:                                   # Iterate over the image columns
            var 
                r = stream.read_float(endianness)           # Read red channel value
                g = stream.read_float(endianness)           # Read green channel value
                b = stream.read_float(endianness)           # Read blue channel value
                col = newColor(r,g,b)                       # Create a new color object

            image.setPixel(x,y,col)                         # Set the pixel value in the HDR image

    return image                                             # Return the populated HDR image
