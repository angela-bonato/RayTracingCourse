## Implementation of the geometry types and their methods. 
import std/math

##Vector is a tree element list, that is supposed to transform as a vector v under a transformation A (a matrix) : v' = A v 
#Vector type declaration. 

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

## Definition of class point with its methods. Note that its algebra its defined via templates, you can find it in geometryalgebra.nim
# Point type declaration

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

proc `*`*(a: float, b: Point) : Point =
    ## Multiplication between scalar and point
    result.x = a * b.x
    result.y = a * b.y
    result.z = a * b.z

    return result

proc `*`*(a: Point, b: float) : Point =
    ## Multiplication between scalar and point
    result.x = a.x * b
    result.y = a.y * b
    result.z = a.z * b

# Usefull for tests

proc print* (p: Point): void =
    ## Prints Point elements in a clear way
    echo "Point( x=", p.x, ", y=", p.y, ", z=", p.z, ")"

proc is_close*(p1, p2: Point) : bool =
    ## is_close version specialized for Point elements
    return ( almostEqual(p1.x, p2.x) ) and
            ( almostEqual(p1.y, p2.y) ) and
            ( almostEqual(p1.z, p2.z) )
    
## Implementation of the vector type and its methods. A normal is the vector perpendicluar to a surface. It is usefull to define a normal class because the normal vector transform in a different way.
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

## Definition of some of the algebra of point, vector and normal classes defined via templates. 
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

## Implementation of the type HomMatrix and its methods. This code define a type matrix which is a 16 elements array that can be used as as 4x4 matrix through GetPixel and SetPixel methods (as done with HdrImage).
# HomMatrix type definition

type HomMatrix* = object   # Stack memory is sufficient
    elements*: array[16, float]  # Empty array

# Constructors

proc newHomMatrix*() : HomMatrix =
    ## Empty constructor, returns the 4x4 identity matrix
    result.elements =  [1.0, 0.0, 0.0, 0.0, 
                        0.0, 1.0, 0.0, 0.0,
                        0.0, 0.0, 1.0, 0.0, 
                        0.0, 0.0, 0.0, 1.0]
    return result

proc newHomMatrix*(myelems: array[16, float]) : HomMatrix =
    ## Constructor which takes as an argument the full elements array of the matrix
    result.elements = myelems
    return result

# Methods to access elements

proc valid_coordinates*(mat: HomMatrix, i,j: int) : bool = 
    ## Check if the given coordinates are inside the 4x4 matrix
    return ( (i >= 0) and (i < 4) ) and
           ( (j >= 0) and (j < 4) ) 

proc element_offset*(mat: HomMatrix, i,j: int) : int = 
    ## Give the linear position of an element, given its x,y
    return i * 4 + j

proc getElement*(mat: HomMatrix, i,j: int) : float =
    ## Get the element in position x,y of the matrix
    assert mat.valid_coordinates(i,j)
    return mat.elements[mat.element_offset(i,j)]

proc setElement*(mat: var HomMatrix, i,j: int, elem : float) : void =
    ## Set the element at the coordinates x,y in the matrix
    assert mat.valid_coordinates(i,j)
    mat.elements[mat.element_offset(i,j)] = elem

# Algebra

func `*`*(m1,m2: HomMatrix) : HomMatrix =
    ## Product m1xm2
    var m3 = newHomMatrix()

    for i in 0..3:
        for j in 0..3:
            var sum : float

            for k in 0..3:      # AxB=C means C(i,j)=A(i,k)*B(k,j) with Einstein's notation
                sum += m1.getElement(i, k) * m2.getElement(k, j)

            m3.setElement(i, j, sum)
    
    return m3

proc is_close*(m1,m2: HomMatrix) : bool =
    ## true if m1 is equal to m2 element wise
    for i in 0..15:
        if(not almostEqual(m1.elements[i], m2.elements[i])):
            return false
    return true

## useful for test

proc print*(h: HomMatrix) : void =
    ## print a hom matrix in a nice way
    
    echo "HomMatrix[", h.getElement(0,0), ", ", h.getElement(0,1), ", ",  h.getElement(0,2), ", ",  h.getElement(0,3), "\n          ",
                       h.getElement(1,0), ", ", h.getElement(1,1), ", ",  h.getElement(1,2), ", ",  h.getElement(1,3), "\n          ",
                       h.getElement(2,0), ", ", h.getElement(2,1), ", ",  h.getElement(2,2), ", ",  h.getElement(2,3), "\n          ",
                       h.getElement(3,0), ", ", h.getElement(3,1), ", ",  h.getElement(3,2), ", ",  h.getElement(3,3), "]"

