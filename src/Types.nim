#[ Definition of type Color and HdrImage ]#

type
    # Color class definition, it contains RGB definition of a color
    Color* = object   # It needs to be fast so I use stack memory
        r*, g*, b*: float32    # These are the values that define a color in RGB encoding    

    # HDR image class definition, it contains a matrix of Color elements saved as a 1-D array
    HdrImage* = ref object
        width*, height*: int    # Dimensions of the matrix
        pixels*: seq[Color]    # 1D array with all the Colors in the image

    # Exception definition, error raised if something wrong happens in reading a PFM file
    InvalidPfmFileFormat* = object of IOError

