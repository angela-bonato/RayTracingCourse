import std/sequtils 

type 
    #Color class definition, it contains RGB definition of a color
    Color*=object   #it needs to be fast so I use stack memory
        r*, g*, b*: float32    #these are the values that defines a color in RGB encode    

    #HDR image class definition, it contains a matrix of Color elements saved as a 1-D array
    HdrImage*=ref object
        width*, height*: int    #dimensions of the matrix
        pixels*: Seq[Color]    #1D array with all the Colors in the image