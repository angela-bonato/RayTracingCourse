## Implementation of the vector type and its methods. Vector is a tree element list, that is supposed to transform as a vector v under a transformation A (a matrix) : v' = A v 

import std/math

# Vector type declaration

type Vector* = object 
    x*, y*, z* : float

# Vector type constructors

proc newVector*() : Vector =
    ## Empty constructor, initialize all the variables to zero
    result.x = 0
    result.y = 0
    result.z = 0

    return result

proc newVector*(x,y,z : float) : Vector = 
    ## Constructor with elements, initialize the variables to given values
    result.x = x
    result.y = y
    result.z = z

    return result

# Vector algebra

proc neg*(vec: Vector) : Vector =
    ## Negate a vector v -> -v
    result.x = - vec.x 
    result.y = - vec.y
    result.z = - vec.z 

    return result

template define_op(fname: untyped) =
    proc fname*(a: Vector, b: Vector) : Vector =
        ## Operation between vectors
        result.x = fname(a.x,b.x)
        result.y = fname(a.y,b.y)
        result.z = fname(a.z,b.z)

        return result

define_op(`+`)
define_op(`-`)

proc `*`*(a: float, b: Vector) : Vector =
    ## Multiplication between scalar and vector
    result.x = a * b.x
    result.y = a * b.y
    result.z = a * b.z

    return result

proc `*`*(a: Vector, b: float) : Vector =
    ## Multiplication between scalar and vector
    result.x = a.x * b
    result.y = a.y * b
    result.z = a.z * b

    return result

proc `/`*(a: Vector, b: float) : Vector =
    ## Division of a vector for a scalar
    result.x = a.x / b
    result.y = a.y / b
    result.z = a.z / b

    return result

proc squared_norm*(vec: Vector) : float =
    ## Give the squared norm of a vector
    return (vec.x^2 + vec.y^2 + vec.z^2)

proc norm*(vec: Vector) : float =
    ## Give the norm of a vector
    return sqrt( vec.squared_norm() )

proc normalized*(vec: Vector) : Vector =
    ## Give a normalized vector
    var norm = vec.norm()
    return (vec / norm)

proc dot*(vec1: Vector, vec2: Vector) : float =
    ## Give the scalar product between two vectors
    return vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z

proc cross*(vec1: Vector, vec2: Vector) : Vector = 
    ## Give the vector product between two vectors
    return newVector( x = vec1.y * vec2.z - vec1.z * vec2.y,
                      y = vec1.z * vec2.x - vec1.x * vec2.z,
                      z = vec1.x * vec2.y - vec1.y * vec2.x )

# Usefull for tests

proc is_close*(vec1, vec2 : Vector) : bool =
    ## Is close proc for vectors
    return ( vec1.x.almostEqual(vec2.x) and vec1.y.almostEqual(vec2.y) and vec1.z.almostEqual(vec2.z) )

proc print*(vec: Vector) : void =
    ## Print vector in a simple way for debugging
    echo "Vector( x:", vec.x, ", y:", vec.y, ", z:", vec.z, ")"   