## Definition of some of the algebra of point, vector and normal classes defined via templates. 

import point
import vector
import normal

# Functions for points and vectors

template define_3Dop(op: untyped, type1: typedesc, type2: typedesc, ret: typedesc) =
    proc op* (a: type1, b:type2) : ret =
        ## Definition of "mixed" sums and differences in R^3
        result.x = op(a.x, b.x)
        result.y = op(a.y, b.y)
        result.z = op(a.z, b.z)

define_3Dop(`+`, Vector, Point, Point)
define_3Dop(`+`, Point, Vector, Point)  #Equal to the one defined before but inverted for comodity
define_3Dop(`-`, Vector, Point, Point)
define_3Dop(`-`, Point, Vector, Point)  #Equal to the one defined before but inverted for comodity
define_3Dop(`+`, Point, Point, Vector)  #da controllare
define_3Dop(`-`, Point, Point, Vector)  #da controllare

proc point_to_vec*(p: Point) : Vector =   #è giusto??
    ## Gives the vector defined from the origin to the point taken as an argument
    result.x = p.x
    result.y = p.y
    result.z = p.z
    return result

