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
    pmin*, pmax* : Point   #points that define the value of each dimension of the shape, along with its position in space

proc newParallelepiped*( transform = newTransformation(), p_min = newPoint(), p_max = newPoint(1.0, 1.0, 1.0) ) : Parallelepiped =
    ## Parallelepiped constructor, default is unitary cube defined from the origin
    new(result)
    result.transformation = transform
    result.pmin = p_min
    result.pmax = p_max
    return result

proc paral_normal*( point : Point, ray_dir : Vector ) : Normal =
    ## Return the normal to a point of the parallelepiped, depending on the ray direction
    result = newNormal(point.x, point.y, point.z)
    if result.dot(ray_dir) < 0.0: 
        return result
    else:
        return result.neg()


#DA CHIEDERE, ORA FACCIO VERSIONE FITTIZIA PER COMPILARE
proc paral_point_to_uv*( point: Point ) : Vec2d =
    newVec2d(0,0)

method ray_intersection*(paral : Parallelepiped, ray : Ray) : Option[HitRecord] =
    ## Compute all the intersection between a ray and a parallelepiped 
    var 
        inv_ray = ray.transform(paral.transformation.inverse())
        #intersections with the planes which form the parallelepiped
        tx1 = (paral.pmin.x - inv_ray.origin.x) / inv_ray.dir.x
        tx2 = (paral.pmax.x - inv_ray.origin.x) / inv_ray.dir.x
        txmin = min(tx1, tx2)
        txmax = max(tx1, tx2)
        ty1 = (paral.pmin.y - inv_ray.origin.y) / inv_ray.dir.y
        ty2 = (paral.pmax.y - inv_ray.origin.y) / inv_ray.dir.y
        tymin = min(ty1, ty2)
        tymax = max(ty1, ty2)
        tz1 = (paral.pmin.z - inv_ray.origin.z) / inv_ray.dir.z
        tz2 = (paral.pmax.z - inv_ray.origin.z) / inv_ray.dir.z
        tzmin = min(tz1, tz2)
        tzmax = max(tz1, tz2)
        th1, th2 : float
        hit_point : Point

    #First I look at x and y with z fixed, then I check on z
    if txmin < tymin :
        if txmax <= tymin :
            return none(HitRecord)
        else :
            if (tymin > inv_ray.tmin and tymin < inv_ray.tmax) and (inv_ray.at(tymin).z < paral.pmax.z and inv_ray.at(tymin).z > paral.pmin.z) :
                hit_point = inv_ray.at(tymin)   #I am sure this is the hit point nearest to the observer
                return some( newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                        surface_point = paral_point_to_uv(hit_point),
                        t = tymin,
                        ray = ray) )
            elif (txmax > inv_ray.tmin and txmax < inv_ray.tmax) and (inv_ray.at(txmax).z < paral.pmax.z and inv_ray.at(txmax).z > paral.pmin.z) :
                th1 = txmax
            else :
                return none(HitRecord)
    elif tymin < txmin :  #Works in the same way as the if indented like this elif
        if tymax <= txmin :
            return none(HitRecord)
        else : 
            if (txmin > inv_ray.tmin and txmin < inv_ray.tmax) and (inv_ray.at(txmin).z < paral.pmax.z and inv_ray.at(txmin).z > paral.pmin.z):
                hit_point = inv_ray.at(txmin)
                return some( newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                        surface_point = paral_point_to_uv(hit_point),
                        t = txmin,
                        ray = ray) )
            elif tymax > inv_ray.tmin and tymax < inv_ray.tmax and (inv_ray.at(tymax).z < paral.pmax.z and inv_ray.at(tymax).z > paral.pmin.z):
                th1 = tymax
            else :
                return none(HitRecord)

    #Now I fix y at first to look at x,z
    if txmin < tzmin :
        if (tzmin > inv_ray.tmin and tzmin < inv_ray.tmax) and (inv_ray.at(tzmin).y < paral.pmax.y and inv_ray.at(tzmin).y > paral.pmin.y) :
            th2 = min(th1, tzmin)
            hit_point = inv_ray.at(th2)
            return some( newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                        surface_point = paral_point_to_uv(hit_point),
                        t = th2,
                        ray = ray) )
        elif (txmax > inv_ray.tmin and txmax < inv_ray.tmax) and (inv_ray.at(txmax).y < paral.pmax.y and inv_ray.at(txmax).y > paral.pmin.y) :  #I have to chek also intersections with z to find the nearest hit point
            th2 = min(th1, txmax)
            hit_point = inv_ray.at(th2)
            return some( newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                        surface_point = paral_point_to_uv(hit_point),
                        t = th2,
                        ray = ray) )
    elif tzmin < txmin :  #Works in the same way as the last if indented like this elif
        if (txmin > inv_ray.tmin and txmin < inv_ray.tmax) and (inv_ray.at(txmin).y < paral.pmax.y and inv_ray.at(txmin).y > paral.pmin.y):
            th2 = min(th1, txmin)
            hit_point = inv_ray.at(th2)
            return some( newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                        surface_point = paral_point_to_uv(hit_point),
                        t = th2,
                        ray = ray) )
        elif (tzmax > inv_ray.tmin and tzmax < inv_ray.tmax)  and (inv_ray.at(tzmax).y < paral.pmax.y and inv_ray.at(tzmax).y > paral.pmin.y):
            th2 = min(th1, tzmax)
            hit_point = inv_ray.at(th2)
            return some( newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                        surface_point = paral_point_to_uv(hit_point),
                        t = th2,
                        ray = ray) )

    #Now I fix x at first to look at y,z
    if tymin < tzmin :
        if (tzmin > inv_ray.tmin and tzmin < inv_ray.tmax) and (inv_ray.at(tzmin).x < paral.pmax.x and inv_ray.at(tzmin).x > paral.pmin.x) :
            th2 = min(th1, tzmin)
            hit_point = inv_ray.at(th2)
            return some( newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                        surface_point = paral_point_to_uv(hit_point),
                        t = th2,
                        ray = ray) )
        elif (tymax > inv_ray.tmin and tymax < inv_ray.tmax) and (inv_ray.at(tymax).x < paral.pmax.x and inv_ray.at(tymax).x > paral.pmin.x) : 
            th2 = min(th1, tymax)
            hit_point = inv_ray.at(th2)
            return some( newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                        surface_point = paral_point_to_uv(hit_point),
                        t = th2,
                        ray = ray) )
    elif tzmin < tymin :  #Works in the same way as the last if indented like this elif
        if (tymin > inv_ray.tmin and tymin < inv_ray.tmax) and (inv_ray.at(tymin).x < paral.pmax.x and inv_ray.at(tymin).x > paral.pmin.x):
            th2 = min(th1, tymin)
            hit_point = inv_ray.at(th2)
            return some( newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                        surface_point = paral_point_to_uv(hit_point),
                        t = th2,
                        ray = ray) )
        elif (tzmax > inv_ray.tmin and tzmax < inv_ray.tmax)  and (inv_ray.at(tzmax).x < paral.pmax.x and inv_ray.at(tzmax).x > paral.pmin.x):
            th2 = min(th1, tzmax)
            hit_point = inv_ray.at(th2)
            return some( newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                        surface_point = paral_point_to_uv(hit_point),
                        t = th2,
                        ray = ray) )
    return none(HitRecord)

