import ../src/point
import ../src/vector
import ../src/normal
import ../src/transformation
import std/unittest

##Tests on functions related to geometry classes (point, vector, normal, transformation)##

proc test_point(): void =
    #[tests Point constructors and is_close definition]#
    var
        origin = newPoint()
        point = newPoint(3.0, 2.0, 1.5)
    
    assert is_close(origin.x, 0.0)
    assert is_close(origin.y, 0.0)
    assert is_close(origin.z, 0.0)
    assert is_close(point.x, 3.0)
    assert is_close(point.y, 2.0)
    assert is_close(point.z, 1.5)
    assert origin.is_close(origin)
    assert not point.is_close(origin)

##Running all the tests##
test_point()