## Implementation of the Implementation type and its methods. Transformation is a matrix that acts in a differen way on Vectors and Normals.
# Transformation type declaration

type Transformation* = object
    matrix* : HomMatrix
    inv_matrix* : HomMatrix

# Transformation type constructors

proc newTransformation*() : Transformation =
    ## Empty constructor, initialize the matrix to the identity matrix
    result.matrix = newHomMatrix()
    result.inv_matrix = newHomMatrix()

proc newTransformation*(matr, inv_matr : HomMatrix) : Transformation =
    ## Constructor with elements, initialize the variables to given values
    result.matrix = matr
    result.inv_matrix = inv_matr

# Transformation procs

proc inverse*(trans : Transformation) : Transformation =
    ## Give the inverse of a Transformation
    result.matrix = trans.inv_matrix
    result.inv_matrix = trans.matrix

proc is_consistent*(trans : Transformation) : bool =
    ## Check if the transformation is consistent ( T T^-1 = Id)
    var 
        id_matrix = newHomMatrix()
        prod = trans.matrix * trans.inv_matrix

    return prod.is_close(id_matrix)

proc is_close*(t1, t2 : Transformation) : bool =
    if not(t1.matrix.is_close(t2.matrix)) or not(t1.inv_matrix.is_close(t2.inv_matrix)):
        return false
    else: 
        return true

# Different types of transformation

proc scaling*( x,y,z : float) :  Transformation =
    ## Create a trasformation that perform a scale transformation in each direction, given the scaling value
    
    result.matrix = newHomMatrix( [ x,   0.0, 0.0, 0.0, 
                                    0.0, y,   0.0, 0.0, 
                                    0.0, 0.0, z,   0.0, 
                                    0.0, 0.0, 0.0, 1.0 ] )

    result.inv_matrix = newHomMatrix( [ 1/x, 0.0, 0.0, 0.0, 
                                        0.0, 1/y, 0.0, 0.0, 
                                        0.0, 0.0, 1/z, 0.0, 
                                        0.0, 0.0, 0.0, 1.0 ] )

proc translation*(vec: Vector) : Transformation =
    ## Create a Transformation that perform a translation of the given vector
    
    result.matrix = newHomMatrix( [ 1.0, 0.0, 0.0, vec.x, 
                                    0.0, 1.0, 0.0, vec.y, 
                                    0.0, 0.0, 1.0, vec.z, 
                                    0.0, 0.0, 0.0, 1.0 ] )

    result.inv_matrix = newHomMatrix( [ 1.0, 0.0, 0.0, -vec.x, 
                                        0.0, 1.0, 0.0, -vec.y, 
                                        0.0, 0.0, 1.0, -vec.z, 
                                        0.0, 0.0, 0.0, 1.0 ] )

proc rotation_x*(theta : float) : Transformation =
    ## Create a Transformation that perform a rotation of the given angle theta around the x axis
     
    result.matrix = newHomMatrix( [ 1.0, 0.0,        0.0,         0.0,
                                     0.0, cos(theta), -sin(theta), 0.0,
                                     0.0, sin(theta), cos(theta),  0.0,
                                     0.0, 0.0,        0.0,         1.0 ])

    result.inv_matrix = newHomMatrix( [ 1.0, 0.0,         0.0,          0.0,
                                        0.0, cos(-theta), -sin(-theta), 0.0,
                                        0.0, sin(-theta), cos(-theta),  0.0,
                                        0.0, 0.0,         0.0,          1.0 ])

proc rotation_y*(theta : float) : Transformation =
    ## Create a Transformation that perform a rotation of the given angle theta around the x axis
     
    result.matrix = newHomMatrix( [ cos(theta),  0.0, sin(theta), 0.0,
                                     0.0,         1.0, 0.0,        0.0,
                                     -sin(theta), 0.0, cos(theta), 0.0,
                                     0.0,         0.0, 0.0,        1.0 ])

    result.inv_matrix = newHomMatrix( [ cos(-theta),  0.0, sin(-theta), 0.0,
                                        0.0,          1.0, 0.0,         0.0,
                                        -sin(-theta), 0.0, cos(-theta), 0.0,
                                        0.0,          0.0, 0.0,         1.0 ])