method all_ray_intersections*(paral : Parallelepiped, ray : Ray) : Option[seq[HitRecord]] =
    ## Compute the nearest intersection between a ray and a parallelepiped form the observer's pov
    var 
        inv_ray = ray.transform(paral.transformation.inverse())
        #intersections with the planes which form the parallelepiped
        tx1 = (paral.pmin.x - inv_ray.origin.x) / inv_ray.dir.x
        tx2 = (paral.pmax.x - inv_ray.origin.x) / inv_ray.dir.x
        txmin = min(tx1, tx2)
        txmax = max(tx1, tx2)
        ty1 = (paral.pmin.y - inv_ray.origin.y) / inv_ray.dir.y
        ty2 = (paral.pmax.y - inv_ray.origin.y) / inv_ray.dir.y
        tymin = min(ty1, ty2)
        tymax = max(ty1, ty2)
        tz1 = (paral.pmin.z - inv_ray.origin.z) / inv_ray.dir.z
        tz2 = (paral.pmax.z - inv_ray.origin.z) / inv_ray.dir.z
        tzmin = min(tz1, tz2)
        tzmax = max(tz1, tz2)
        hit_point : Point
        hits : seq[HitRecord]

    hits = @[]

    #First I look at x and y with z fixed, then I check on z
    if txmin < tymin :
        if txmax <= tymin :
            return none(seq[HitRecord])
        else :
            if (tymin > inv_ray.tmin and tymin < inv_ray.tmax) and (inv_ray.at(tymin).z < paral.pmax.z and inv_ray.at(tymin).z > paral.pmin.z) :
                hit_point = inv_ray.at(tymin)
                hits.add( newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                        surface_point = paral_point_to_uv(hit_point),
                        t = tymin,
                        ray = ray) )
            if (txmax > inv_ray.tmin and txmax < inv_ray.tmax) and (inv_ray.at(txmax).z < paral.pmax.z and inv_ray.at(txmax).z > paral.pmin.z) :
                hit_point = inv_ray.at(txmax)
                hits.add( newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                        surface_point = paral_point_to_uv(hit_point),
                        t = txmax,
                        ray = ray) )
            else :
                return none(seq[HitRecord])
    elif tymin < txmin :  #Works in the same way as the if indented like this elif
        if tymax <= txmin :
            return none(seq[HitRecord])
        else : 
            if (txmin > inv_ray.tmin and txmin < inv_ray.tmax) and (inv_ray.at(txmin).z < paral.pmax.z and inv_ray.at(txmin).z > paral.pmin.z):
                hit_point = inv_ray.at(txmin)
                hits.add( newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                        surface_point = paral_point_to_uv(hit_point),
                        t = txmin,
                        ray = ray) )
            elif tymax > inv_ray.tmin and tymax < inv_ray.tmax and (inv_ray.at(tymax).z < paral.pmax.z and inv_ray.at(tymax).z > paral.pmin.z):
                hit_point = inv_ray.at(tymax)
                hits.add( newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                        surface_point = paral_point_to_uv(hit_point),
                        t = tymax,
                        ray = ray) )
            else :
                return none(seq[HitRecord])

    #Now I fix y at first to look at x,z
    if txmin < tzmin :
        if (tzmin > inv_ray.tmin and tzmin < inv_ray.tmax) and (inv_ray.at(tzmin).y < paral.pmax.y and inv_ray.at(tzmin).y > paral.pmin.y) :
            hit_point = inv_ray.at(tzmin)
            hits.add( newHitRecord(world_point = paral.transformation * hit_point , 
                    normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                    surface_point = paral_point_to_uv(hit_point),
                    t = tzmin,
                    ray = ray) )
        if (txmax > inv_ray.tmin and txmax < inv_ray.tmax) and (inv_ray.at(txmax).y < paral.pmax.y and inv_ray.at(txmax).y > paral.pmin.y) :  #I have to chek also intersections with z to find the nearest hit point
            hit_point = inv_ray.at(txmax)
            hits.add( newHitRecord(world_point = paral.transformation * hit_point , 
                    normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                    surface_point = paral_point_to_uv(hit_point),
                    t = txmax,
                    ray = ray) )
    elif tzmin < txmin :  #Works in the same way as the last if indented like this elif
        if (txmin > inv_ray.tmin and txmin < inv_ray.tmax) and (inv_ray.at(txmin).y < paral.pmax.y and inv_ray.at(txmin).y > paral.pmin.y):
            hit_point = inv_ray.at(txmin)
            hits.add( newHitRecord(world_point = paral.transformation * hit_point , 
                    normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                    surface_point = paral_point_to_uv(hit_point),
                    t = txmin,
                    ray = ray) )
        elif (tzmax > inv_ray.tmin and tzmax < inv_ray.tmax)  and (inv_ray.at(tzmax).y < paral.pmax.y and inv_ray.at(tzmax).y > paral.pmin.y):
            hit_point = inv_ray.at(tzmax)
            hits.add( newHitRecord(world_point = paral.transformation * hit_point , 
                    normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                    surface_point = paral_point_to_uv(hit_point),
                    t = tzmax,
                    ray = ray) )

    #Now I fix x at first to look at y,z
    if tymin < tzmin :
        if (tzmin > inv_ray.tmin and tzmin < inv_ray.tmax) and (inv_ray.at(tzmin).x < paral.pmax.x and inv_ray.at(tzmin).x > paral.pmin.x) :
            hit_point = inv_ray.at(tzmin)
            hits.add( newHitRecord(world_point = paral.transformation * hit_point , 
                    normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                    surface_point = paral_point_to_uv(hit_point),
                    t = tzmin,
                    ray = ray) )
        elif (tymax > inv_ray.tmin and tymax < inv_ray.tmax) and (inv_ray.at(tymax).x < paral.pmax.x and inv_ray.at(tymax).x > paral.pmin.x) : 
            hit_point = inv_ray.at(tymax)
            hits.add( newHitRecord(world_point = paral.transformation * hit_point , 
                    normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                    surface_point = paral_point_to_uv(hit_point),
                    t = tymax,
                    ray = ray) )
    elif tzmin < tymin :  #Works in the same way as the last if indented like this elif
        if (tymin > inv_ray.tmin and tymin < inv_ray.tmax) and (inv_ray.at(tymin).x < paral.pmax.x and inv_ray.at(tymin).x > paral.pmin.x):
            hit_point = inv_ray.at(tymin)
            hits.add( newHitRecord(world_point = paral.transformation * hit_point , 
                    normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                    surface_point = paral_point_to_uv(hit_point),
                    t = tymin,
                    ray = ray) )
        elif (tzmax > inv_ray.tmin and tzmax < inv_ray.tmax)  and (inv_ray.at(tzmax).x < paral.pmax.x and inv_ray.at(tzmax).x > paral.pmin.x):
            hit_point = inv_ray.at(tzmax)
            hits.add( newHitRecord(world_point = paral.transformation * hit_point , 
                    normal = paral.transformation * paral_normal( hit_point, inv_ray.dir ),
                    surface_point = paral_point_to_uv(hit_point),
                    t = tzmax,
                    ray = ray) )
    
    return some(hits)

method have_inside*(paral : Parallelepiped, point : Point ) : bool =
    ## Check if a point is inside a parallelepiped (works the same as the sphere version)
    var inv_point = point_to_vec(paral.transformation.inverse() * point )

    if inv_point.squared_norm() < 1:
        return true
    else:
        return false
