## Definition of class point with its methods. Note that its algebra its defined via templates, you can find it in geometryalgebra.nim

# Point type declaration

import std/math

type Point* = object
    ## Point type declaration. Is the equivalent of a point in R^3 with its mathematical properties.
    x* , y* , z*: float    # Coordinates of the point in R^3

# Constructors

proc newPoint*(): Point =
    ## Empty constructor, initialize the origin point (all coordinates are null).
    result.x = 0.0
    result.y = 0.0
    result.z = 0.0
    return result

proc newPoint*(x,y,z : float): Point =
    ## Constructor with elements, initialize a point with the coordinates passed as arguments.
    result.x = x
    result.y = y
    result.z = z
    return result

# Methods 

proc print* (p: Point): void =
    ## Prints Point elements in a clear way
    echo "Point( x=", p.x, ", y=", p.y, ", z=", p.z, ")"

proc is_close*(p1, p2: Point) : bool =
    ## is_close version specialized for Point elements
    return ( almostEqual(p1.x, p2.x) ) and
            ( almostEqual(p1.y, p2.y) ) and
            ( almostEqual(p1.z, p2.z) )
    

