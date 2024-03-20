#[Implementation of the type Color and its methods]#

### Color type declaration ###

type Color* = object   # It needs to be fast so I use stack memory
        r*, g*, b*: float32    # These are the values that define a color in RGB encoding    

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

## Color methods for sRGB conversion ##

proc luminosity*(col : Color): float =
    #[Evaluates the luminosity of a pixel using Shirley&Morley method]#
    return (max(max(col.r, col.g), col.b) + min(min(col.r, col.g), col.b)) / 2.0

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

### Print method ###

proc print*(col: Color): void =
    #[Prints Color elements in a more efficient way]#
    echo "Color(r=", col.r, ", g=", col.g, ", b=", col.b, ")"

### Usefull for tests ###

proc is_close*(scal1, scal2: float32) : bool =
    #[Used instead of == when rounding errors could give wrong results, for float scalars]#
    return ( abs(scal1-scal2)<=1e-5 )

proc is_close*(scal1, scal2: int) : bool =
    #[same as is_close but for int scalars]#
    return ( abs(float(scal1-scal2))<=1e-5 )

proc is_close*(col1, col2: Color) : bool =
    #[is_close version specialized for Color elements]#
    return ( is_close(col1.r, col2.r) ) and
            ( is_close(col1.g, col2.g) ) and
            ( is_close(col1.b, col2.b) )