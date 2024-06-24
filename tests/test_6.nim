import std/unittest
import std/options
import std/math
import ../src/world
import ../src/ray
import ../src/geometry
import ../src/materials

suite "Test Sphere":
    ## Tests on Sphere
    echo "Started tests on Sphere"
    
    setup:
        var
            unitary_sphere = newSphere()
            traslated_sphere = newSphere(translation( newVector(10.0,0,0)))
        echo "New test started"

    teardown:
        echo "Test ended"

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

    test "All intersection":
        var
            ray = newRay(newPoint(-2,0,0),newVector(1.0,0,0))
            teoretical_hit_point1 = unitary_sphere.newHitRecord( world_point = newPoint(-1.0,0,0),
                                                  normal = newNormal(-1.0,0,0),
                                                  surface_point = newVec2d(0.5,0.5),
                                                  t = 1.0,
                                                  ray = ray
                                                )
            teoretical_hit_point2 = unitary_sphere.newHitRecord( world_point = newPoint(1.0,0,0),
                                                  normal = newNormal(-1.0,0,0),
                                                  surface_point = newVec2d(0,0.5),
                                                  t = 3.0,
                                                  ray = ray
                                                )
            hit_points = unitary_sphere.all_ray_intersections(ray)


        assert hit_points.isSome()
        assert len(hit_points.get()) == 2
        assert teoretical_hit_point1 in hit_points.get()
        assert teoretical_hit_point2 in hit_points.get()
    
    test "Have inside":
        var 
            point1 = newPoint()
            point2 = newPoint(1,1,1)

        assert unitary_sphere.have_inside(point1)
        assert not unitary_sphere.have_inside(point2)

    echo "Ended tests on Sphere"

suite "Test Plane":

    echo "Started test on Plane"

    setup:
        var 
            xy_plane = newPlane()
        echo "New test started"

    teardown:
        echo "Test ended"

    test "Ray origin with positive z":
        var
            ray = newRay(newPoint(0.5,0.5,1),newVector(0,0,-1))
            teoretical_hit_point = newPoint(0.5,0.5,0)
            teoretical_norm = newNormal(0,0,1)
            teoretical_uv_coordinates = newVec2d(0.5,0.5)
            hit_point = xy_plane.ray_intersection(ray)

        assert hit_point.isSome
        assert hit_point.get().world_point.is_close( teoretical_hit_point )
        assert hit_point.get().normal.is_close( teoretical_norm )
        assert hit_point.get().t.almostEqual(1.0)
        assert hit_point.get().surface_point.is_close( teoretical_uv_coordinates )

    test "Ray origin with negative z":
        var
            ray = newRay(newPoint(0.5,0.5,-1),newVector(0,0,1))
            teoretical_hit_point = newPoint(0.5,0.5,0)
            teoretical_norm = newNormal(0,0,-1)
            teoretical_uv_coordinates = newVec2d(0.5,0.5)
            hit_point = xy_plane.ray_intersection(ray)

        assert hit_point.isSome
        assert hit_point.get().world_point.is_close( teoretical_hit_point )
        assert hit_point.get().normal.is_close( teoretical_norm )
        assert hit_point.get().t.almostEqual(1.0)
        assert hit_point.get().surface_point.is_close( teoretical_uv_coordinates )

    test "Rotated plane":
        var
            rotated_plane = newPlane( rotation_y(PI/4) )
            ray = newRay(newPoint(1,0,1),newVector(-1,0,-1))
            teoretical_hit_point = newPoint(0,0,0)
            teoretical_norm = newNormal(sqrt(2.0)/2.0,0,sqrt(2.0)/2.0)
            teoretical_uv_coordinates = newVec2d(0,0)
            hit_point = rotated_plane.ray_intersection(ray)
        
        assert hit_point.isSome
        assert hit_point.get().world_point.is_close( teoretical_hit_point )
        assert hit_point.get().normal.is_close( teoretical_norm )
        assert hit_point.get().t.almostEqual(1.0)
        assert hit_point.get().surface_point.is_close( teoretical_uv_coordinates )
    
    test "Have inside":
        var
            point1 = newPoint(0,0,1)
            point2 = newPoint(0,0,-1)

        assert xy_plane.have_inside(point2)
        assert not xy_plane.have_inside(point1)

    echo "Ended tests on Plane"

