## Implementation of different Shapes that our code can render. Implement also some useful types to perform the rendering.

import transformation
import point
import vector
import normal
import geometryalgebra
import ray
import math
import options

# Vec2d type declaration

type Vec2d* = object # It represent a point in the shape independant u,v coordinates
    u* : float
    v* : float

proc newVec2d*(u = 0.0,v = 0.0) : Vec2d =
    ## Constructor for Vec2d
    result.u = u
    result.v = v
    return result

proc is_close*( vec1, vec2 : Vec2d ) : bool =
    ## is_close method for Vec2d
    return (vec1.u.almostEqual(vec2.u) and
            vec1.v.almostEqual(vec2.v) )
    
proc print*( vec : Vec2d ) : void =
    ## print method for Vec2d
    echo "Vec2d( u=", vec.u, ", v=", vec.v, " )"

# HitRecord type declaration and costructor

type HitRecord* = object    # Record of all the values about the hit of the ray
    world_point* : Point
    normal* : Normal
    surface_point* : Vec2d
    t* : float
    ray* : Ray

proc newHitRecord*( world_point : Point, normal : Normal, surface_point : Vec2d, t : float, ray : Ray ) : HitRecord =
    ## Constructor for HitRecord
    result.world_point = world_point
    result.normal = normal
    result.surface_point = surface_point
    result.t = t
    result.ray = ray 
    return result

proc is_close*(hit1, hit2: HitRecord) : bool =
    ## Usefull to compare two HitRecords in tests
    return is_close(hit1.world_point, hit2.world_point) and 
            is_close(hit1.normal, hit2.normal) and 
            is_close(hit1.surface_point, hit2.surface_point) and 
            almostEqual(hit1.t, hit2.t) and 
            is_close(hit1.ray, hit2.ray)

# Shape type declaration

type Shape* = ref object of RootObj

method ray_intersection*(shape : Shape, ray : Ray) : Option[HitRecord] {.base.} =
    ## Virtual ray_intersection method
    quit "To override"

method all_ray_intersections*(shape : Shape, ray : Ray) : Option[seq[HitRecord]] {.base.} =
    ## Virtual all_ray_intersections method
    quit "To override"

method have_inside*( shape : Shape, point : Point) : bool {.base.} =
    ## Check if a point is inside a shape
    quit "To override"

# Sphere declaration and procs

type Sphere* = ref object of Shape  
    ## It represents a unitary sphere centered in the origin, the proper position of the object is represented by the transformation 
    transformation* : Transformation

proc newSphere*( transform = newTransformation() ) : Shape =
    ## Sphere constructor
    let sphere = new Sphere
    sphere.transformation = transform
    return Shape(sphere)

proc sphere_normal*( point : Point, ray_dir : Vector ) : Normal =
    ## Return the normal to a point of the sphere, depending on the ray direction
    result = newNormal(point.x, point.y, point.z)
    if result.dot(ray_dir) < 0.0: 
        return result
    else:
        return result.neg()

proc sphere_point_to_uv*( point: Point ) : Vec2d =
    ## Return the point of the sphere in the shape independant u,v coordinates
    var 
        u = arctan2(point.y, point.x) / (2.0 * PI) 
        v = arccos(point.z) / PI
    if u >= 0.0: 
        return newVec2d(u,v)
    else:
        return newVec2d(u+1.0,v)

method ray_intersection*( sphere: Sphere, ray : Ray) : Option[HitRecord] =
    ## Compute the intersection between a ray and a sphere
    var 
        inv_ray = ray.transform(sphere.transformation.inverse())
        reduced_delta =  (inv_ray.dir.dot( inv_ray.origin.point_to_vec() ))^2 - inv_ray.dir.squared_norm() * ( inv_ray.origin.point_to_vec.squared_norm() - 1.0 ) 
        t_1 = (-inv_ray.dir.dot( inv_ray.origin.point_to_vec() ) - sqrt( reduced_delta )) / inv_ray.dir.squared_norm()  # compute the two intersection with the sphere
        t_2 = (-inv_ray.dir.dot( inv_ray.origin.point_to_vec() ) + sqrt( reduced_delta )) / inv_ray.dir.squared_norm()
        first_hit : float

    if t_1 > inv_ray.tmin and t_1 < inv_ray.tmax :
        first_hit = t_1
    elif t_2 > inv_ray.tmin and t_2 < inv_ray.tmax :
        first_hit = t_2
    else:
        return none(HitRecord) # the ray missed the sphere

    var hit_point = inv_ray.at(first_hit)

    return some( newHitRecord( world_point = sphere.transformation * hit_point , 
                               normal = sphere.transformation * sphere_normal( hit_point, inv_ray.dir ),
                               surface_point = sphere_point_to_uv(hit_point),
                               t = first_hit,
                               ray = ray    
                               ) )

