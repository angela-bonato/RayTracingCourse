## Implementation of the type HomMatrix and its methods. This code define a type matrix which is a 16 elements array that can be used as as 4x4 matrix through GetPixel and SetPixel methods (as done with HdrImage).


import std/math

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

proc valid_coordinates*(mat: HomMatrix, x,y: int) : bool = 
    ## Check if the given coordinates are inside the 4x4 matrix
    return ( (x >= 0) and (x < 4) ) and
           ( (y >= 0) and (y < 4) ) 

proc element_offset*(mat: HomMatrix, x,y: int) : int = 
    ## Give the linear position of an element, given its x,y
    return y * 4 + x

proc getElement*(mat: HomMatrix, x,y: int) : float =
    ## Get the element in position x,y of the matrix
    assert mat.valid_coordinates(x,y)
    return mat.elements[mat.element_offset(x,y)]

proc setElement*(mat: var HomMatrix, x,y: int, elem : float) : void =
    ## Set the element at the coordinates x,y in the matrix
    assert mat.valid_coordinates(x,y)
    mat.elements[mat.element_offset(x,y)] = elem

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

