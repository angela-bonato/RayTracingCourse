## Implementation of the Implementation type and its methods. Transformation is a matrix that acts in a differen way on Vectors and Normals.

import hommatrix
import vector
import std/math

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

# Different types of transformation

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

## useful for test

proc print*(t: Transformation) : void =
    ## to print a transformaation in a nice way
    
    #echo t.matrix.getElement(0,0)

    
    echo "Transformation \nMatrix[",  t.matrix.getElement(0,0), ", ", t.matrix.getElement(1,0), ", ", t.matrix.getElement(2,0), ", ", t.matrix.getElement(3,0), ",\n       ",
                                      t.matrix.getElement(0,1), ", ", t.matrix.getElement(1,1), ", ", t.matrix.getElement(2,1), ", ", t.matrix.getElement(3,1), ",\n       ", 
                                      t.matrix.getElement(0,2), ", ", t.matrix.getElement(1,2), ", ", t.matrix.getElement(2,2), ", ", t.matrix.getElement(3,2), ",\n       ", 
                                      t.matrix.getElement(0,3), ", ", t.matrix.getElement(1,3), ", ", t.matrix.getElement(2,3), ", ", t.matrix.getElement(3,3), "]\n",
                  "Inverse Matrix[",  t.inv_matrix.getElement(0,0), ", ", t.inv_matrix.getElement(1,0), ", ", t.inv_matrix.getElement(2,0), ", ", t.inv_matrix.getElement(3,0), ",\n               ",
                                      t.inv_matrix.getElement(0,1), ", ", t.inv_matrix.getElement(1,1), ", ", t.inv_matrix.getElement(2,1), ", ", t.inv_matrix.getElement(3,1), ",\n               ",
                                      t.inv_matrix.getElement(0,2), ", ", t.inv_matrix.getElement(1,2), ", ", t.inv_matrix.getElement(2,2), ", ", t.inv_matrix.getElement(3,2), ",\n               ", 
                                      t.inv_matrix.getElement(0,3), ", ", t.inv_matrix.getElement(1,3), ", ", t.inv_matrix.getElement(2,3), ", ", t.inv_matrix.getElement(3,3), "]\n"
    