import std/unittest
import std/options
import std/math
import ../src/shapes
import ../src/ray
import ../src/vector
import ../src/point
import ../src/normal
import ../src/transformation

suite "test sphere":
    ## Tests on Sphere
    echo "Started tests on Sphere"
    
    setup:
        var
            unitary_sphere = NewSphere()
            traslated_sphere = NewSphere(translation( newVector(10.0,0,0)))
        echo "New test started"

    test "Ray direction z":
        var 
            ray = newRay(newPoint(0,0,2.0),newVector(0,0,-1.0))
            teoretical_hit_point = newPoint(0,0,1.0)
            teoretical_normal = newNormal(0,0,1.0)
            teoretical_uv_coordinates = newVec2d(0,0)
            hit_point = unitary_sphere.ray_intersection(ray)

        assert hit_point.isSome
        assert hit_point.get().world_point.is_close( teoretical_hit_point )
        assert hit_point.get().normal.is_close( teoretical_normal )
        assert hit_point.get().t.almostEqual(1.0)
        assert hit_point.get().surface_point.is_close( teoretical_uv_coordinates )

    test "Ray direction x":
        var 
            ray = newRay(newPoint(3.0,0,0),newVector(-1,0,0))
            teoretical_hit_point = newPoint(1.0,0,0)
            teoretical_normal = newNormal(1.0,0,0)
            teoretical_uv_coordinates = newVec2d(0,0.5)
            hit_point = unitary_sphere.ray_intersection(ray)

        assert hit_point.isSome
        assert hit_point.get().world_point.is_close( teoretical_hit_point )
        assert hit_point.get().normal.is_close( teoretical_normal )
        assert hit_point.get().t.almostEqual(2.0)
        assert hit_point.get().surface_point.is_close( teoretical_uv_coordinates )

    test "Ray inside the sphere":
        var 
            ray = newRay(newPoint(0,0,0),newVector(1,0,0))
            teoretical_hit_point = newPoint(1.0,0,0)
            teoretical_normal = newNormal(-1.0,0,0)
            teoretical_uv_coordinates = newVec2d(0,0.5)
            hit_point = unitary_sphere.ray_intersection(ray)

        assert hit_point.isSome
        assert hit_point.get().world_point.is_close( teoretical_hit_point )
        assert hit_point.get().normal.is_close( teoretical_normal )
        assert hit_point.get().t.almostEqual(1.0)
        assert hit_point.get().surface_point.is_close( teoretical_uv_coordinates )

    test "Traslated sphere intersection 1":
        var
            ray = newRay(newPoint(10.0,0,2.0),newVector(0,0,-1.0))
            teoretical_hit_point = newPoint(10.0,0,1.0)
            teoretical_normal = newNormal(0,0,1.0)
            teoretical_uv_coordinates = newVec2d(0,0)
            hit_point = traslated_sphere.ray_intersection(ray)
            hit_point_2 = unitary_sphere.ray_intersection(ray)

        assert hit_point.isSome
        assert hit_point_2.isNone
        assert hit_point.get().world_point.is_close( teoretical_hit_point )
        assert hit_point.get().normal.is_close( teoretical_normal )
        assert hit_point.get().t.almostEqual(1.0)
        assert hit_point.get().surface_point.is_close( teoretical_uv_coordinates )

    test "Traslated sphere intersection 2":
        var
            ray = newRay(newPoint(13.0,0,0),newVector(-1,0,0))
            teoretical_hit_point = newPoint(11.0,0,0)
            teoretical_normal = newNormal(1.0,0,0)
            teoretical_uv_coordinates = newVec2d(0,0.5)
            hit_point = traslated_sphere.ray_intersection(ray)

        assert hit_point.isSome
        assert hit_point.get().world_point.is_close( teoretical_hit_point )
        assert hit_point.get().normal.is_close( teoretical_normal )
        assert hit_point.get().t.almostEqual(2.0)
        assert hit_point.get().surface_point.is_close( teoretical_uv_coordinates )

    test "Not intersecting rays":
        var 
            ray_1 = newRay(newPoint(0,0,2),newVector(1,0,0))
            ray_2 = newRay(newPoint(-10,0,2),newVector(0,0,-1))
            hit_point_1 = unitary_sphere.ray_intersection(ray_1)
            hit_point_2 = unitary_sphere.ray_intersection(ray_2)

        assert hit_point_1.isNone
        assert hit_point_2.isNone

    teardown:
        echo "Test ended"
    
    echo "Ended tests on Sphere"

    

    