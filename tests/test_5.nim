import ../src/color
import ../src/hdrimage
import ../src/point
import ../src/vector
import ../src/transformation
import ../src/ray
import ../src/camera
import ../src/imagetracer
import std/math
import std/unittest

##Tests on functions related to cameras classes (ray, camera, imagetracer)##

# Ray class

proc test_ray(): void =
    ## Tests related to ray methods
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
    ## Test on the action of a transformation on a ray object
    var
        ray = newRay(newPoint(1.0, 2.0, 3.0), newVector(6.0, 5.0, 4.0))
        transformation = translation(newVector(10.0, 11.0, 12.0)) * rotation_x(PI/2.0)
        transformed = ray.transform(transformation)

    assert transformed.origin.is_close(newPoint(11.0, 8.0, 14.0))
    assert transformed.dir.is_close(newVector(6.0, -4.0, 5.0))

# Camera class

proc test_orthogonal_camera(): void =
    ## Tests the definition of a camera with orthogonal features
    var 
        cam = newCamera(2.0)     #I pass the aspect ratio as argument but I leave distance and transformation as default
        fire_ray = fire_ray_orthogonal  #I define a FireRayProc object to make cam behave as an orthogonal camera
        ray1 = cam.fire_ray(0.0, 0.0)
        ray2 = cam.fire_ray(1.0, 0.0)
        ray3 = cam.fire_ray(0.0, 1.0)
        ray4 = cam.fire_ray(1.0, 1.0)

    # We verify that the rays are parallel by verifying that cross-products vanish
    assert almostEqual(0.0, ray1.dir.cross(ray2.dir).squared_norm())
    assert almostEqual(0.0, ray1.dir.cross(ray3.dir).squared_norm())
    assert almostEqual(0.0, ray1.dir.cross(ray4.dir).squared_norm())

    # We verify that the ray hitting the corners have the right coordinates
    assert ray1.at(1.0).is_close(newPoint(0.0, 2.0, -1.0))
    assert ray2.at(1.0).is_close(newPoint(0.0, -2.0, -1.0))
    assert ray3.at(1.0).is_close(newPoint(0.0, 2.0, 1.0))
    assert ray4.at(1.0).is_close(newPoint(0.0, -2.0, 1.0))

proc test_orthogonal_camera_transform(): void =
    ##Tests the action of a transformation on an orthogonal camera
    var 
        cam = newCamera(transform = (translation(newVector(0.0, -1.0, 0.0) * 2.0) * rotation_z(PI/2.0)))    #Uses default aspect_ratio and distance
        fire_ray = fire_ray_orthogonal  #cam is now an orthogonal camera
        ray = cam.fire_ray(0.5, 0.5)

    assert ray.at(1.0).is_close(newPoint(0.0, -2.0, 0.0))

proc test_perspective_camera(): void =
    ## Tests the definition of a camera with perspective features
    var
        cam = newCamera(distance=1.0, aspect_ratio=2.0)
        fire_ray = fire_ray_perspective  #I define a FireRayProc object to make cam behave as a perspective camera
        ray1 = cam.fire_ray(0.0, 0.0)
        ray2 = cam.fire_ray(1.0, 0.0)
        ray3 = cam.fire_ray(0.0, 1.0)
        ray4 = cam.fire_ray(1.0, 1.0)

    # Verify that all the rays depart from the same point
    assert ray1.origin.is_close(ray2.origin)
    assert ray1.origin.is_close(ray3.origin)
    assert ray1.origin.is_close(ray4.origin)

    # Verify that the ray hitting the corners have the right coordinates
    assert ray1.at(1.0).is_close(newPoint(0.0, 2.0, -1.0))
    assert ray2.at(1.0).is_close(newPoint(0.0, -2.0, -1.0))
    assert ray3.at(1.0).is_close(newPoint(0.0, 2.0, 1.0))
    assert ray4.at(1.0).is_close(newPoint(0.0, -2.0, 1.0))

# ImageTracer class implemented using unittest

proc solverendproc(ray: Ray): Color =
    ##Just a temporary proc which inherit from SolveRenderingProcs type, to be used in the next proc
    return newColor(1.0, 2.0, 3.0)

suite "test_image_tracer":
    ##Tests on ImageTracer methods
    echo "Starting tests on ImageTracer."

    setup:
        var 
            img = newHdrImage(4, 2)
            cam = newCamera(aspect_ratio=2)
            fire_ray = fire_ray_perspective     #cam is a perspective camera
            trc = newImageTracer(img, cam)

        echo "New test started."

    teardown:
        echo "Test completed."

    test "Orientation":
        var 
            top_left_ray = trc.fire_ray_pixel(0, 0, fire_ray, u_pixel=0.0, v_pixel=0.0)
            bottom_right_ray = trc.fire_ray_pixel(3, 1, fire_ray, u_pixel=1.0, v_pixel=1.0)
        
        check(newPoint(0.0, 2.0, 1.0).is_close(top_left_ray.at(1.0)))
        check(newPoint(0.0, -2.0, -1.0).is_close(bottom_right_ray.at(1.0)))

    test "u-v sub-mapping":
        var
            ray1 = trc.fire_ray_pixel(0, 0, fire_ray, u_pixel=2.5, v_pixel=1.5)
            ray2 = trc.fire_ray_pixel(2, 1, fire_ray, u_pixel=0.5, v_pixel=0.5)

        check(ray1.is_close(ray2))

    test "Image coverage":
        var sol = solverendproc

        trc.fire_all_rays(fire_ray, sol)
        for row in 0..<img.height:
            for col in 0..<img.width:
                check(is_close(img.get_pixel(col, row), newColor(1.0, 2.0, 3.0)))

    echo "Completed tests on ImageTracer."

##Running all the tests##
test_ray()
test_ray_transform()
test_orthogonal_camera()
test_orthogonal_camera_transform()
test_perspective_camera()