proc rotation_z*(theta : float) : Transformation =
    ## Create a Transformation that perform a rotation of the given angle theta around the y axis
     
    result.matrix = newHomMatrix( [ cos(theta), -sin(theta), 0.0, 0.0,
                                     sin(theta), cos(theta),  0.0, 0.0,
                                     0.0,        0.0,         1.0, 0.0,
                                     0.0,        0.0,         0.0, 1.0 ])

    result.inv_matrix = newHomMatrix( [ cos(-theta), -sin(-theta), 0.0, 0.0,
                                        sin(-theta), cos(-theta),  0.0, 0.0,
                                        0.0,         0.0,          1.0, 0.0,
                                        0.0,         0.0,          0.0, 1.0 ])

func `*`*(t1,t2: Transformation) : Transformation =
    ## Perform composition between two transformation via hommatrix product.
    return newTransformation(t1.matrix * t2.matrix, t2.inv_matrix * t1.inv_matrix)

proc print*(t: Transformation) : void =
    ## to print a transformaation in a nice way
    
    #echo t.matrix.getElement(0,0)

    
    echo "Transformation \nMatrix[",  t.matrix.getElement(0,0), ", ", t.matrix.getElement(0,1), ", ", t.matrix.getElement(0,2), ", ", t.matrix.getElement(0,3), ",\n       ",
                                      t.matrix.getElement(1,0), ", ", t.matrix.getElement(1,1), ", ", t.matrix.getElement(1,2), ", ", t.matrix.getElement(1,3), ",\n       ", 
                                      t.matrix.getElement(2,0), ", ", t.matrix.getElement(2,1), ", ", t.matrix.getElement(2,2), ", ", t.matrix.getElement(2,3), ",\n       ", 
                                      t.matrix.getElement(3,0), ", ", t.matrix.getElement(3,1), ", ", t.matrix.getElement(3,2), ", ", t.matrix.getElement(3,3), "]\n",
                  "Inverse Matrix[",  t.inv_matrix.getElement(0,0), ", ", t.inv_matrix.getElement(0,1), ", ", t.inv_matrix.getElement(0,2), ", ", t.inv_matrix.getElement(0,3), ",\n               ",
                                      t.inv_matrix.getElement(1,0), ", ", t.inv_matrix.getElement(1,1), ", ", t.inv_matrix.getElement(1,2), ", ", t.inv_matrix.getElement(1,3), ",\n               ",
                                      t.inv_matrix.getElement(2,0), ", ", t.inv_matrix.getElement(2,1), ", ", t.inv_matrix.getElement(2,2), ", ", t.inv_matrix.getElement(2,3), ",\n               ", 
                                      t.inv_matrix.getElement(3,0), ", ", t.inv_matrix.getElement(3,1), ", ", t.inv_matrix.getElement(3,2), ", ", t.inv_matrix.getElement(3,3), "]\n"

# Algebra usefull with transformations

func `*`*(tr: Transformation, p1: Point) : Point =
    ##  product between a transformation (4x4 matrix) and a point (3 coordinates and 1)
    var 
        p2 = newPoint()     # result of tr*p1
        w = p1.x*tr.matrix.getElement(3, 0) + p1.y*tr.matrix.getElement(3, 1) + p1.z*tr.matrix.getElement(3, 2) + tr.matrix.getElement(3, 3)    # normalizing factor

    p2.x = p1.x*tr.matrix.getElement(0, 0) + p1.y*tr.matrix.getElement(0, 1) + p1.z*tr.matrix.getElement(0, 2) + tr.matrix.getElement(0, 3)
    p2.y = p1.x*tr.matrix.getElement(1, 0) + p1.y*tr.matrix.getElement(1, 1) + p1.z*tr.matrix.getElement(1, 2) + tr.matrix.getElement(1, 3)
    p2.z = p1.x*tr.matrix.getElement(2, 0) + p1.y*tr.matrix.getElement(2, 1) + p1.z*tr.matrix.getElement(2, 2) + tr.matrix.getElement(2, 3)

    if(almostEqual(1.0,w)):
        return p2
    else:
        return newPoint(p2.x/w, p2.y/w, p2.z/w)

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