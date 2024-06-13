## Implementation of different Shapes that our code can render. Implement also some useful types to perform the rendering.

import transformation
import point
import vector
import normal
import geometryalgebra
import ray
import materials
import std/math
import std/options
import std/algorithm

# Shape type declaration

type Shape* = ref object of RootObj
    transformation* : Transformation
    material* : Material

# HitRecord type declaration and costructor

type HitRecord* = object    # Record of all the values about the hit of the ray
    shape* : Shape
    world_point* : Point
    normal* : Normal
    surface_point* : Vec2d
    t* : float
    ray* : Ray

proc newHitRecord*(shape : Shape, world_point : Point, normal : Normal, surface_point : Vec2d, t : float, ray : Ray ) : HitRecord =
    ## Constructor for HitRecord
    result.shape = shape
    result.world_point = world_point
    result.normal = normal
    result.surface_point = surface_point
    result.t = t
    result.ray = ray 
    return result

proc is_close*(hit1, hit2: HitRecord) : bool =
    ## Usefull to compare two HitRecords in tests, it does not checks on the shape member
    return is_close(hit1.world_point, hit2.world_point) and 
            is_close(hit1.normal, hit2.normal) and 
            is_close(hit1.surface_point, hit2.surface_point) and 
            almostEqual(hit1.t, hit2.t) and 
            is_close(hit1.ray, hit2.ray)

#Virtual Shape method declarations

method shape_normal*(shape : Shape, point : Point, ray_dir : Vector) : Normal {.base.} =
    ## Virtual ray_intersection method
    quit "Called shape_normal of Shape, it is a virtual method!"

method point_to_uv*(shape : Shape, point : Point) : Vec2d {.base.} =
    ## Virtual ray_intersection method
    quit "Called point_to_uv of Shape, it is a virtual method!"

method ray_intersection*(shape : Shape, ray : Ray) : Option[HitRecord] {.base.} =
    ## Virtual ray_intersection method
    quit "Called ray_intersection of Shape, it is a virtual method!"

method all_ray_intersections*(shape : Shape, ray : Ray) : Option[seq[HitRecord]] {.base.} =
    ## Virtual all_ray_intersections method
    quit "Called all_ray_intersections of Shape, it is a virtual method!"

method have_inside*( shape : Shape, point : Point) : bool {.base.} =
    ## Check if a point is inside a shape
    quit "Called have_inside of Shape, it is a virtual method!"

# Sphere declaration and procs

type Sphere* = ref object of Shape  
    ## It represents a unitary sphere centered in the origin, the proper position of the object is represented by the transformation 
    # Transformation
    # Material

proc newSphere*( transform = newTransformation(), material = newMaterial() ) : Shape =
    ## Sphere constructor
    let sphere = new Sphere
    sphere.transformation = transform
    sphere.material = material
    return Shape(sphere)

method shape_normal*(sphere: Sphere, point : Point, ray_dir : Vector ) : Normal =
    ## Return the normal to a point of the sphere, depending on the ray direction
    result = newNormal(point.x, point.y, point.z)
    if result.dot(ray_dir) < 0.0: 
        return result
    else:
        return result.neg()

