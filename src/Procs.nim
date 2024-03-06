#[
    Some useful procs 
]#

import Types
import std/sequtils

### Color type constructors ###

proc newColor*(): Color =       
    #[Empty constructor, initialize all the variables to zero]#
    result.r, result.g, result.b = 0.0
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
    result.height, result.width = 0
    result.pixels = newSeq[Color](0)
    return result

proc newHdrImage*(height,width : int): HdrImage = 
    #[Constructor with elements, initialize the variables to given values]#
    result.height = height
    result.width = width
    result.pixels = newSeq[Color](height*width)

