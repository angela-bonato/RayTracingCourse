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

type Shape* = object of RootObj

# Sphere declaration and procs

type Sphere* = object of Shape  # It represent a unitary sphere centered in the origin, the proper position of the object is represented by the transformation 
    transformation* : Transformation

proc NewSphere*( transform = newTransformation() ) : Sphere =
    ## Sphere constructor
    result.transformation = transform
    return result

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

proc ray_intersection*( sphere: Sphere, ray : Ray) : Option[HitRecord] =
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

# Plane declaration and procs

type Plane* = object of Shape
    transformation* : Transformation

proc newPlane*( transform = newTransformation() ) : Plane =
    ## Plane constructor
    result.transformation = transform
    return result

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

proc ray_intersection*( plane: Plane, ray : Ray) : Option[HitRecord] =
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