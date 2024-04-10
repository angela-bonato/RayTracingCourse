import ../src/point
import ../src/vector
import ../src/normal
import ../src/hommatrix
import ../src/transformation
import ../src/geometryalgebra
import std/math

##Tests on functions related to geometry classes (point, vector, normal, transformation)##

proc test_point(): void =
    #[tests Point constructors and is_close definition]#
    var
        origin = newPoint()
        point = newPoint(3.0, 2.0, 1.5)
    
    assert almostEqual(origin.x, 0.0)
    assert almostEqual(origin.y, 0.0)
    assert almostEqual(origin.z, 0.0)
    assert almostEqual(point.x, 3.0)
    assert almostEqual(point.y, 2.0)
    assert almostEqual(point.z, 1.5)
    assert origin.is_close(origin)
    assert not point.is_close(origin)

proc test_point_operation(): void =
    ## test point operations
    var
        p1 = newPoint(1.0, 2.0, 3.0)
        p2 = newPoint(4.0, 6.0, 8.0)
        v = newVector(4.0, 6.0, 8.0)

    assert (2*p1).is_close(newPoint(2.0, 4.0, 6.0))
    assert (p1 + v).is_close(newPoint(5.0, 8.0, 11.0))
    assert (p2 - p1).is_close(newVector(3.0, 4.0, 5.0))
    assert (p1 - v).is_close(newPoint(-3.0, -4.0, -5.0))


proc test_vector(): void =
    ## test vector constructor 
    var 
        a = newVector(1.0, 2.0, 3.0)
        b = newVector(4.0, 6.0, 8.0)
    
    assert a.is_close(a)
    assert not a.is_close(b)

proc test_vector_operations(): void =
    ## test vector operations
    var 
        a = newVector(1.0, 2.0, 3.0)
        b = newVector(4.0, 6.0, 8.0)

    assert a.neg().is_close(newVector(-1.0,-2.0,-3.0))
    assert (a+b).is_close(newVector(5.0,8.0,11.0))
    assert (b-a).is_close(newVector(3.0, 4.0, 5.0))
    assert (2*a).is_close(newVector(2.0, 4.0, 6.0))
    assert a.dot(b).almostEqual(40.0)
    assert a.cross(b).is_close(newVector(-2.0, 4.0, -2.0))
    assert b.cross(a).is_close(newVector(2.0, -4.0, 2.0))
    assert a.squared_norm().almostEqual(14.0)
    assert almostEqual(14.0, a.norm()^2)

proc test_normal(): void =
    ## test normal constructor 
    var 
        a = newNormal(1.0, 2.0, 3.0)
        b = newNormal(4.0, 6.0, 8.0)
    
    assert a.is_close(a)
    assert not a.is_close(b)

proc test_normal_operations(): void =
    ## test normal operations
    var 
        a = newNormal(1.0, 2.0, 3.0)
        b = newNormal(4.0, 6.0, 8.0)

    assert a.neg().is_close(newNormal(-1.0,-2.0,-3.0))
    assert (2*a).is_close(newNormal(2.0, 4.0, 6.0))
    assert a.cross(b).is_close(newNormal(-2.0, 4.0, -2.0))
    assert b.cross(a).is_close(newNormal(2.0, -4.0, 2.0))
    assert a.squared_norm().almostEqual(14.0)
    assert almostEqual(14.0, a.norm()^2)

## Test on HomMatrix class

proc test_mat_creation() : void =
    ## tests HomMatrix creators
    var
        m1 = newHomMatrix()
        m2 = newHomMatrix([1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0])
    
    assert m1.is_close(m2)

proc test_element_access(): void =
    ##tests all methods regarding element access
    var
        mat = newHomMatrix()

    assert mat.valid_coordinates(0, 0)
    assert mat.valid_coordinates(3, 2)
    assert not mat.valid_coordinates(-1, 0)
    assert not mat.valid_coordinates(0, -1)
    assert not mat.valid_coordinates(4, 0)
    assert not mat.valid_coordinates(0, 4)

    assert mat.element_offset(3, 2)==11
    
    mat.setElement(2, 3, 5.3)

    assert almostEqual(mat.getElement(2, 3), 5.3)

proc test_matrix_product() : void=
    ##tests the overloading of * 
    var
        m1 = newHomMatrix()
        m2 = newHomMatrix([1.0, 2.0, 3.0, 4.0, 
                           5.0, 6.0, 7.0, 8.0, 
                           9.0, 10.0, 11.0, 12.0,
                           13.0, 14.0, 15.0, 16.0])
        m3 = m1*m2
    
    assert m3.is_close(m2)

##Running all the tests##
test_point()
test_point_operation()
test_vector()
test_vector_operations()
test_normal()
test_normal_operations()
test_mat_creation()
test_element_access()
test_matrix_product()