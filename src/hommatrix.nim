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