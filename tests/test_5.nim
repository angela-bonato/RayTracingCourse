import ../src/point
import ../src/vector
import ../src/transformation
import ../src/ray
import std/math

##Tests on functions related to cameras classes (ray, camera, imagetracer)##

proc test_ray(): void =
    ## Tests related to ray class
    var 
        ray1 = newRay(newPoint(1.0, 2.0, 3.0), newVector(5.0, 4.0, -1.0))     # Here I use all possible default values
        ray2 = newRay(newPoint(1.0, 2.0, 3.0), newVector(5.0, 4.0, -1.0), 0)  # I specify depth value
        ray3 = newRay(newPoint(1.0, 2.0, 4.0), newVector(4.0, 2.0, 1.0), tmin=1e-5)  # I use default depth but I specify tmin

    # Asserts on newRay
    assert ray2.depth == ray3.depth
    assert almostEqual(ray2.tmin, ray3.tmin)

    # Asserts on is_close
    assert ray1.is_close(ray2)
    assert not ray1.is_close(ray3)

    # Asserts on at
    assert ray3.at(0.0).is_close(ray3.origin)
    assert ray3.at(1.0).is_close(newPoint(5.0, 4.0, 5.0))
    assert ray3.at(2.0).is_close(newPoint(9.0, 6.0, 6.0))

proc test_ray_transform(): void =
    ## Test on trasform method
    var
        ray = newRay(newPoint(1.0, 2.0, 3.0), newVector(6.0, 5.0, 4.0))
        transformation = translation(newVector(10.0, 11.0, 12.0)) * rotation_x(PI/2.0)
        transformed = ray.transform(transformation)

    assert transformed.origin.is_close(newPoint(11.0, 8.0, 14.0))
    assert transformed.dir.is_close(newVector(6.0, -4.0, 5.0))


##Running all the tests##
test_ray()
test_ray_transform()