suite "Test Parallelepiped":

    echo "Started tests on Parallelepiped"
    
    setup:
        var
            cube = newParallelepiped()
        echo "New test started"

    teardown:
        echo "Test ended"

    test "Ray direction z":
        var 
            ray = newRay(newPoint(0.5,0.5,2.0),newVector(0,0,-1.0))
            teoretical_hit_point = newPoint(0.5,0.5,1.0)
            teoretical_normal = newNormal(0,0,1.0)
            teoretical_uv_coordinates = newVec2d(0.5,1/8)
            hit_point = cube.ray_intersection(ray)

        assert hit_point.isSome
        assert hit_point.get().world_point.is_close( teoretical_hit_point )
        assert hit_point.get().normal.is_close( teoretical_normal )
        assert hit_point.get().t.almostEqual(1.0)
        assert hit_point.get().surface_point.is_close( teoretical_uv_coordinates )

    test "Ray direction x":
        var 
            ray = newRay(newPoint(3.0,0.5,0.5),newVector(-1,0,0))
            teoretical_hit_point = newPoint(1.0,0.5,0.5)
            teoretical_normal = newNormal(1.0,0,0)
            teoretical_uv_coordinates = newVec2d(1/2,3/8)
            hit_point = cube.ray_intersection(ray)

        assert hit_point.isSome
        assert hit_point.get().world_point.is_close( teoretical_hit_point )
        assert hit_point.get().normal.is_close( teoretical_normal )
        assert hit_point.get().t.almostEqual(2.0)
        assert hit_point.get().surface_point.is_close( teoretical_uv_coordinates )

    test "Ray against edge":
        var 
            ray = newRay(newPoint(1.5,1.5,0.5),newVector(-sqrt(2.0),-sqrt(2.0),0))
            teoretical_hit_point = newPoint(1.0,1.0,0.5)
            hit_point = cube.ray_intersection(ray)

        assert hit_point.isSome
        assert hit_point.get().world_point.is_close( teoretical_hit_point )
        
    test "Ray inside the cube":
        var 
            ray = newRay(newPoint(0.5,0.5,0.5),newVector(1,0,0))
            teoretical_hit_point = newPoint(1.0,0.5,0.5)
            teoretical_normal = newNormal(-1.0,0,0)
            teoretical_uv_coordinates = newVec2d(1/2,3/8)
            hit_point = cube.ray_intersection(ray)

        assert hit_point.isSome
        assert hit_point.get().world_point.is_close( teoretical_hit_point )
        assert hit_point.get().normal.is_close( teoretical_normal )
        assert hit_point.get().t.almostEqual(0.5)
        assert hit_point.get().surface_point.is_close( teoretical_uv_coordinates )

    test "Traslated cube intersection":
        var
            tr_cube = newParallelepiped(transform = translation(newVector(10.0,0,0)))
            ray = newRay(newPoint(10.5,0.5,2.0),newVector(0,0,-1.0))
            teoretical_hit_point = newPoint(10.5,0.5,1.0)
            teoretical_normal = newNormal(0,0,1.0)
            teoretical_uv_coordinates = newVec2d(0.5,1/8)
            hit_point = tr_cube.ray_intersection(ray)
        
        assert hit_point.isSome
        assert hit_point.get().world_point.is_close( teoretical_hit_point )
        assert hit_point.get().normal.is_close( teoretical_normal )
        assert hit_point.get().t.almostEqual(1.0)
        assert hit_point.get().surface_point.is_close( teoretical_uv_coordinates )

    test "Not intersecting rays":
        var 
            ray_1 = newRay(newPoint(0,0,2),newVector(1,0,0))
            ray_2 = newRay(newPoint(-10,0,2),newVector(0,0,-1))
            hit_point_1 = cube.ray_intersection(ray_1)
            hit_point_2 = cube.ray_intersection(ray_2)

        assert hit_point_1.isNone
        assert hit_point_2.isNone

    test "All intersection":
        var
            ray = newRay(newPoint(-2,0.5,0.5),newVector(1.0,0,0))
            teoretical_hit_point1 = cube.newHitRecord( world_point = newPoint(0,0.5,0.5),
                                                  normal = newNormal(-1.0,0,0),
                                                  surface_point = newVec2d(1/2,7/8),
                                                  t = 2.0,
                                                  ray = ray
                                                )
            teoretical_hit_point2 = cube.newHitRecord( world_point = newPoint(1.0,0.5,0.5),
                                                  normal = newNormal(-1.0,0,0),
                                                  surface_point = newVec2d(1/2,3/8),
                                                  t = 3.0,
                                                  ray = ray
                                                )
            hit_points = cube.all_ray_intersections(ray)

        assert hit_points.isSome()
        assert len(hit_points.get()) == 2
        assert teoretical_hit_point1 in hit_points.get()
        assert teoretical_hit_point2 in hit_points.get()
    
    test "Have inside":
        var 
            point1 = newPoint(0.5,0.5,0.5)
            point2 = newPoint(-0.5,-0.5,-0.5)

        assert cube.have_inside(point1)
        assert not cube.have_inside(point2)

    echo "Ended tests on Parallelepiped"


