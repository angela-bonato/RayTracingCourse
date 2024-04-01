## Implementation of the vector type and its methods. A normal is the vector perpendicluar to a surface. It is usefull to define a normal class because the normal vector transform in a different way.

import std/math

# Normal type definition

type Normal* = object
    x*, y*, z* : float

# Normal type constructors

proc newNormal*() : Normal =
    ## Empty constructor, initialize all the variables to zero
    result.x = 0
    result.y = 0
    result.z = 0

    return result

proc newNormal*(x,y,z : float) : Normal = 
    ## Constructor with elements, initialize the variables to given values
    result.x = x
    result.y = y
    result.z = z

    return result

# Normal algebra

proc neg*(vec: Normal) : Normal =
    ## Negate a normal h -> -h
    result.x = - vec.x 
    result.y = - vec.y
    result.z = - vec.z 

    return result

proc `*`*(a: float, b: Normal) : Normal =
    ## Multiplication between scalar and normal
    result.x = a * b.x
    result.y = a * b.y
    result.z = a * b.z

    return result

proc `*`*(a: Normal, b: float) : Normal =
    ## Multiplication between scalar and normal
    result.x = a.x * b
    result.y = a.y * b
    result.z = a.z * b

    return result

proc `/`*(a: Normal, b: float) : Normal =
    ## Division of a normal for a scalar
    result.x = a.x / b
    result.y = a.y / b
    result.z = a.z / b

    return result

proc cross*(norm1, norm2 : Normal) : Normal =
    ## Give the vector product between two normals
    return newNormal( x = norm1.y * norm2.z - norm1.z * norm2.y,
                      y = norm1.z * norm2.x - norm1.x * norm2.z,
                      z = norm1.x * norm2.y - norm1.y * norm2.x )

proc squared_norm*(norm: Normal) : float =
    ## Give the squared norm of a normal
    return (norm.x^2 + norm.y^2 + norm.z^2)

proc norm*(normal: Normal) : float =
    ## Give the norm of a normal
    return sqrt( normal.squared_norm() )

proc normalized*(normal: Normal) : Normal =
    ## Give a normalized normal
    var norm = normal.norm()
    return (normal / norm)

# Useful for tests

proc is_close*(norm1, norm2 : Normal) : bool =
    ## Is close proc for normals
    return ( norm1.x.almostEqual(norm2.x) and norm1.y.almostEqual(norm2.y) and norm1.z.almostEqual(norm2.z) )

proc print*(norm: Normal) : void =
    ## Print normal in a simple way for debugging
    echo "Normal( x:", norm.x, ", y:", norm.y, ", z:", norm.z, ")"   
