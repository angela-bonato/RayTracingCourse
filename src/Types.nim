import std/seqtils 

type 
    #Color class definition, it contains RGB definition of a color
    Color*=object   #it needs to be fast so I use stack memory
        r*, g*, b*: float32

    #HDR image class definition, it contains a matrix of Color elements saved as a 1-D array
    HdrImage*=ref object
        width*, height*: int
        pixels*: Seq[Color]