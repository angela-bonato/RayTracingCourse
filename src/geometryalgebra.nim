## Definition of some of the algebra of point, vector and normal classes defined via templates. 

import point
import vector
import normal
import transformation
import hommatrix

# Algebra for points and vectors

template define_3Dop(op: untyped, type1: typedesc, type2: typedesc, ret: typedesc) =
    proc op* (a: type1, b:type2) : ret =
        ## Definition of "mixed" sums and differences in R^3
        result.x = op(a.x, b.x)
        result.y = op(a.y, b.y)
        result.z = op(a.z, b.z)

define_3Dop(`+`, Vector, Point, Point)
define_3Dop(`+`, Point, Vector, Point)  # Equal to the one defined before but inverted for comodity
define_3Dop(`-`, Point, Vector, Point)  
define_3Dop(`-`, Point, Point, Vector)

proc point_to_vec*(p: Point) : Vector =
    ## Gives the vector defined from the origin to the point taken as an argument
    result.x = p.x
    result.y = p.y
    result.z = p.z
    return result

proc dot*(norm: Normal, vec: Vector) : float =
    ## scalar product between normal and vector
    return norm.x * vec.x + norm.y * vec.y + norm.z * vec.z

proc dot*(vec: Vector, norm: Normal) : float =
    ## scalar product between vector and normal
    return norm.x * vec.x + norm.y * vec.y + norm.z * vec.z

# Algebra usefull with transformations

func `*`*(tr: Transformation, p1: Point) : Point =
    ##  product between a transformation (4x4 matrix) and a point (3 coordinates and 1)
    var 
        p2 = newPoint()     # result of tr*p1
        w = p1.x*tr.matrix.getElement(3, 0) + p1.y*tr.matrix.getElement(3, 1) + p1.z*tr.matrix.getElement(3, 2) + tr.matrix.getElement(3, 3)    # normalizing factor

    p2.x = p1.x*tr.matrix.getElement(0, 0) + p1.y*tr.matrix.getElement(0, 1) + p1.z*tr.matrix.getElement(0, 2) + tr.matrix.getElement(0, 3)
    p2.y = p1.x*tr.matrix.getElement(1, 0) + p1.y*tr.matrix.getElement(1, 1) + p1.z*tr.matrix.getElement(1, 2) + tr.matrix.getElement(1, 3)
    p2.z = p1.x*tr.matrix.getElement(2, 0) + p1.y*tr.matrix.getElement(2, 1) + p1.z*tr.matrix.getElement(2, 2) + tr.matrix.getElement(2, 3)

    if(w.almostEqual(1.0)):
        return p2
    else:
        return newPoint(p2.x/w, p2.y/w, p3.z/w)

func `*`*(tr: Transformation, v1: Vector) : Vector =
    ##  product between a transformation (4x4 matrix) and a vector (3 coordinates and 0)
    var 
        v2 = newVector()     # result of tr*v1

    v2.x = v1.x*tr.matrix.getElement(0, 0) + v1.y*tr.matrix.getElement(0, 1) + v1.z*tr.matrix.getElement(0, 2)
    v2.y = v1.x*tr.matrix.getElement(1, 0) + v1.y*tr.matrix.getElement(1, 1) + v1.z*tr.matrix.getElement(1, 2)
    v2.z = v1.x*tr.matrix.getElement(2, 0) + v1.y*tr.matrix.getElement(2, 1) + v1.z*tr.matrix.getElement(2, 2)

    return v2

func `*`*(tr: Transformation, v1: Vector) : Vector =
    ##  product between a transformation (4x4 matrix) and a vector (3 coordinates and 0)
    var 
        v2 = newVector()     # result of tr*v1

    v2.x = v1.x*tr.matrix.getElement(0, 0) + v1.y*tr.matrix.getElement(0, 1) + v1.z*tr.matrix.getElement(0, 2)
    v2.y = v1.x*tr.matrix.getElement(1, 0) + v1.y*tr.matrix.getElement(1, 1) + v1.z*tr.matrix.getElement(1, 2)
    v2.z = v1.x*tr.matrix.getElement(2, 0) + v1.y*tr.matrix.getElement(2, 1) + v1.z*tr.matrix.getElement(2, 2)

    return v2

func `*`*(tr: Transformation, n1: Normal) : Normal =
    ##  product between a transformation (4x4 matrix) and a normal (3 coordinates and 0), similar to tr*vec but using the inverse traspose of tr
    var 
        n2 = newNormal()     # result of tr*n1

    n2.x = n1.x*tr.inv_matrix.getElement(0, 0) + n1.y*tr.inv_matrix.getElement(1, 0) + n1.z*tr.inv_matrix.getElement(2, 0)
    n2.y = n1.x*tr.inv_matrix.getElement(0, 1) + n1.y*tr.inv_matrix.getElement(1, 1) + n1.z*tr.inv_matrix.getElement(2, 1)
    n2.z = n1.x*tr.inv_matrix.getElement(0, 2) + n1.y*tr.inv_matrix.getElement(1, 2) + n1.z*tr.inv_matrix.getElement(2, 2)

    return n2