suite "Test CSG":

    echo "Started tests on CSG"

    setup:
        var
            sphere1 = newSphere( translation(newVector(0.5,0,0)) )
            sphere2 = newSphere( translation(newVector(-0.5,0,0)))
            ray = newRay(newPoint(-2,0,0),newVector(1.0,0,0))
        
        echo "New test started"

    teardown:
        echo "Test ended"

    test "Union":
        var 
            union = unite(sphere1, sphere2)
            teoretical_hit_point = newPoint(-1.5,0,0)
            teoretical_norm = newNormal(-1,0,0)
            teoretical_uv_coordinates = newVec2d(0.5,0.5)
            hit_point = union.ray_intersection(ray)

        assert hit_point.isSome
        assert hit_point.get().world_point.is_close( teoretical_hit_point )
        assert hit_point.get().normal.is_close( teoretical_norm )
        assert hit_point.get().t.almostEqual(0.5)
        assert hit_point.get().surface_point.is_close( teoretical_uv_coordinates )

    test "All intersections for Union":
        var
            union = unite(sphere1, sphere2)
            teoretical_hit_point1 = sphere2.newHitRecord( world_point = newPoint(-1.5,0,0),
                                                  normal = newNormal(-1.0,0,0),
                                                  surface_point = newVec2d(0.5,0.5),
                                                  t = 0.5,
                                                  ray = ray
                                                )
            teoretical_hit_point2 = sphere1.newHitRecord( world_point = newPoint(1.5,0,0),
                                                  normal = newNormal(-1.0,0,0),
                                                  surface_point = newVec2d(0,0.5),
                                                  t = 3.5,
                                                  ray = ray
                                                )
            hit_points = union.all_ray_intersections(ray)


        assert hit_points.isSome()
        assert len(hit_points.get()) == 2
        assert teoretical_hit_point1 in hit_points.get()
        assert teoretical_hit_point2 in hit_points.get()
    
    test "Have inside for Union":
        var
            point1 = newPoint()
            point2 = newPoint(1,0,0)
            point3 = newPoint(-1,0,0)
            point4 = newpoint(0,0,2)
            union = unite(sphere1, sphere2)

        assert union.have_inside(point1)
        assert union.have_inside(point2)
        assert union.have_inside(point3)
        assert not union.have_inside(point4)
        

    test "Intersection":
        var 
            intersection = intersect(sphere1, sphere2)
            teoretical_hit_point = newPoint(-0.5,0,0)
            teoretical_norm = newNormal(-1,0,0)
            teoretical_uv_coordinates = newVec2d(0.5,0.5)
            hit_point = intersection.ray_intersection(ray)

        assert hit_point.isSome
        assert hit_point.get().world_point.is_close( teoretical_hit_point )
        assert hit_point.get().normal.is_close( teoretical_norm )
        assert hit_point.get().t.almostEqual(1.5)
        assert hit_point.get().surface_point.is_close( teoretical_uv_coordinates )

    test "All intersections for Intersection":
        var
            intersect = intersect(sphere1, sphere2)
            teoretical_hit_point1 = sphere1.newHitRecord( world_point = newPoint(-0.5,0,0),
                                                  normal = newNormal(-1.0,0,0),
                                                  surface_point = newVec2d(0.5,0.5),
                                                  t = 1.5,
                                                  ray = ray
                                                )
            teoretical_hit_point2 = sphere2.newHitRecord( world_point = newPoint(0.5,0,0),
                                                  normal = newNormal(-1.0,0,0),
                                                  surface_point = newVec2d(0,0.5),
                                                  t = 2.5,
                                                  ray = ray
                                                )
            hit_points = intersect.all_ray_intersections(ray)

        assert hit_points.isSome()
        assert len(hit_points.get()) == 2
        assert teoretical_hit_point1 in hit_points.get()
        assert teoretical_hit_point2 in hit_points.get()

    test "Have inside for Intersection":
        var
            point1 = newPoint()
            point2 = newPoint(1,0,0)
            point3 = newPoint(-1,0,0)
            intersection = intersect(sphere1, sphere2)

        assert intersection.have_inside(point1)
        assert not intersection.have_inside(point2)
        assert not intersection.have_inside(point3)

    test "Difference":
        var 
            difference = subtract(sphere1, sphere2)
            teoretical_hit_point = newPoint(0.5,0,0)
            teoretical_norm = newNormal(-1,0,0)
            teoretical_uv_coordinates = newVec2d(0,0.5)
            hit_point = difference.ray_intersection(ray)

        assert hit_point.isSome
        assert hit_point.get().world_point.is_close( teoretical_hit_point )
        assert hit_point.get().normal.is_close( teoretical_norm )
        assert hit_point.get().t.almostEqual(2.5)
        assert hit_point.get().surface_point.is_close( teoretical_uv_coordinates )

    test "All intersections for Difference":
        var
            difference = subtract(sphere1, sphere2)
            teoretical_hit_point1 = sphere2.newHitRecord( world_point = newPoint(0.5,0,0),
                                                  normal = newNormal(-1.0,0,0),
                                                  surface_point = newVec2d(0,0.5),
                                                  t = 2.5,
                                                  ray = ray
                                                )
            teoretical_hit_point2 = sphere1.newHitRecord( world_point = newPoint(1.5,0,0),
                                                  normal = newNormal(-1.0,0,0),
                                                  surface_point = newVec2d(0,0.5),
                                                  t = 3.5,
                                                  ray = ray
                                                )
            hit_points = difference.all_ray_intersections(ray)

        assert hit_points.isSome()
        assert len(hit_points.get()) == 2
        assert teoretical_hit_point1 in hit_points.get()
        assert teoretical_hit_point2 in hit_points.get()

    test "Have inside for Difference":
        var
            point1 = newPoint()
            point2 = newPoint(1,0,0)
            point3 = newPoint(-1,0,0)
            difference = subtract(sphere1, sphere2)

        assert not difference.have_inside(point1)
        assert difference.have_inside(point2)
        assert not difference.have_inside(point3)

    echo "Ended tests on CSG"