method all_ray_intersections*( sphere : Sphere, ray : Ray) : Option[seq[HitRecord]] =
    ## Compute all the intersections between a ray and a sphere
    var 
        inv_ray = ray.transform(sphere.transformation.inverse())
        reduced_delta =  (inv_ray.dir.dot( inv_ray.origin.point_to_vec() ))^2 - inv_ray.dir.squared_norm() * ( inv_ray.origin.point_to_vec.squared_norm() - 1.0 ) 
        t_1 = (-inv_ray.dir.dot( inv_ray.origin.point_to_vec() ) - sqrt( reduced_delta )) / inv_ray.dir.squared_norm()  # compute the two intersection with the sphere
        t_2 = (-inv_ray.dir.dot( inv_ray.origin.point_to_vec() ) + sqrt( reduced_delta )) / inv_ray.dir.squared_norm()
        hits : seq[HitRecord]

    hits = @[]

    if (t_1 < inv_ray.tmin or t_1 > inv_ray.tmax) and (t_2 < inv_ray.tmin or t_2 > inv_ray.tmax) :
        return none(seq[HitRecord])
    
    if t_1 > inv_ray.tmin and t_1 < inv_ray.tmax :
        var hit_point = inv_ray.at(t_1)
        hits.add( newHitRecord( world_point = sphere.transformation * hit_point , 
                               normal = sphere.transformation * sphere_normal( hit_point, inv_ray.dir ),
                               surface_point = sphere_point_to_uv(hit_point),
                               t = t_1,
                               ray = ray    
                               ) )

    if t_2 > inv_ray.tmin and t_2 < inv_ray.tmax :
        var hit_point = inv_ray.at(t_2)
        hits.add( newHitRecord( world_point = sphere.transformation * hit_point , 
                               normal = sphere.transformation * sphere_normal( hit_point, inv_ray.dir ),
                               surface_point = sphere_point_to_uv(hit_point),
                               t = t_2,
                               ray = ray    
                               ) )
    
    return some(hits)

method have_inside*( sphere : Sphere, point : Point ) : bool =
    ## Check if a point is inside a sphere
    var inv_point = point_to_vec( sphere.transformation.inverse() * point )

    if inv_point.squared_norm() < 1:
        return true
    else:
        return false

# Plane declaration and procs

type Plane* = ref object of Shape
    ## It defines an infinite plane in space
    transformation* : Transformation

proc newPlane*( transform = newTransformation() ) : Shape =
    ## Plane constructor
    let plane = new Plane
    plane.transformation = transform
    return Shape(plane)

proc plane_normal*(ray_dir : Vector) : Normal =
    ## Return the normal to a point of the plane, depending on the ray direction
    result = newNormal(0,0,1)
    if result.dot(ray_dir) < 0.0: 
        return result
    else:
        return result.neg()

proc plane_point_to_uv*( point: Point ) : Vec2d =
    ## Return the point of the sphere in the shape independant u,v coordinates
    var 
        u = point.x - floor(point.x)
        v = point.y - floor(point.y)
    return newVec2d(u,v)

method ray_intersection*( plane: Plane, ray : Ray) : Option[HitRecord] =
    ## Compute the intersection between a ray and a plane
    var inv_ray = ray.transform(plane.transformation.inverse())
    if inv_ray.dir.z == 0: return none(HitRecord) # the ray missed the plane

    var t_hit = - inv_ray.origin.z / inv_ray.dir.z
    
    if t_hit < ray.tmin or t_hit > ray.tmax : return none(HitRecord) # the intersection is out of the ray boundaries

    var hit_point = inv_ray.at(t_hit)

    return some( newHitRecord( world_point = plane.transformation * hit_point , 
                               normal = plane.transformation * plane_normal( inv_ray.dir ),
                               surface_point = plane_point_to_uv(hit_point),
                               t = t_hit,
                               ray = ray    
                               ) )

method all_ray_intersections*(plane : Plane, ray : Ray) : Option[seq[HitRecord]] =
    ## Compute all the intersections between a ray and a plane
    var 
        inv_ray = ray.transform(plane.transformation.inverse())
        hits : seq[HitRecord]
    
    hits = @[]

    if inv_ray.dir.z == 0: return none(seq[HitRecord]) # the ray missed the plane

    var t_hit = - inv_ray.origin.z / inv_ray.dir.z
    
    if t_hit < ray.tmin or t_hit > ray.tmax : return none(seq[HitRecord]) # the intersection is out of the ray boundaries

    var hit_point = inv_ray.at(t_hit)

    hits.add( newHitRecord( world_point = plane.transformation * hit_point , 
                               normal = plane.transformation * plane_normal( inv_ray.dir ),
                               surface_point = plane_point_to_uv(hit_point),
                               t = t_hit,
                               ray = ray    
                               ) )
    
    return some(hits)

method have_inside*( plane : Plane, point : Point) : bool =
    ## Check if a point is inside a plane -> mean that the point z is negative
    var inv_point = plane.transformation.inverse() * point

    if inv_point.z < 0 :
        return true
    else: 
        return false


# Parallelepipeid declaration and procs

type Parallelepiped* = ref object of Shape  
    ## It defines an axis-aligned box
    transformation* : Transformation
    p_min*, p_max* : Point   #points that define the value of each dimension of the shape, along with its position in space

proc newParallelepiped*( transform = newTransformation(), p_m = newPoint(), p_M = newPoint(1, 1, 1) ) : Parallelepiped =
    ## Parallelepiped constructor, default is unitary cube defined from the origin
    new(result)
    result.transformation = transform
    result.p_min = p.m
    result.p_max = p.M
    return result

#to Angela: finish procs of parallelepiped looking at sphere, then define difference in CSG file