method point_to_uv*(sphere: Sphere, point: Point ) : Vec2d =
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

    return some( sphere.newHitRecord( world_point = sphere.transformation * hit_point , 
                               normal = sphere.transformation * sphere.shape_normal( hit_point, inv_ray.dir ),
                               surface_point = sphere.point_to_uv(hit_point),
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
        hits.add(sphere.newHitRecord( world_point = sphere.transformation * hit_point , 
                               normal = sphere.transformation * sphere.shape_normal( hit_point, inv_ray.dir ),
                               surface_point = sphere.point_to_uv(hit_point),
                               t = t_1,
                               ray = ray    
                               ) )

    if t_2 > inv_ray.tmin and t_2 < inv_ray.tmax :
        var hit_point = inv_ray.at(t_2)
        hits.add(sphere.newHitRecord( world_point = sphere.transformation * hit_point , 
                               normal = sphere.transformation * sphere.shape_normal( hit_point, inv_ray.dir ),
                               surface_point = sphere.point_to_uv(hit_point),
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
    # Transformation
    # Material

proc newPlane*( transform = newTransformation(), material = newMaterial() ) : Shape =
    ## Plane constructor
    let plane = new Plane
    plane.transformation = transform
    plane.material = material
    return Shape(plane)

method shape_normal*(plane: Plane, point: Point, ray_dir : Vector) : Normal =
    ## Return the normal to a point of the plane, depending on the ray direction
    result = newNormal(0,0,1)
    if result.dot(ray_dir) < 0.0: 
        return result
    else:
        return result.neg()

method point_to_uv*(plane: Plane, point: Point ) : Vec2d =
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

    return some(plane.newHitRecord( world_point = plane.transformation * hit_point , 
                               normal = plane.transformation * plane.shape_normal(hit_point, inv_ray.dir ),
                               surface_point = plane.point_to_uv(hit_point),
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

    hits.add(plane.newHitRecord( world_point = plane.transformation * hit_point , 
                               normal = plane.transformation * plane.shape_normal(hit_point, inv_ray.dir ),
                               surface_point = plane.point_to_uv(hit_point),
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

proc is_close(a,b: float) : bool =
    ## alternative function to almostEqual. I define this to avoid small rounding errors
    if abs(a-b)<1e-5 : return true
    else : return false

type Parallelepiped* = ref object of Shape  
    ## It defines an axis-aligned box
    # Transformation
    # Material
    pmin*, pmax* : Point   #points that define the value of each dimension of the shape, along with its position in space

proc newParallelepiped*( transform = newTransformation(), p_max = newPoint(1.0, 1.0, 1.0), material = newMaterial() ) : Shape =
    ## Parallelepiped constructor, default is unitary cube defined from the origin, to change the default you can change pmax but as long as it is ppositive
    
    let paral = new Parallelepiped
    paral.transformation = transform
    paral.pmin = newPoint()
    paral.material = material
    
    if p_max.x < 0.0 or p_max.y < 0.0 or p_max.z < 0.0 :
        echo "Invalid p_max argument in newParallelepiped(): a negative p_max it is not allowed, you have to define it positive and then use transform on it. The default constructor will be called now."
        paral.pmax = newPoint(1.0, 1.0, 1.0)
    else:
        paral.pmax = p_max
    
    return Shape(paral)

method shape_normal*(paral : Parallelepiped, point : Point, ray_dir : Vector ) : Normal =
    ## Return the normal to a point of the parallelepiped (based on the face on which it lies), depending on the ray direction
    #Now I define the normal pointing out from the parallelepiped but if nedeed it is fixed below
    if point.z.is_close(paral.pmax.z) :
        result = newNormal(0.0, 0.0, 1.0)
    if point.x.is_close(paral.pmax.x) :
        result = newNormal(1.0, 0.0, 0.0)
    if point.y.is_close(paral.pmax.y) :
        result = newNormal(0.0, 1.0, 0.0)
    if point.y.is_close(0.0) :
        result = newNormal(0.0, -1.0, 0.0)
    if point.z.is_close(0.0) :
        result = newNormal(0.0, 0.0, -1.0)
    if point.x.is_close(0.0) :
        result = newNormal(-1.0, 0.0, 0.0)
    
    if result.dot(ray_dir) < 0.0: 
        return result
    else:
        return result.neg()

method point_to_uv*(paral : Parallelepiped, point: Point ) : Vec2d =
    ## Maps the parallelepiped into a 2D plane with coordinates u,v in [0, 1]
    ## 
    ##      ___________________ _v=0
    ##     |     |      |      |                          ______
    ##     |  // |   5  |  //  |                        /  5   /| 
    ##     |_____|______|______|                       /______/ |-->3
    ##     |     |      |      |                       |      |4|
    ##     |  2  |   6  |   4  |                   2<--|  6   | /
    ##     |_____|______|______|            z|         |______|/
    ##     |     |      |      |             |             |
    ##     |  // |   1  |   // |             |----- y      v
    ##     |_____|______|______|            /              1
    ##     |     |      |      |           /x 
    ##     |  // |   3  |   // |         
    ##     |_____|______|______|_v=1  
    ##     |                   |
    ##     u=0                 u=1
    ## 
    # point is in the ref syst of the shape, the idea here is to associate each face of the parallelepiped to a specific region of the (u,v) plane
    var
        u, v : float #these are the output coordinates
        # normalization constants to define u,v in [0,1]. Thanks to the way newParallelepiped is defined, paral.pmax.x,y,z are the lengths of the three dimensions of the parallelepiped
        normalu = 2.0*paral.pmax.x + paral.pmax.y  
        normalv = 2.0*(paral.pmax.x + paral.pmax.z)
    # I have to understand in which face of the parallelepiped the point is placed and then map it in the correspondent part of the (u,v) plane
    if point.z.is_close(paral.pmax.z) :  #face number 5
        u = (paral.pmax.x + point.y)/normalu
        v = point.x/normalv
    if point.y.is_close(0.0) :  #face number 2
        u = point.x/normalu
        v = (paral.pmax.x + (paral.pmax.z - point.z))/normalv
    if point.x.is_close(paral.pmax.x) :  #face number 6
        u = (paral.pmax.x + point.y)/normalu
        v = (paral.pmax.x + (paral.pmax.z - point.z))/normalv
    if point.y.is_close(paral.pmax.y) :  #face number 4
        u = (paral.pmax.x + paral.pmax.y + (paral.pmax.x - point.x))/normalu
        v = (paral.pmax.x + (paral.pmax.z - point.z))/normalv
    if point.z.is_close(0.0) :  #face number 1
        u = (paral.pmax.x + point.y)/normalu
        v = (paral.pmax.x + paral.pmax.z + (paral.pmax.x - point.x))/normalv
    if point.x.is_close(0.0) :  #face number 3
        u = (paral.pmax.x + point.y)/normalu
        v = (2.0*paral.pmax.x + paral.pmax.z + point.z)/normalv
    
    return newVec2d(u,v)

proc min_close*(a,b: float32) : bool =
    ## to use <= with float avoiding rounding errors
    if a < b or is_close(a, b) : return true
    else : return false

func max_close*(a,b: float32) : bool =
    ## to use >= with float avoiding rounding errors
    if a > b or is_close(a, b) : return true
    else : return false

method ray_intersection*(paral : Parallelepiped, ray : Ray) : Option[HitRecord] =
    ## Compute all the intersection between a ray and a parallelepiped 
    var 
        inv_ray = ray.transform(paral.transformation.inverse())
        #intersections with the planes which form the parallelepiped
        txmin = (paral.pmin.x - inv_ray.origin.x) / inv_ray.dir.x
        txmax = (paral.pmax.x - inv_ray.origin.x) / inv_ray.dir.x
        tymin = (paral.pmin.y - inv_ray.origin.y) / inv_ray.dir.y
        tymax = (paral.pmax.y - inv_ray.origin.y) / inv_ray.dir.y
        tzmin = (paral.pmin.z - inv_ray.origin.z) / inv_ray.dir.z
        tzmax = (paral.pmax.z - inv_ray.origin.z) / inv_ray.dir.z
        ts : seq[float]
        hit_point : Point

    ts = @[]

    if txmin > txmax : swap(txmin, txmax)
    if tymin > tymax : swap(tymin, tymax)
    if tzmin > tzmax : swap(tzmin, tzmax)

    #I separatelly check if the ray is parallel to a face of the parallelepiped
    if inv_ray.dir.x.is_close(0.0) and inv_ray.dir.y.is_close(0.0) :
        #Ray parallel to z
        if (inv_ray.origin.x.max_close(paral.pmin.x) and inv_ray.origin.x.min_close(paral.pmax.x)) and (inv_ray.origin.y.max_close(paral.pmin.y) and inv_ray.origin.y.min_close(paral.pmax.y)):
            if (tzmin > inv_ray.tmin and tzmin < inv_ray.tmax) and (inv_ray.at(tzmin).x.min_close(paral.pmax.x) and inv_ray.at(tzmin).x.max_close(paral.pmin.x)) and (inv_ray.at(tzmin).y.min_close(paral.pmax.y) and inv_ray.at(tzmin).y.max_close(paral.pmin.y)) and (inv_ray.at(tzmin).z.min_close(paral.pmax.z) and inv_ray.at(tzmin).z.max_close(paral.pmin.z)):
                hit_point = inv_ray.at(tzmin)
                return some(paral.newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral.shape_normal( hit_point, inv_ray.dir ),
                        surface_point = paral.point_to_uv(hit_point),
                        t = tzmin,
                        ray = ray) )
            elif (tzmax > inv_ray.tmin and tzmax < inv_ray.tmax) and (inv_ray.at(tzmax).x.min_close(paral.pmax.x) and inv_ray.at(tzmax).x.max_close(paral.pmin.x)) and (inv_ray.at(tzmax).y.min_close(paral.pmax.y) and inv_ray.at(tzmax).y.max_close(paral.pmin.y)) and (inv_ray.at(tzmax).z.min_close(paral.pmax.z) and inv_ray.at(tzmax).z.max_close(paral.pmin.z)):
                hit_point = inv_ray.at(tzmax)
                return some(paral.newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral.shape_normal( hit_point, inv_ray.dir ),
                        surface_point = paral.point_to_uv(hit_point),
                        t = tzmax,
                        ray = ray) )
            else :
                return none(HitRecord)

    if inv_ray.dir.z.is_close(0.0) and inv_ray.dir.y.is_close(0.0) :
        #Ray parallel to x
        if (inv_ray.origin.y.max_close(paral.pmin.y) and inv_ray.origin.y.min_close(paral.pmax.y)) and (inv_ray.origin.z.max_close(paral.pmin.z) and inv_ray.origin.z.min_close(paral.pmax.z)) :
            if (txmin > inv_ray.tmin and txmin < inv_ray.tmax) and (inv_ray.at(txmin).x.min_close(paral.pmax.x) and inv_ray.at(txmin).x.max_close(paral.pmin.x)) and (inv_ray.at(txmin).y.min_close(paral.pmax.y) and inv_ray.at(txmin).y.max_close(paral.pmin.y)) and (inv_ray.at(txmin).z.min_close(paral.pmax.z) and inv_ray.at(txmin).z.max_close(paral.pmin.z)):
                hit_point = inv_ray.at(txmin)
                return some(paral.newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral.shape_normal( hit_point, inv_ray.dir ),
                        surface_point = paral.point_to_uv(hit_point),
                        t = txmin,
                        ray = ray) )
            elif (txmax > inv_ray.tmin and txmax < inv_ray.tmax) and (inv_ray.at(txmax).x.min_close(paral.pmax.x) and inv_ray.at(txmax).x.max_close(paral.pmin.x)) and (inv_ray.at(txmax).y.min_close(paral.pmax.y) and inv_ray.at(txmax).y.max_close(paral.pmin.y)) and (inv_ray.at(txmax).z.min_close(paral.pmax.z) and inv_ray.at(txmax).z.max_close(paral.pmin.z)):
                hit_point = inv_ray.at(txmax)
                return some(paral.newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral.shape_normal( hit_point, inv_ray.dir ),
                        surface_point = paral.point_to_uv(hit_point),
                        t = txmax,
                        ray = ray) )
            else :
                return none(HitRecord) 

    if inv_ray.dir.x.is_close(0.0) and inv_ray.dir.z.is_close(0.0) :
        #Ray parallel to y
        if (inv_ray.origin.x.max_close(paral.pmin.x) and inv_ray.origin.x.min_close(paral.pmax.x)) and (inv_ray.origin.z.max_close(paral.pmin.z) and inv_ray.origin.z.min_close(paral.pmax.z)) :
            if (tymin > inv_ray.tmin and tymin < inv_ray.tmax) and (inv_ray.at(tymin).x.min_close(paral.pmax.x) and inv_ray.at(tymin).x.max_close(paral.pmin.x)) and (inv_ray.at(tymin).y.min_close(paral.pmax.y) and inv_ray.at(tymin).y.max_close(paral.pmin.y)) and (inv_ray.at(tymin).z.min_close(paral.pmax.z) and inv_ray.at(tymin).z.max_close(paral.pmin.z)):
                hit_point = inv_ray.at(tymin)
                return some(paral.newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral.shape_normal( hit_point, inv_ray.dir ),
                        surface_point = paral.point_to_uv(hit_point),
                        t = tymin,
                        ray = ray) )
            elif (tymax > inv_ray.tmin and tymax < inv_ray.tmax) and (inv_ray.at(tymax).x.min_close(paral.pmax.x) and inv_ray.at(tymax).x.max_close(paral.pmin.x)) and (inv_ray.at(tymax).y.min_close(paral.pmax.y) and inv_ray.at(tymax).y.max_close(paral.pmin.y)) and (inv_ray.at(tymax).z.min_close(paral.pmax.z) and inv_ray.at(tymax).z.max_close(paral.pmin.z)):
                hit_point = inv_ray.at(tymax)
                return some(paral.newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral.shape_normal( hit_point, inv_ray.dir ),
                        surface_point = paral.point_to_uv(hit_point),
                        t = tymax,
                        ray = ray) )
            else :
                return none(HitRecord) 

    #I look at x and y with z fixed, then I check on z
    if txmin.min_close(tymin) and tymin.min_close(txmax):
        if (tymin > inv_ray.tmin and tymin < inv_ray.tmax) and (inv_ray.at(tymin).x.min_close(paral.pmax.x) and inv_ray.at(tymin).x.max_close(paral.pmin.x)) and (inv_ray.at(tymin).y.min_close(paral.pmax.y) and inv_ray.at(tymin).y.max_close(paral.pmin.y)) and (inv_ray.at(tymin).z.min_close(paral.pmax.z) and inv_ray.at(tymin).z.max_close(paral.pmin.z)):
            ts.add(tymin)
        if (txmax > inv_ray.tmin and txmax < inv_ray.tmax) and (inv_ray.at(txmax).x.min_close(paral.pmax.x) and inv_ray.at(txmax).x.max_close(paral.pmin.x)) and (inv_ray.at(txmax).y.min_close(paral.pmax.y) and inv_ray.at(txmax).y.max_close(paral.pmin.y)) and (inv_ray.at(txmax).z.min_close(paral.pmax.z) and inv_ray.at(txmax).z.max_close(paral.pmin.z)):
            ts.add(txmax)

    elif tymin < txmin and txmin.min_close(tymax):  #Works in the same way as the if indented like this elif
        if (txmin > inv_ray.tmin and txmin < inv_ray.tmax) and (inv_ray.at(txmin).x.min_close(paral.pmax.x) and inv_ray.at(txmin).x.max_close(paral.pmin.x)) and (inv_ray.at(txmin).y.min_close(paral.pmax.y) and inv_ray.at(txmin).y.max_close(paral.pmin.y)) and (inv_ray.at(txmin).z.min_close(paral.pmax.z) and inv_ray.at(txmin).z.max_close(paral.pmin.z)):
            ts.add(txmin)
        if (tymax > inv_ray.tmin and tymax < inv_ray.tmax) and (inv_ray.at(tymax).x.min_close(paral.pmax.x) and inv_ray.at(tymax).x.max_close(paral.pmin.x)) and (inv_ray.at(tymax).y.min_close(paral.pmax.y) and inv_ray.at(tymax).y.max_close(paral.pmin.y)) and (inv_ray.at(tymax).z.min_close(paral.pmax.z) and inv_ray.at(tymax).z.max_close(paral.pmin.z)):
            ts.add(tymax)
    
    #Now I fix y at first to look at x,z
    if txmin.min_close(tzmin) :
        if (tzmin > inv_ray.tmin and tzmin < inv_ray.tmax) and (inv_ray.at(tzmin).x.min_close(paral.pmax.x) and inv_ray.at(tzmin).x.max_close(paral.pmin.x)) and (inv_ray.at(tzmin).y.min_close(paral.pmax.y) and inv_ray.at(tzmin).y.max_close(paral.pmin.y)) and (inv_ray.at(tzmin).z.min_close(paral.pmax.z) and inv_ray.at(tzmin).z.max_close(paral.pmin.z)):
            ts.add(tzmin)
        if (txmax > inv_ray.tmin and txmax < inv_ray.tmax) and (inv_ray.at(txmax).x.min_close(paral.pmax.x) and inv_ray.at(txmax).x.max_close(paral.pmin.x)) and (inv_ray.at(txmax).y.min_close(paral.pmax.y) and inv_ray.at(txmax).y.max_close(paral.pmin.y)) and (inv_ray.at(txmax).z.min_close(paral.pmax.z) and inv_ray.at(txmax).z.max_close(paral.pmin.z)):
            ts.add(txmax)
    elif tzmin < txmin :  #Works in the same way as the last if indented like this elif
        if (txmin > inv_ray.tmin and txmin < inv_ray.tmax) and (inv_ray.at(txmin).x.min_close(paral.pmax.x) and inv_ray.at(txmin).x.max_close(paral.pmin.x)) and (inv_ray.at(txmin).y.min_close(paral.pmax.y) and inv_ray.at(txmin).y.max_close(paral.pmin.y)) and (inv_ray.at(txmin).z.min_close(paral.pmax.z) and inv_ray.at(txmin).z.max_close(paral.pmin.z)):
            ts.add(txmin)
        if (tzmax > inv_ray.tmin and tzmax < inv_ray.tmax)  and (inv_ray.at(tzmax).x.min_close(paral.pmax.x) and inv_ray.at(tzmax).x.max_close(paral.pmin.x)) and (inv_ray.at(tzmax).y.min_close(paral.pmax.y) and inv_ray.at(tzmax).y.max_close(paral.pmin.y)) and (inv_ray.at(tzmax).z.min_close(paral.pmax.z) and inv_ray.at(tzmax).z.max_close(paral.pmin.z)):
            ts.add(tzmax)

    #Now I fix x at first to look at y,z
    if tymin.min_close(tzmin) :
        if (tzmin > inv_ray.tmin and tzmin < inv_ray.tmax) and (inv_ray.at(tzmin).x.min_close(paral.pmax.x) and inv_ray.at(tzmin).x.max_close(paral.pmin.x)) and (inv_ray.at(tzmin).y.min_close(paral.pmax.y) and inv_ray.at(tzmin).y.max_close(paral.pmin.y)) and (inv_ray.at(tzmin).z.min_close(paral.pmax.z) and inv_ray.at(tzmin).z.max_close(paral.pmin.z)):
            ts.add(tzmin)
        if (tymax > inv_ray.tmin and tymax < inv_ray.tmax) and (inv_ray.at(tymax).x.min_close(paral.pmax.x) and inv_ray.at(tymax).x.max_close(paral.pmin.x)) and (inv_ray.at(tymax).y.min_close(paral.pmax.y) and inv_ray.at(tymax).y.max_close(paral.pmin.y)) and (inv_ray.at(tymax).z.min_close(paral.pmax.z) and inv_ray.at(tymax).z.max_close(paral.pmin.z)):
            ts.add(tymax)
    elif tzmin < tymin :  #Works in the same way as the last if indented like this elif
        if (tymin > inv_ray.tmin and tymin < inv_ray.tmax) and (inv_ray.at(tymin).x.min_close(paral.pmax.x) and inv_ray.at(tymin).x.max_close(paral.pmin.x)) and (inv_ray.at(tymin).y.min_close(paral.pmax.y) and inv_ray.at(tymin).y.max_close(paral.pmin.y)) and (inv_ray.at(tymin).z.min_close(paral.pmax.z) and inv_ray.at(tymin).z.max_close(paral.pmin.z)):
            ts.add(tymin)
        if (tzmax > inv_ray.tmin and tzmax < inv_ray.tmax)  and (inv_ray.at(tzmax).x.min_close(paral.pmax.x) and inv_ray.at(tzmax).x.max_close(paral.pmin.x)) and (inv_ray.at(tzmax).y.min_close(paral.pmax.y) and inv_ray.at(tzmax).y.max_close(paral.pmin.y)) and (inv_ray.at(tzmax).z.min_close(paral.pmax.z) and inv_ray.at(tzmax).z.max_close(paral.pmin.z)):
            ts.add(tzmax)
            
    if len(ts) == 0: return none(HitRecord)
    
    else:
        ts.sort()
        hit_point = inv_ray.at(ts[0])
        return some(paral.newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral.shape_normal( hit_point, inv_ray.dir ),
                        surface_point = paral.point_to_uv(hit_point),
                        t = ts[0],
                        ray = ray))

method all_ray_intersections*(paral : Parallelepiped, ray : Ray) : Option[seq[HitRecord]] =
    ## Compute the nearest intersection between a ray and a parallelepiped form the observer's pov
    var 
        inv_ray = ray.transform(paral.transformation.inverse())
        #intersections with the planes which form the parallelepiped
        txmin = (paral.pmin.x - inv_ray.origin.x) / inv_ray.dir.x
        txmax = (paral.pmax.x - inv_ray.origin.x) / inv_ray.dir.x
        tymin = (paral.pmin.y - inv_ray.origin.y) / inv_ray.dir.y
        tymax = (paral.pmax.y - inv_ray.origin.y) / inv_ray.dir.y
        tzmin = (paral.pmin.z - inv_ray.origin.z) / inv_ray.dir.z
        tzmax = (paral.pmax.z - inv_ray.origin.z) / inv_ray.dir.z
        ts : seq[float]
        hit_point : Point
        hits : seq[HitRecord]

    ts = @[]
    hits = @[]

    if txmin > txmax : swap(txmin, txmax)
    if tymin > tymax : swap(tymin, tymax)
    if tzmin > tzmax : swap(tzmin, tzmax)

#I separatelly check if the ray is parallel to a face of the parallelepiped
    if inv_ray.dir.x.is_close(0.0) and inv_ray.dir.y.is_close(0.0) :
        #Ray parallel to z
        if (inv_ray.origin.x.max_close(paral.pmin.x) and inv_ray.origin.x.min_close(paral.pmax.x)) and (inv_ray.origin.y.max_close(paral.pmin.y) and inv_ray.origin.y.min_close(paral.pmax.y)):
            if (tzmin > inv_ray.tmin and tzmin < inv_ray.tmax) and (inv_ray.at(tzmin).x.min_close(paral.pmax.x) and inv_ray.at(tzmin).x.max_close(paral.pmin.x)) and (inv_ray.at(tzmin).y.min_close(paral.pmax.y) and inv_ray.at(tzmin).y.max_close(paral.pmin.y)) and (inv_ray.at(tzmin).z.min_close(paral.pmax.z) and inv_ray.at(tzmin).z.max_close(paral.pmin.z)):
                hit_point = inv_ray.at(tzmin)
                hits.add(paral.newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral.shape_normal( hit_point, inv_ray.dir ),
                        surface_point = paral.point_to_uv(hit_point),
                        t = tzmin,
                        ray = ray) )
            if (tzmax > inv_ray.tmin and tzmax < inv_ray.tmax) and (inv_ray.at(tzmax).x.min_close(paral.pmax.x) and inv_ray.at(tzmax).x.max_close(paral.pmin.x)) and (inv_ray.at(tzmax).y.min_close(paral.pmax.y) and inv_ray.at(tzmax).y.max_close(paral.pmin.y)) and (inv_ray.at(tzmax).z.min_close(paral.pmax.z) and inv_ray.at(tzmax).z.max_close(paral.pmin.z)):
                hit_point = inv_ray.at(tzmax)
                hits.add(paral.newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral.shape_normal( hit_point, inv_ray.dir ),
                        surface_point = paral.point_to_uv(hit_point),
                        t = tzmax,
                        ray = ray) )
            return some(hits)
        else :
            return none(seq[HitRecord])

    if inv_ray.dir.z.is_close(0.0) and inv_ray.dir.y.is_close(0.0) :
        #Ray parallel to x
        if (inv_ray.origin.y.max_close(paral.pmin.y) and inv_ray.origin.y.min_close(paral.pmax.y)) and (inv_ray.origin.z.max_close(paral.pmin.z) and inv_ray.origin.z.min_close(paral.pmax.z)) :
            if (txmin > inv_ray.tmin and txmin < inv_ray.tmax) and (inv_ray.at(txmin).x.min_close(paral.pmax.x) and inv_ray.at(txmin).x.max_close(paral.pmin.x)) and (inv_ray.at(txmin).y.min_close(paral.pmax.y) and inv_ray.at(txmin).y.max_close(paral.pmin.y)) and (inv_ray.at(txmin).z.min_close(paral.pmax.z) and inv_ray.at(txmin).z.max_close(paral.pmin.z)):
                hit_point = inv_ray.at(txmin)
                hits.add(paral.newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral.shape_normal( hit_point, inv_ray.dir ),
                        surface_point = paral.point_to_uv(hit_point),
                        t = txmin,
                        ray = ray) )
            if (txmax > inv_ray.tmin and txmax < inv_ray.tmax) and (inv_ray.at(txmax).x.min_close(paral.pmax.x) and inv_ray.at(txmax).x.max_close(paral.pmin.x)) and (inv_ray.at(txmax).y.min_close(paral.pmax.y) and inv_ray.at(txmax).y.max_close(paral.pmin.y)) and (inv_ray.at(txmax).z.min_close(paral.pmax.z) and inv_ray.at(txmax).z.max_close(paral.pmin.z)):
                hit_point = inv_ray.at(txmax)
                hits.add(paral.newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral.shape_normal( hit_point, inv_ray.dir ),
                        surface_point = paral.point_to_uv(hit_point),
                        t = txmax,
                        ray = ray) )
            return some(hits)
        else :
            return none(seq[HitRecord]) 

    if inv_ray.dir.x.is_close(0.0) and inv_ray.dir.z.is_close(0.0) :
        #Ray parallel to y
        if (inv_ray.origin.x.max_close(paral.pmin.x) and inv_ray.origin.x.min_close(paral.pmax.x)) and (inv_ray.origin.z.max_close(paral.pmin.z) and inv_ray.origin.z.min_close(paral.pmax.z)) :
            if (tymin > inv_ray.tmin and tymin < inv_ray.tmax) and (inv_ray.at(tymin).x.min_close(paral.pmax.x) and inv_ray.at(tymin).x.max_close(paral.pmin.x)) and (inv_ray.at(tymin).y.min_close(paral.pmax.y) and inv_ray.at(tymin).y.max_close(paral.pmin.y)) and (inv_ray.at(tymin).z.min_close(paral.pmax.z) and inv_ray.at(tymin).z.max_close(paral.pmin.z)):
                hit_point = inv_ray.at(tymin)
                hits.add(paral.newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral.shape_normal( hit_point, inv_ray.dir ),
                        surface_point = paral.point_to_uv(hit_point),
                        t = tymin,
                        ray = ray) )
            if (tymax > inv_ray.tmin and tymax < inv_ray.tmax) and (inv_ray.at(tymax).x.min_close(paral.pmax.x) and inv_ray.at(tymax).x.max_close(paral.pmin.x)) and (inv_ray.at(tymax).y.min_close(paral.pmax.y) and inv_ray.at(tymax).y.max_close(paral.pmin.y)) and (inv_ray.at(tymax).z.min_close(paral.pmax.z) and inv_ray.at(tymax).z.max_close(paral.pmin.z)):
                hit_point = inv_ray.at(tymax)
                hits.add(paral.newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral.shape_normal( hit_point, inv_ray.dir ),
                        surface_point = paral.point_to_uv(hit_point),
                        t = tymax,
                        ray = ray) )
            return some(hits)
        else :
            return none(seq[HitRecord]) 

    #I look at x and y with z fixed, then I check on z
    if txmin.min_close(tymin) and tymin.min_close(txmax):
        if (tymin > inv_ray.tmin and tymin < inv_ray.tmax) and (inv_ray.at(tymin).x.min_close(paral.pmax.x) and inv_ray.at(tymin).x.max_close(paral.pmin.x)) and (inv_ray.at(tymin).y.min_close(paral.pmax.y) and inv_ray.at(tymin).y.max_close(paral.pmin.y)) and (inv_ray.at(tymin).z.min_close(paral.pmax.z) and inv_ray.at(tymin).z.max_close(paral.pmin.z)):
            ts.add(tymin)
        if (txmax > inv_ray.tmin and txmax < inv_ray.tmax) and (inv_ray.at(txmax).x.min_close(paral.pmax.x) and inv_ray.at(txmax).x.max_close(paral.pmin.x)) and (inv_ray.at(txmax).y.min_close(paral.pmax.y) and inv_ray.at(txmax).y.max_close(paral.pmin.y)) and (inv_ray.at(txmax).z.min_close(paral.pmax.z) and inv_ray.at(txmax).z.max_close(paral.pmin.z)):
            ts.add(txmax)

    elif tymin < txmin and txmin.min_close(tymax):  #Works in the same way as the if indented like this elif
        if (txmin > inv_ray.tmin and txmin < inv_ray.tmax) and (inv_ray.at(txmin).x.min_close(paral.pmax.x) and inv_ray.at(txmin).x.max_close(paral.pmin.x)) and (inv_ray.at(txmin).y.min_close(paral.pmax.y) and inv_ray.at(txmin).y.max_close(paral.pmin.y)) and (inv_ray.at(txmin).z.min_close(paral.pmax.z) and inv_ray.at(txmin).z.max_close(paral.pmin.z)):
            ts.add(txmin)
        if (tymax > inv_ray.tmin and tymax < inv_ray.tmax) and (inv_ray.at(tymax).x.min_close(paral.pmax.x) and inv_ray.at(tymax).x.max_close(paral.pmin.x)) and (inv_ray.at(tymax).y.min_close(paral.pmax.y) and inv_ray.at(tymax).y.max_close(paral.pmin.y)) and (inv_ray.at(tymax).z.min_close(paral.pmax.z) and inv_ray.at(tymax).z.max_close(paral.pmin.z)):
            ts.add(tymax)
    
    #Now I fix y at first to look at x,z
    if txmin.min_close(tzmin) :
        if (tzmin > inv_ray.tmin and tzmin < inv_ray.tmax) and (inv_ray.at(tzmin).x.min_close(paral.pmax.x) and inv_ray.at(tzmin).x.max_close(paral.pmin.x)) and (inv_ray.at(tzmin).y.min_close(paral.pmax.y) and inv_ray.at(tzmin).y.max_close(paral.pmin.y)) and (inv_ray.at(tzmin).z.min_close(paral.pmax.z) and inv_ray.at(tzmin).z.max_close(paral.pmin.z)):
            ts.add(tzmin)
        if (txmax > inv_ray.tmin and txmax < inv_ray.tmax) and (inv_ray.at(txmax).x.min_close(paral.pmax.x) and inv_ray.at(txmax).x.max_close(paral.pmin.x)) and (inv_ray.at(txmax).y.min_close(paral.pmax.y) and inv_ray.at(txmax).y.max_close(paral.pmin.y)) and (inv_ray.at(txmax).z.min_close(paral.pmax.z) and inv_ray.at(txmax).z.max_close(paral.pmin.z)):
            ts.add(txmax)
    elif tzmin < txmin :  #Works in the same way as the last if indented like this elif
        if (txmin > inv_ray.tmin and txmin < inv_ray.tmax) and (inv_ray.at(txmin).x.min_close(paral.pmax.x) and inv_ray.at(txmin).x.max_close(paral.pmin.x)) and (inv_ray.at(txmin).y.min_close(paral.pmax.y) and inv_ray.at(txmin).y.max_close(paral.pmin.y)) and (inv_ray.at(txmin).z.min_close(paral.pmax.z) and inv_ray.at(txmin).z.max_close(paral.pmin.z)):
            ts.add(txmin)
        if (tzmax > inv_ray.tmin and tzmax < inv_ray.tmax)  and (inv_ray.at(tzmax).x.min_close(paral.pmax.x) and inv_ray.at(tzmax).x.max_close(paral.pmin.x)) and (inv_ray.at(tzmax).y.min_close(paral.pmax.y) and inv_ray.at(tzmax).y.max_close(paral.pmin.y)) and (inv_ray.at(tzmax).z.min_close(paral.pmax.z) and inv_ray.at(tzmax).z.max_close(paral.pmin.z)):
            ts.add(tzmax)

    #Now I fix x at first to look at y,z
    if tymin.min_close(tzmin) :
        if (tzmin > inv_ray.tmin and tzmin < inv_ray.tmax) and (inv_ray.at(tzmin).x.min_close(paral.pmax.x) and inv_ray.at(tzmin).x.max_close(paral.pmin.x)) and (inv_ray.at(tzmin).y.min_close(paral.pmax.y) and inv_ray.at(tzmin).y.max_close(paral.pmin.y)) and (inv_ray.at(tzmin).z.min_close(paral.pmax.z) and inv_ray.at(tzmin).z.max_close(paral.pmin.z)):
            ts.add(tzmin)
        if (tymax > inv_ray.tmin and tymax < inv_ray.tmax) and (inv_ray.at(tymax).x.min_close(paral.pmax.x) and inv_ray.at(tymax).x.max_close(paral.pmin.x)) and (inv_ray.at(tymax).y.min_close(paral.pmax.y) and inv_ray.at(tymax).y.max_close(paral.pmin.y)) and (inv_ray.at(tymax).z.min_close(paral.pmax.z) and inv_ray.at(tymax).z.max_close(paral.pmin.z)):
            ts.add(tymax)
    elif tzmin < tymin :  #Works in the same way as the last if indented like this elif
        if (tymin > inv_ray.tmin and tymin < inv_ray.tmax) and (inv_ray.at(tymin).x.min_close(paral.pmax.x) and inv_ray.at(tymin).x.max_close(paral.pmin.x)) and (inv_ray.at(tymin).y.min_close(paral.pmax.y) and inv_ray.at(tymin).y.max_close(paral.pmin.y)) and (inv_ray.at(tymin).z.min_close(paral.pmax.z) and inv_ray.at(tymin).z.max_close(paral.pmin.z)):
            ts.add(tymin)
        if (tzmax > inv_ray.tmin and tzmax < inv_ray.tmax)  and (inv_ray.at(tzmax).x.min_close(paral.pmax.x) and inv_ray.at(tzmax).x.max_close(paral.pmin.x)) and (inv_ray.at(tzmax).y.min_close(paral.pmax.y) and inv_ray.at(tzmax).y.max_close(paral.pmin.y)) and (inv_ray.at(tzmax).z.min_close(paral.pmax.z) and inv_ray.at(tzmax).z.max_close(paral.pmin.z)):
            ts.add(tzmax)

    if len(ts) == 0: return none(seq[HitRecord])

    ts.sort()
    hit_point = inv_ray.at(ts[0])
    hits.add(paral.newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral.shape_normal( hit_point, inv_ray.dir ),
                        surface_point = paral.point_to_uv(hit_point),
                        t = ts[0],
                        ray = ray))
    hit_point = inv_ray.at(ts[1])
    hits.add(paral.newHitRecord(world_point = paral.transformation * hit_point , 
                        normal = paral.transformation * paral.shape_normal( hit_point, inv_ray.dir ),
                        surface_point = paral.point_to_uv(hit_point),
                        t = ts[1],
                        ray = ray))
    return some(hits)

method have_inside*(paral : Parallelepiped, point : Point ) : bool =
    ## Check if a point is inside a parallelepiped 
    var inv_point = paral.transformation.inverse() * point
    if (inv_point.x > paral.pmin.x and inv_point.x < paral.pmax.x) and (inv_point.y > paral.pmin.y and inv_point.y < paral.pmax.y) and (inv_point.z > paral.pmin.z and inv_point.z < paral.pmax.z) :
        return true
    else:
        return false