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

# HitRecord type declaration and costructor

type HitRecord* = object    # Record of all the values about the hit of the ray
    world_point* : Point
    normal* : Normal
    surface_point* : Vec2d
    t* : float
    ray* = Ray

proc newHitRecord*( world_point : Point, normal : Normal, surface_point : Vec2d, t : float, ray : Ray ) : void =
    ## Constructor for HitRecord
    result.world_point = world_point
    result.normal = normal
    result.surface_point = surface_point
    result.t = t
    result.ray = ray 
    return result

# Shape type declaration

type Shape* = object 

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
        u = arctan2(point.y, point.x) / (2.0 * pi)
        v=acos(point.z) / pi
    if u >= 0.0: 
        return newVec2d(u,v)
    else:
        return newVec2d(u+1.0,v)

proc ray_intersection( sphere: Sphere, ray : Ray) : Option[HitRecord] =
    ## Compute the intersection between a ray and a sphere
    var 
        inv_ray = ray.transform(sphere.transformation)
        reduced_delta =  (inv_ray.direction.dot( inv_ray.origin.point_to_vec() ))^2 - inv_ray.dir.squared_norm() * ( inv_ray.origin.point_to_vec.squared_norm() - 1.0 )
        t_1 = (-inv_ray.direction.dot( inv_ray.origin.point_to_vec() ) - sqrt( reduced_delta / 4.0 ))/ inv_ray.dir.squared_norm()
        t_2 = (-inv_ray.direction.dot( inv_ray.origin.point_to_vec() ) + sqrt( reduced_delta / 4.0 ))/ inv_ray.dir.squared_norm()
        firts_hit : float

    if t_1 > inv_ray.tmin and t_1 < inv_ray.tmax :
        first hit = t_1
    elif t_2 > inv_ray.tmin and t_2 < inv_ray.tmax :
        firts_hit = t_2
    else:
        return nil # the ray missed the sphere

    var hit_point = inv_ray.at(firts_hit)

    return newHitRecord( world_point = sphere.transformation * hit_point , 
                         normal = sphere.transformation * sphere_normal( hit_point, ray.dir ),
                         surface_point = sphere_point_to_uv(hit_point),
                         t = firts_hit,
                         ray = ray    
                        )


