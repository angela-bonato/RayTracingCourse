## Implementation of different Shapes that our code can render. Implement also some useful types to perform the rendering.

import transformation
import point
import vector
import normal
import geometryalgebra
import ray
import materials
import std/algorithm
import std/math
import std/options
import std/algorithm

# procs usefull to avoid rounding errors

proc is_close(a,b: float) : bool =
    ## alternative function to almostEqual. I define this to avoid small rounding errors
    if abs(a-b)<1e-5 : return true
    else : return false

proc min_close*(a,b: float32) : bool =
    ## to use <= with float avoiding rounding errors
    if a < b or is_close(a, b) : return true
    else : return false

func max_close*(a,b: float32) : bool =
    ## to use >= with float avoiding rounding errors
    if a > b or is_close(a, b) : return true
    else : return false

# Shape type declaration

type 
    ShapeKind* = enum
        ## All possible kinds of shapes
        Sphere, Plane, Parallelepiped, ShapesUnion, ShapesIntersection, ShapesDifference

    Shape* = ref ShapeObj

    ShapeObj* = object
        transformation* : Transformation
        material* : Material
        case kind*: ShapeKind
            of Sphere:
                ## It represents a unitary sphere centered in the origin, the proper position of the object is represented by the transformation 
                discard
            of Plane:
                ## It defines an infinite plane in space
                discard
            of Parallelepiped:
                ## It defines an axis-aligned box
                pmin*, pmax*: Point   #points that define the value of each dimension of the shape, along with its position in space
            of ShapesUnion:
                ## It represent the union of two shapes
                u_shape1*, u_shape2* : Shape
            of ShapesIntersection:
                ## It represent the intesection of two shapes
                i_shape1*, i_shape2* : Shape
            of ShapesDifference:
                ## It represent the difference between two shapes (shape1 - shape2)
                d_shape1*, d_shape2* : Shape

# Shapes constructors

proc newSphere*( transform = newTransformation(), material = newMaterial() ) : Shape {.inline.} =
    ## Sphere constructor
    Shape( transformation: transform, material: material, kind: Sphere )

proc newPlane*( transform = newTransformation(), material = newMaterial() ) : Shape {.inline.} =
    ## Plane constructor
    Shape( transformation: transform, material: material, kind: Plane)

proc newParallelepiped*( transform = newTransformation(), p_max = newPoint(1.0, 1.0, 1.0), material = newMaterial() ) : Shape =
    ## Parallelepiped constructor, default is unitary cube defined from the origin, to change the default you can change pmax but as long as it is positive
    
    var 
        pmin = newPoint()
        pmax : Point
    
    if p_max.x < 0.0 or p_max.y < 0.0 or p_max.z < 0.0 :
        echo "Invalid p_max argument in newParallelepiped(): a negative p_max it is not allowed, you have to define it positive and then use transform on it. The default constructor will be called now."
        pmax = newPoint(1.0, 1.0, 1.0)
    else:
        pmax = p_max
    
    return Shape( transformation: transform, material: material, kind: Parallelepiped, pmin: pmin, pmax: pmax)

proc unite*(shape1, shape2 : Shape) : Shape {.inline.} =
    ## ShapeUnion constructor
    Shape( transformation: newTransformation(), material: newMaterial(), kind: ShapesUnion, u_shape1: shape1, u_shape2: shape2 )

proc intersect*(shape1, shape2 : Shape) : Shape {.inline.} =
    ## ShapeIntersection constructor
    Shape( transformation: newTransformation(), material: newMaterial(), kind: ShapesIntersection, i_shape1: shape1, i_shape2: shape2 )

proc subtract*(shape1, shape2 : Shape) : Shape {.inline.} =
    ## ShapeDifference constructor (shape1 - shape2)
    Shape( transformation: newTransformation(), material: newMaterial(), kind: ShapesDifference, d_shape1: shape1, d_shape2: shape2 )


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

# Shape procs declarations

proc shape_normal*(shape : Shape, point : Point, ray_dir : Vector) : Normal =
    
    if shape.kind == Sphere:
        ## Return the normal to a point of the sphere, depending on the ray direction
        result = newNormal(point.x, point.y, point.z)
        if result.dot(ray_dir) < 0.0: 
            return result
        else:
            return result.neg()
    elif shape.kind == Plane:
        ## Return the normal to a point of the plane, depending on the ray direction
        result = newNormal(0,0,1)
        if result.dot(ray_dir) < 0.0: 
            return result
        else:
            return result.neg()
    elif shape.kind == Parallelepiped: 
        ## Return the normal to a point of the parallelepiped (based on the face on which it lies), depending on the ray direction
        if point.z.is_close(shape.pmax.z) :
            result = newNormal(0.0, 0.0, 1.0)
        if point.x.is_close(shape.pmax.x) :
            result = newNormal(1.0, 0.0, 0.0)
        if point.y.is_close(shape.pmax.y) :
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
    else:
        assert false, "Invalid Shape.kind found"

proc point_to_uv*(shape : Shape, point : Point) : Vec2d =

    if shape.kind == Sphere:
        ## Return the point of the sphere in the shape independant u,v coordinates
        var 
            u = arctan2(point.y, point.x) / (2.0 * PI) 
            v = arccos(point.z) / PI
        if u >= 0.0: 
            return newVec2d(u,v)
        else:
            return newVec2d(u+1.0,v)

    elif shape.kind == Plane:
        ## Return the point of the sphere in the shape independant u,v coordinates
        var 
            u = point.x - floor(point.x)
            v = point.y - floor(point.y)
        return newVec2d(u,v)

    elif shape.kind == Parallelepiped:
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
            # normalization constants to define u,v in [0,1]. Thanks to the way newParallelepiped is defined, shape.pmax.x,y,z are the lengths of the three dimensions of the parallelepiped
            normalu = 2.0*shape.pmax.x + shape.pmax.y  
            normalv = 2.0*(shape.pmax.x + shape.pmax.z)
        # I have to understand in which face of the parallelepiped the point is placed and then map it in the correspondent part of the (u,v) plane
        if point.z.is_close(shape.pmax.z) :  #face number 5
            u = (shape.pmax.x + point.y)/normalu
            v = point.x/normalv
        if point.y.is_close(0.0) :  #face number 2
            u = point.x/normalu
            v = (shape.pmax.x + (shape.pmax.z - point.z))/normalv
        if point.x.is_close(shape.pmax.x) :  #face number 6
            u = (shape.pmax.x + point.y)/normalu
            v = (shape.pmax.x + (shape.pmax.z - point.z))/normalv
        if point.y.is_close(shape.pmax.y) :  #face number 4
            u = (shape.pmax.x + shape.pmax.y + (shape.pmax.x - point.x))/normalu
            v = (shape.pmax.x + (shape.pmax.z - point.z))/normalv
        if point.z.is_close(0.0) :  #face number 1
            u = (shape.pmax.x + point.y)/normalu
            v = (shape.pmax.x + shape.pmax.z + (shape.pmax.x - point.x))/normalv
        if point.x.is_close(0.0) :  #face number 3
            u = (shape.pmax.x + point.y)/normalu
            v = (2.0*shape.pmax.x + shape.pmax.z + point.z)/normalv

        return newVec2d(u,v)

    else:
        assert false, "Invalid Shape.kind found"

proc all_ray_intersections*(shape : Shape, ray : Ray) : Option[seq[HitRecord]]
proc have_inside*( shape : Shape, point : Point) : bool

proc ray_intersection*(shape : Shape, ray : Ray) : Option[HitRecord] =

    if shape.kind == Sphere: 
        ## Compute the intersection between a ray and a sphere
        var 
            inv_ray = ray.transform(shape.transformation.inverse())
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
        return some( shape.newHitRecord( world_point = shape.transformation * hit_point , 
                     normal = shape.transformation * shape.shape_normal( hit_point, inv_ray.dir ),
                     surface_point = shape.point_to_uv(hit_point),
                     t = first_hit,
                     ray = ray    
                     ) )

    elif shape.kind == Plane: 
        ## Compute the intersection between a ray and a plane
        var inv_ray = ray.transform(shape.transformation.inverse())
        if inv_ray.dir.z == 0: return none(HitRecord) # the ray missed the plane
    
        var t_hit = - inv_ray.origin.z / inv_ray.dir.z
        
        if t_hit < ray.tmin or t_hit > ray.tmax : return none(HitRecord) # the intersection is out of the ray boundaries
    
        var hit_point = inv_ray.at(t_hit)
    
        return some(shape.newHitRecord( world_point = shape.transformation * hit_point , 
                                   normal = shape.transformation * shape.shape_normal(hit_point, inv_ray.dir ),
                                   surface_point = shape.point_to_uv(hit_point),
                                   t = t_hit,
                                   ray = ray    
                                   ) )

    elif shape.kind == Parallelepiped: 
        ## Compute all the intersection between a ray and a parallelepiped 
        var 
            inv_ray = ray.transform(shape.transformation.inverse())
            #intersections with the planes which form the parallelepiped
            txmin = (shape.pmin.x - inv_ray.origin.x) / inv_ray.dir.x
            txmax = (shape.pmax.x - inv_ray.origin.x) / inv_ray.dir.x
            tymin = (shape.pmin.y - inv_ray.origin.y) / inv_ray.dir.y
            tymax = (shape.pmax.y - inv_ray.origin.y) / inv_ray.dir.y
            tzmin = (shape.pmin.z - inv_ray.origin.z) / inv_ray.dir.z
            tzmax = (shape.pmax.z - inv_ray.origin.z) / inv_ray.dir.z
            ts : seq[float]
            hit_point : Point
    
        ts = @[]
    
        if txmin > txmax : swap(txmin, txmax)
        if tymin > tymax : swap(tymin, tymax)
        if tzmin > tzmax : swap(tzmin, tzmax)
    
        #I separatelly check if the ray is parallel to a face of the parallelepiped
        if inv_ray.dir.x.is_close(0.0) and inv_ray.dir.y.is_close(0.0) :
            #Ray parallel to z
            if (inv_ray.origin.x.max_close(shape.pmin.x) and inv_ray.origin.x.min_close(shape.pmax.x)) and (inv_ray.origin.y.max_close(shape.pmin.y) and inv_ray.origin.y.min_close(shape.pmax.y)):
                if (tzmin > inv_ray.tmin and tzmin < inv_ray.tmax) and (inv_ray.at(tzmin).x.min_close(shape.pmax.x) and inv_ray.at(tzmin).x.max_close(shape.pmin.x)) and (inv_ray.at(tzmin).y.min_close(shape.pmax.y) and inv_ray.at(tzmin).y.max_close(shape.pmin.y)) and (inv_ray.at(tzmin).z.min_close(shape.pmax.z) and inv_ray.at(tzmin).z.max_close(shape.pmin.z)):
                    hit_point = inv_ray.at(tzmin)
                    return some(shape.newHitRecord(world_point = shape.transformation * hit_point , 
                            normal = shape.transformation * shape.shape_normal( hit_point, inv_ray.dir ),
                            surface_point = shape.point_to_uv(hit_point),
                            t = tzmin,
                            ray = ray) )
                elif (tzmax > inv_ray.tmin and tzmax < inv_ray.tmax) and (inv_ray.at(tzmax).x.min_close(shape.pmax.x) and inv_ray.at(tzmax).x.max_close(shape.pmin.x)) and (inv_ray.at(tzmax).y.min_close(shape.pmax.y) and inv_ray.at(tzmax).y.max_close(shape.pmin.y)) and (inv_ray.at(tzmax).z.min_close(shape.pmax.z) and inv_ray.at(tzmax).z.max_close(shape.pmin.z)):
                    hit_point = inv_ray.at(tzmax)
                    return some(shape.newHitRecord(world_point = shape.transformation * hit_point , 
                            normal = shape.transformation * shape.shape_normal( hit_point, inv_ray.dir ),
                            surface_point = shape.point_to_uv(hit_point),
                            t = tzmax,
                            ray = ray) )
                else :
                    return none(HitRecord)
    
        if inv_ray.dir.z.is_close(0.0) and inv_ray.dir.y.is_close(0.0) :
            #Ray parallel to x
            if (inv_ray.origin.y.max_close(shape.pmin.y) and inv_ray.origin.y.min_close(shape.pmax.y)) and (inv_ray.origin.z.max_close(shape.pmin.z) and inv_ray.origin.z.min_close(shape.pmax.z)) :
                if (txmin > inv_ray.tmin and txmin < inv_ray.tmax) and (inv_ray.at(txmin).x.min_close(shape.pmax.x) and inv_ray.at(txmin).x.max_close(shape.pmin.x)) and (inv_ray.at(txmin).y.min_close(shape.pmax.y) and inv_ray.at(txmin).y.max_close(shape.pmin.y)) and (inv_ray.at(txmin).z.min_close(shape.pmax.z) and inv_ray.at(txmin).z.max_close(shape.pmin.z)):
                    hit_point = inv_ray.at(txmin)
                    return some(shape.newHitRecord(world_point = shape.transformation * hit_point , 
                            normal = shape.transformation * shape.shape_normal( hit_point, inv_ray.dir ),
                            surface_point = shape.point_to_uv(hit_point),
                            t = txmin,
                            ray = ray) )
                elif (txmax > inv_ray.tmin and txmax < inv_ray.tmax) and (inv_ray.at(txmax).x.min_close(shape.pmax.x) and inv_ray.at(txmax).x.max_close(shape.pmin.x)) and (inv_ray.at(txmax).y.min_close(shape.pmax.y) and inv_ray.at(txmax).y.max_close(shape.pmin.y)) and (inv_ray.at(txmax).z.min_close(shape.pmax.z) and inv_ray.at(txmax).z.max_close(shape.pmin.z)):
                    hit_point = inv_ray.at(txmax)
                    return some(shape.newHitRecord(world_point = shape.transformation * hit_point , 
                            normal = shape.transformation * shape.shape_normal( hit_point, inv_ray.dir ),
                            surface_point = shape.point_to_uv(hit_point),
                            t = txmax,
                            ray = ray) )
                else :
                    return none(HitRecord) 
    
        if inv_ray.dir.x.is_close(0.0) and inv_ray.dir.z.is_close(0.0) :
            #Ray parallel to y
            if (inv_ray.origin.x.max_close(shape.pmin.x) and inv_ray.origin.x.min_close(shape.pmax.x)) and (inv_ray.origin.z.max_close(shape.pmin.z) and inv_ray.origin.z.min_close(shape.pmax.z)) :
                if (tymin > inv_ray.tmin and tymin < inv_ray.tmax) and (inv_ray.at(tymin).x.min_close(shape.pmax.x) and inv_ray.at(tymin).x.max_close(shape.pmin.x)) and (inv_ray.at(tymin).y.min_close(shape.pmax.y) and inv_ray.at(tymin).y.max_close(shape.pmin.y)) and (inv_ray.at(tymin).z.min_close(shape.pmax.z) and inv_ray.at(tymin).z.max_close(shape.pmin.z)):
                    hit_point = inv_ray.at(tymin)
                    return some(shape.newHitRecord(world_point = shape.transformation * hit_point , 
                            normal = shape.transformation * shape.shape_normal( hit_point, inv_ray.dir ),
                            surface_point = shape.point_to_uv(hit_point),
                            t = tymin,
                            ray = ray) )
                elif (tymax > inv_ray.tmin and tymax < inv_ray.tmax) and (inv_ray.at(tymax).x.min_close(shape.pmax.x) and inv_ray.at(tymax).x.max_close(shape.pmin.x)) and (inv_ray.at(tymax).y.min_close(shape.pmax.y) and inv_ray.at(tymax).y.max_close(shape.pmin.y)) and (inv_ray.at(tymax).z.min_close(shape.pmax.z) and inv_ray.at(tymax).z.max_close(shape.pmin.z)):
                    hit_point = inv_ray.at(tymax)
                    return some(shape.newHitRecord(world_point = shape.transformation * hit_point , 
                            normal = shape.transformation * shape.shape_normal( hit_point, inv_ray.dir ),
                            surface_point = shape.point_to_uv(hit_point),
                            t = tymax,
                            ray = ray) )
                else :
                    return none(HitRecord) 
    
        #I look at x and y with z fixed, then I check on z
        if txmin.min_close(tymin) and tymin.min_close(txmax):
            if (tymin > inv_ray.tmin and tymin < inv_ray.tmax) and (inv_ray.at(tymin).x.min_close(shape.pmax.x) and inv_ray.at(tymin).x.max_close(shape.pmin.x)) and (inv_ray.at(tymin).y.min_close(shape.pmax.y) and inv_ray.at(tymin).y.max_close(shape.pmin.y)) and (inv_ray.at(tymin).z.min_close(shape.pmax.z) and inv_ray.at(tymin).z.max_close(shape.pmin.z)):
                ts.add(tymin)
            if (txmax > inv_ray.tmin and txmax < inv_ray.tmax) and (inv_ray.at(txmax).x.min_close(shape.pmax.x) and inv_ray.at(txmax).x.max_close(shape.pmin.x)) and (inv_ray.at(txmax).y.min_close(shape.pmax.y) and inv_ray.at(txmax).y.max_close(shape.pmin.y)) and (inv_ray.at(txmax).z.min_close(shape.pmax.z) and inv_ray.at(txmax).z.max_close(shape.pmin.z)):
                ts.add(txmax)
    
        elif tymin < txmin and txmin.min_close(tymax):  #Works in the same way as the if indented like this elif
            if (txmin > inv_ray.tmin and txmin < inv_ray.tmax) and (inv_ray.at(txmin).x.min_close(shape.pmax.x) and inv_ray.at(txmin).x.max_close(shape.pmin.x)) and (inv_ray.at(txmin).y.min_close(shape.pmax.y) and inv_ray.at(txmin).y.max_close(shape.pmin.y)) and (inv_ray.at(txmin).z.min_close(shape.pmax.z) and inv_ray.at(txmin).z.max_close(shape.pmin.z)):
                ts.add(txmin)
            if (tymax > inv_ray.tmin and tymax < inv_ray.tmax) and (inv_ray.at(tymax).x.min_close(shape.pmax.x) and inv_ray.at(tymax).x.max_close(shape.pmin.x)) and (inv_ray.at(tymax).y.min_close(shape.pmax.y) and inv_ray.at(tymax).y.max_close(shape.pmin.y)) and (inv_ray.at(tymax).z.min_close(shape.pmax.z) and inv_ray.at(tymax).z.max_close(shape.pmin.z)):
                ts.add(tymax)
        
        #Now I fix y at first to look at x,z
        if txmin.min_close(tzmin) :
            if (tzmin > inv_ray.tmin and tzmin < inv_ray.tmax) and (inv_ray.at(tzmin).x.min_close(shape.pmax.x) and inv_ray.at(tzmin).x.max_close(shape.pmin.x)) and (inv_ray.at(tzmin).y.min_close(shape.pmax.y) and inv_ray.at(tzmin).y.max_close(shape.pmin.y)) and (inv_ray.at(tzmin).z.min_close(shape.pmax.z) and inv_ray.at(tzmin).z.max_close(shape.pmin.z)):
                ts.add(tzmin)
            if (txmax > inv_ray.tmin and txmax < inv_ray.tmax) and (inv_ray.at(txmax).x.min_close(shape.pmax.x) and inv_ray.at(txmax).x.max_close(shape.pmin.x)) and (inv_ray.at(txmax).y.min_close(shape.pmax.y) and inv_ray.at(txmax).y.max_close(shape.pmin.y)) and (inv_ray.at(txmax).z.min_close(shape.pmax.z) and inv_ray.at(txmax).z.max_close(shape.pmin.z)):
                ts.add(txmax)
        elif tzmin < txmin :  #Works in the same way as the last if indented like this elif
            if (txmin > inv_ray.tmin and txmin < inv_ray.tmax) and (inv_ray.at(txmin).x.min_close(shape.pmax.x) and inv_ray.at(txmin).x.max_close(shape.pmin.x)) and (inv_ray.at(txmin).y.min_close(shape.pmax.y) and inv_ray.at(txmin).y.max_close(shape.pmin.y)) and (inv_ray.at(txmin).z.min_close(shape.pmax.z) and inv_ray.at(txmin).z.max_close(shape.pmin.z)):
                ts.add(txmin)
            if (tzmax > inv_ray.tmin and tzmax < inv_ray.tmax)  and (inv_ray.at(tzmax).x.min_close(shape.pmax.x) and inv_ray.at(tzmax).x.max_close(shape.pmin.x)) and (inv_ray.at(tzmax).y.min_close(shape.pmax.y) and inv_ray.at(tzmax).y.max_close(shape.pmin.y)) and (inv_ray.at(tzmax).z.min_close(shape.pmax.z) and inv_ray.at(tzmax).z.max_close(shape.pmin.z)):
                ts.add(tzmax)
    
        #Now I fix x at first to look at y,z
        if tymin.min_close(tzmin) :
            if (tzmin > inv_ray.tmin and tzmin < inv_ray.tmax) and (inv_ray.at(tzmin).x.min_close(shape.pmax.x) and inv_ray.at(tzmin).x.max_close(shape.pmin.x)) and (inv_ray.at(tzmin).y.min_close(shape.pmax.y) and inv_ray.at(tzmin).y.max_close(shape.pmin.y)) and (inv_ray.at(tzmin).z.min_close(shape.pmax.z) and inv_ray.at(tzmin).z.max_close(shape.pmin.z)):
                ts.add(tzmin)
            if (tymax > inv_ray.tmin and tymax < inv_ray.tmax) and (inv_ray.at(tymax).x.min_close(shape.pmax.x) and inv_ray.at(tymax).x.max_close(shape.pmin.x)) and (inv_ray.at(tymax).y.min_close(shape.pmax.y) and inv_ray.at(tymax).y.max_close(shape.pmin.y)) and (inv_ray.at(tymax).z.min_close(shape.pmax.z) and inv_ray.at(tymax).z.max_close(shape.pmin.z)):
                ts.add(tymax)
        elif tzmin < tymin :  #Works in the same way as the last if indented like this elif
            if (tymin > inv_ray.tmin and tymin < inv_ray.tmax) and (inv_ray.at(tymin).x.min_close(shape.pmax.x) and inv_ray.at(tymin).x.max_close(shape.pmin.x)) and (inv_ray.at(tymin).y.min_close(shape.pmax.y) and inv_ray.at(tymin).y.max_close(shape.pmin.y)) and (inv_ray.at(tymin).z.min_close(shape.pmax.z) and inv_ray.at(tymin).z.max_close(shape.pmin.z)):
                ts.add(tymin)
            if (tzmax > inv_ray.tmin and tzmax < inv_ray.tmax)  and (inv_ray.at(tzmax).x.min_close(shape.pmax.x) and inv_ray.at(tzmax).x.max_close(shape.pmin.x)) and (inv_ray.at(tzmax).y.min_close(shape.pmax.y) and inv_ray.at(tzmax).y.max_close(shape.pmin.y)) and (inv_ray.at(tzmax).z.min_close(shape.pmax.z) and inv_ray.at(tzmax).z.max_close(shape.pmin.z)):
                ts.add(tzmax)
                
        if len(ts) == 0: return none(HitRecord)
        
        else:
            ts.sort()
            hit_point = inv_ray.at(ts[0])
            return some(shape.newHitRecord(world_point = shape.transformation * hit_point , 
                            normal = shape.transformation * shape.shape_normal( hit_point, inv_ray.dir ),
                            surface_point = shape.point_to_uv(hit_point),
                            t = ts[0],
                            ray = ray))
    elif shape.kind == ShapesUnion:
        ## Ray intersection for a union of two shapes
    
        var
            hit_point1 = shape.u_shape1.ray_intersection(ray)         # check the first intersection with every shapes
            hit_point2 = shape.u_shape2.ray_intersection(ray)
    
        if hit_point1.isNone and hit_point2.isNone:                 # if the ray doesn't hit nothing -> return none
            return none(HitRecord)
        
        if hit_point1.isNone and hit_point2.isSome:                 # if the ray hits only one of the stwo shapes -> return that hit
            return hit_point2   
        
        if hit_point1.isSome and hit_point2.isNone:
            return hit_point1
        
        if hit_point1.isSome and hit_point2.isSome:                 # if it hits both -> return the closest
            if hit_point1.get().t < hit_point2.get().t:
                return hit_point1
            else:
                return hit_point2
    elif shape.kind == ShapesIntersection:
        ## Ray intersection for an intersection of two shapes
        var
            shape1_ray_intersections = shape.i_shape1.all_ray_intersections(ray)                   # check all the intersection between the ray and the two shapes
            shape2_ray_intersections = shape.i_shape2.all_ray_intersections(ray)
            internal_intersections : seq[HitRecord]
            first_hit : HitRecord
    
        internal_intersections = @[]

        if shape1_ray_intersections.isNone and shape2_ray_intersections.isNone: return none(HitRecord)  # if the ray doesn't hit -> return none

        if shape1_ray_intersections.isSome:                                                             # add the point hitted by the ray only if inside the other shape (we want the intersection)
            for hit in shape1_ray_intersections.get():
                if shape.i_shape2.have_inside(hit.world_point):
                    internal_intersections.add(hit)

        if shape2_ray_intersections.isSome:
            for hit in shape2_ray_intersections.get():
                if shape.i_shape1.have_inside(hit.world_point):
                    internal_intersections.add(hit)

        if len(internal_intersections) == 0: return none(HitRecord)                                     # if the hit points are not inside the other shape -> return none

        first_hit = internal_intersections[0]

        for hit in internal_intersections:                                                              # check the closest
            if hit.t < first_hit.t: 
                first_hit = hit

        return some(first_hit)

    elif shape.kind == ShapesDifference:
        ## Ray intersection for the difference between two shapes (returns only the intersection nearest to the observer)
        var
            hit1 = shape.d_shape1.ray_intersection(ray)
            hit2 = shape.d_shape2.ray_intersection(ray)

        #shape1-shape2=shape1 without points of shapes1 which lie inside shape2 and all the points which lie outside shape1

        if hit1.isNone : return none(HitRecord)

        elif (hit1.isSome and hit2.isNone) or (hit1.get().t <= hit2.get().t) : return hit1

        else :
            var  
                shape1_ray_intersections = shape.d_shape1.all_ray_intersections(ray)
                shape2_ray_intersections = shape.d_shape2.all_ray_intersections(ray)
                diff_intersections : seq[HitRecord]
                first_hit : HitRecord

            diff_intersections = @[]

            if shape1_ray_intersections.isSome:
                for hit in shape1_ray_intersections.get():
                    if not shape.d_shape2.have_inside(hit.world_point):    #have_inside does not consider boundary points
                        diff_intersections.add(hit)

            if shape2_ray_intersections.isSome:
                for hit in shape2_ray_intersections.get():
                    if shape.d_shape1.have_inside(hit.world_point):
                        diff_intersections.add(hit)

            if len(diff_intersections) == 0: return none(HitRecord) 

            first_hit = diff_intersections[0]

            for hit in diff_intersections: 
                if hit.t < first_hit.t: 
                    first_hit = hit

            return some(first_hit)

    else:
        assert false, "Invalid Shape.kind found"
    
proc all_ray_intersections*(shape : Shape, ray : Ray) : Option[seq[HitRecord]] =
    if shape.kind == Sphere:
        ## Compute all the intersections between a ray and a sphere
        var 
            inv_ray = ray.transform(shape.transformation.inverse())
            reduced_delta =  (inv_ray.dir.dot( inv_ray.origin.point_to_vec() ))^2 - inv_ray.dir.squared_norm() * ( inv_ray.origin.point_to_vec.squared_norm() - 1.0 ) 
            t_1 = (-inv_ray.dir.dot( inv_ray.origin.point_to_vec() ) - sqrt( reduced_delta )) / inv_ray.dir.squared_norm()  # compute the two intersection with the sphere
            t_2 = (-inv_ray.dir.dot( inv_ray.origin.point_to_vec() ) + sqrt( reduced_delta )) / inv_ray.dir.squared_norm()
            hits : seq[HitRecord]

        hits = @[]

        if (t_1 < inv_ray.tmin or t_1 > inv_ray.tmax) and (t_2 < inv_ray.tmin or t_2 > inv_ray.tmax) :
            return none(seq[HitRecord])
        
        if t_1 > inv_ray.tmin and t_1 < inv_ray.tmax :
            var hit_point = inv_ray.at(t_1)
            hits.add(shape.newHitRecord( world_point = shape.transformation * hit_point , 
                                   normal = shape.transformation * shape.shape_normal( hit_point, inv_ray.dir ),
                                   surface_point = shape.point_to_uv(hit_point),
                                   t = t_1,
                                   ray = ray    
                                   ) )

        if t_2 > inv_ray.tmin and t_2 < inv_ray.tmax :
            var hit_point = inv_ray.at(t_2)
            hits.add(shape.newHitRecord( world_point = shape.transformation * hit_point , 
                                   normal = shape.transformation * shape.shape_normal( hit_point, inv_ray.dir ),
                                   surface_point = shape.point_to_uv(hit_point),
                                   t = t_2,
                                   ray = ray    
                                   ) )

        return some(hits)

    elif shape.kind == Plane:
        ## Compute all the intersections between a ray and a plane
        var 
            inv_ray = ray.transform(shape.transformation.inverse())
            hits : seq[HitRecord]

        hits = @[]

        if inv_ray.dir.z == 0: return none(seq[HitRecord]) # the ray missed the plane

        var t_hit = - inv_ray.origin.z / inv_ray.dir.z

        if t_hit < ray.tmin or t_hit > ray.tmax : return none(seq[HitRecord]) # the intersection is out of the ray boundaries

        var hit_point = inv_ray.at(t_hit)

        hits.add(shape.newHitRecord( world_point = shape.transformation * hit_point , 
                                   normal = shape.transformation * shape.shape_normal(hit_point, inv_ray.dir ),
                                   surface_point = shape.point_to_uv(hit_point),
                                   t = t_hit,
                                   ray = ray    
                                   ) )
        return some(hits)

    elif shape.kind == Parallelepiped:
        ## Compute the nearest intersection between a ray and a parallelepiped form the observer's pov
        var 
            inv_ray = ray.transform(shape.transformation.inverse())
            #intersections with the planes which form the parallelepiped
            txmin = (shape.pmin.x - inv_ray.origin.x) / inv_ray.dir.x
            txmax = (shape.pmax.x - inv_ray.origin.x) / inv_ray.dir.x
            tymin = (shape.pmin.y - inv_ray.origin.y) / inv_ray.dir.y
            tymax = (shape.pmax.y - inv_ray.origin.y) / inv_ray.dir.y
            tzmin = (shape.pmin.z - inv_ray.origin.z) / inv_ray.dir.z
            tzmax = (shape.pmax.z - inv_ray.origin.z) / inv_ray.dir.z
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
            if (inv_ray.origin.x.max_close(shape.pmin.x) and inv_ray.origin.x.min_close(shape.pmax.x)) and (inv_ray.origin.y.max_close(shape.pmin.y) and inv_ray.origin.y.min_close(shape.pmax.y)):
                if (tzmin > inv_ray.tmin and tzmin < inv_ray.tmax) and (inv_ray.at(tzmin).x.min_close(shape.pmax.x) and inv_ray.at(tzmin).x.max_close(shape.pmin.x)) and (inv_ray.at(tzmin).y.min_close(shape.pmax.y) and inv_ray.at(tzmin).y.max_close(shape.pmin.y)) and (inv_ray.at(tzmin).z.min_close(shape.pmax.z) and inv_ray.at(tzmin).z.max_close(shape.pmin.z)):
                    hit_point = inv_ray.at(tzmin)
                    hits.add(shape.newHitRecord(world_point = shape.transformation * hit_point , 
                            normal = shape.transformation * shape.shape_normal( hit_point, inv_ray.dir ),
                            surface_point = shape.point_to_uv(hit_point),
                            t = tzmin,
                            ray = ray) )
                if (tzmax > inv_ray.tmin and tzmax < inv_ray.tmax) and (inv_ray.at(tzmax).x.min_close(shape.pmax.x) and inv_ray.at(tzmax).x.max_close(shape.pmin.x)) and (inv_ray.at(tzmax).y.min_close(shape.pmax.y) and inv_ray.at(tzmax).y.max_close(shape.pmin.y)) and (inv_ray.at(tzmax).z.min_close(shape.pmax.z) and inv_ray.at(tzmax).z.max_close(shape.pmin.z)):
                    hit_point = inv_ray.at(tzmax)
                    hits.add(shape.newHitRecord(world_point = shape.transformation * hit_point , 
                            normal = shape.transformation * shape.shape_normal( hit_point, inv_ray.dir ),
                            surface_point = shape.point_to_uv(hit_point),
                            t = tzmax,
                            ray = ray) )
                return some(hits)
            else :
                return none(seq[HitRecord])

        if inv_ray.dir.z.is_close(0.0) and inv_ray.dir.y.is_close(0.0) :
            #Ray parallel to x
            if (inv_ray.origin.y.max_close(shape.pmin.y) and inv_ray.origin.y.min_close(shape.pmax.y)) and (inv_ray.origin.z.max_close(shape.pmin.z) and inv_ray.origin.z.min_close(shape.pmax.z)) :
                if (txmin > inv_ray.tmin and txmin < inv_ray.tmax) and (inv_ray.at(txmin).x.min_close(shape.pmax.x) and inv_ray.at(txmin).x.max_close(shape.pmin.x)) and (inv_ray.at(txmin).y.min_close(shape.pmax.y) and inv_ray.at(txmin).y.max_close(shape.pmin.y)) and (inv_ray.at(txmin).z.min_close(shape.pmax.z) and inv_ray.at(txmin).z.max_close(shape.pmin.z)):
                    hit_point = inv_ray.at(txmin)
                    hits.add(shape.newHitRecord(world_point = shape.transformation * hit_point , 
                            normal = shape.transformation * shape.shape_normal( hit_point, inv_ray.dir ),
                            surface_point = shape.point_to_uv(hit_point),
                            t = txmin,
                            ray = ray) )
                if (txmax > inv_ray.tmin and txmax < inv_ray.tmax) and (inv_ray.at(txmax).x.min_close(shape.pmax.x) and inv_ray.at(txmax).x.max_close(shape.pmin.x)) and (inv_ray.at(txmax).y.min_close(shape.pmax.y) and inv_ray.at(txmax).y.max_close(shape.pmin.y)) and (inv_ray.at(txmax).z.min_close(shape.pmax.z) and inv_ray.at(txmax).z.max_close(shape.pmin.z)):
                    hit_point = inv_ray.at(txmax)
                    hits.add(shape.newHitRecord(world_point = shape.transformation * hit_point , 
                            normal = shape.transformation * shape.shape_normal( hit_point, inv_ray.dir ),
                            surface_point = shape.point_to_uv(hit_point),
                            t = txmax,
                            ray = ray) )
                return some(hits)
            else :
                return none(seq[HitRecord]) 

        if inv_ray.dir.x.is_close(0.0) and inv_ray.dir.z.is_close(0.0) :
            #Ray parallel to y
            if (inv_ray.origin.x.max_close(shape.pmin.x) and inv_ray.origin.x.min_close(shape.pmax.x)) and (inv_ray.origin.z.max_close(shape.pmin.z) and inv_ray.origin.z.min_close(shape.pmax.z)) :
                if (tymin > inv_ray.tmin and tymin < inv_ray.tmax) and (inv_ray.at(tymin).x.min_close(shape.pmax.x) and inv_ray.at(tymin).x.max_close(shape.pmin.x)) and (inv_ray.at(tymin).y.min_close(shape.pmax.y) and inv_ray.at(tymin).y.max_close(shape.pmin.y)) and (inv_ray.at(tymin).z.min_close(shape.pmax.z) and inv_ray.at(tymin).z.max_close(shape.pmin.z)):
                    hit_point = inv_ray.at(tymin)
                    hits.add(shape.newHitRecord(world_point = shape.transformation * hit_point , 
                            normal = shape.transformation * shape.shape_normal( hit_point, inv_ray.dir ),
                            surface_point = shape.point_to_uv(hit_point),
                            t = tymin,
                            ray = ray) )
                if (tymax > inv_ray.tmin and tymax < inv_ray.tmax) and (inv_ray.at(tymax).x.min_close(shape.pmax.x) and inv_ray.at(tymax).x.max_close(shape.pmin.x)) and (inv_ray.at(tymax).y.min_close(shape.pmax.y) and inv_ray.at(tymax).y.max_close(shape.pmin.y)) and (inv_ray.at(tymax).z.min_close(shape.pmax.z) and inv_ray.at(tymax).z.max_close(shape.pmin.z)):
                    hit_point = inv_ray.at(tymax)
                    hits.add(shape.newHitRecord(world_point = shape.transformation * hit_point , 
                            normal = shape.transformation * shape.shape_normal( hit_point, inv_ray.dir ),
                            surface_point = shape.point_to_uv(hit_point),
                            t = tymax,
                            ray = ray) )
                return some(hits)
            else :
                return none(seq[HitRecord]) 

        #I look at x and y with z fixed, then I check on z
        if txmin.min_close(tymin) and tymin.min_close(txmax):
            if (tymin > inv_ray.tmin and tymin < inv_ray.tmax) and (inv_ray.at(tymin).x.min_close(shape.pmax.x) and inv_ray.at(tymin).x.max_close(shape.pmin.x)) and (inv_ray.at(tymin).y.min_close(shape.pmax.y) and inv_ray.at(tymin).y.max_close(shape.pmin.y)) and (inv_ray.at(tymin).z.min_close(shape.pmax.z) and inv_ray.at(tymin).z.max_close(shape.pmin.z)):
                ts.add(tymin)
            if (txmax > inv_ray.tmin and txmax < inv_ray.tmax) and (inv_ray.at(txmax).x.min_close(shape.pmax.x) and inv_ray.at(txmax).x.max_close(shape.pmin.x)) and (inv_ray.at(txmax).y.min_close(shape.pmax.y) and inv_ray.at(txmax).y.max_close(shape.pmin.y)) and (inv_ray.at(txmax).z.min_close(shape.pmax.z) and inv_ray.at(txmax).z.max_close(shape.pmin.z)):
                ts.add(txmax)

        elif tymin < txmin and txmin.min_close(tymax):  #Works in the same way as the if indented like this elif
            if (txmin > inv_ray.tmin and txmin < inv_ray.tmax) and (inv_ray.at(txmin).x.min_close(shape.pmax.x) and inv_ray.at(txmin).x.max_close(shape.pmin.x)) and (inv_ray.at(txmin).y.min_close(shape.pmax.y) and inv_ray.at(txmin).y.max_close(shape.pmin.y)) and (inv_ray.at(txmin).z.min_close(shape.pmax.z) and inv_ray.at(txmin).z.max_close(shape.pmin.z)):
                ts.add(txmin)
            if (tymax > inv_ray.tmin and tymax < inv_ray.tmax) and (inv_ray.at(tymax).x.min_close(shape.pmax.x) and inv_ray.at(tymax).x.max_close(shape.pmin.x)) and (inv_ray.at(tymax).y.min_close(shape.pmax.y) and inv_ray.at(tymax).y.max_close(shape.pmin.y)) and (inv_ray.at(tymax).z.min_close(shape.pmax.z) and inv_ray.at(tymax).z.max_close(shape.pmin.z)):
                ts.add(tymax)

        #Now I fix y at first to look at x,z
        if txmin.min_close(tzmin) :
            if (tzmin > inv_ray.tmin and tzmin < inv_ray.tmax) and (inv_ray.at(tzmin).x.min_close(shape.pmax.x) and inv_ray.at(tzmin).x.max_close(shape.pmin.x)) and (inv_ray.at(tzmin).y.min_close(shape.pmax.y) and inv_ray.at(tzmin).y.max_close(shape.pmin.y)) and (inv_ray.at(tzmin).z.min_close(shape.pmax.z) and inv_ray.at(tzmin).z.max_close(shape.pmin.z)):
                ts.add(tzmin)
            if (txmax > inv_ray.tmin and txmax < inv_ray.tmax) and (inv_ray.at(txmax).x.min_close(shape.pmax.x) and inv_ray.at(txmax).x.max_close(shape.pmin.x)) and (inv_ray.at(txmax).y.min_close(shape.pmax.y) and inv_ray.at(txmax).y.max_close(shape.pmin.y)) and (inv_ray.at(txmax).z.min_close(shape.pmax.z) and inv_ray.at(txmax).z.max_close(shape.pmin.z)):
                ts.add(txmax)
        elif tzmin < txmin :  #Works in the same way as the last if indented like this elif
            if (txmin > inv_ray.tmin and txmin < inv_ray.tmax) and (inv_ray.at(txmin).x.min_close(shape.pmax.x) and inv_ray.at(txmin).x.max_close(shape.pmin.x)) and (inv_ray.at(txmin).y.min_close(shape.pmax.y) and inv_ray.at(txmin).y.max_close(shape.pmin.y)) and (inv_ray.at(txmin).z.min_close(shape.pmax.z) and inv_ray.at(txmin).z.max_close(shape.pmin.z)):
                ts.add(txmin)
            if (tzmax > inv_ray.tmin and tzmax < inv_ray.tmax)  and (inv_ray.at(tzmax).x.min_close(shape.pmax.x) and inv_ray.at(tzmax).x.max_close(shape.pmin.x)) and (inv_ray.at(tzmax).y.min_close(shape.pmax.y) and inv_ray.at(tzmax).y.max_close(shape.pmin.y)) and (inv_ray.at(tzmax).z.min_close(shape.pmax.z) and inv_ray.at(tzmax).z.max_close(shape.pmin.z)):
                ts.add(tzmax)

        #Now I fix x at first to look at y,z
        if tymin.min_close(tzmin) :
            if (tzmin > inv_ray.tmin and tzmin < inv_ray.tmax) and (inv_ray.at(tzmin).x.min_close(shape.pmax.x) and inv_ray.at(tzmin).x.max_close(shape.pmin.x)) and (inv_ray.at(tzmin).y.min_close(shape.pmax.y) and inv_ray.at(tzmin).y.max_close(shape.pmin.y)) and (inv_ray.at(tzmin).z.min_close(shape.pmax.z) and inv_ray.at(tzmin).z.max_close(shape.pmin.z)):
                ts.add(tzmin)
            if (tymax > inv_ray.tmin and tymax < inv_ray.tmax) and (inv_ray.at(tymax).x.min_close(shape.pmax.x) and inv_ray.at(tymax).x.max_close(shape.pmin.x)) and (inv_ray.at(tymax).y.min_close(shape.pmax.y) and inv_ray.at(tymax).y.max_close(shape.pmin.y)) and (inv_ray.at(tymax).z.min_close(shape.pmax.z) and inv_ray.at(tymax).z.max_close(shape.pmin.z)):
                ts.add(tymax)
        elif tzmin < tymin :  #Works in the same way as the last if indented like this elif
            if (tymin > inv_ray.tmin and tymin < inv_ray.tmax) and (inv_ray.at(tymin).x.min_close(shape.pmax.x) and inv_ray.at(tymin).x.max_close(shape.pmin.x)) and (inv_ray.at(tymin).y.min_close(shape.pmax.y) and inv_ray.at(tymin).y.max_close(shape.pmin.y)) and (inv_ray.at(tymin).z.min_close(shape.pmax.z) and inv_ray.at(tymin).z.max_close(shape.pmin.z)):
                ts.add(tymin)
            if (tzmax > inv_ray.tmin and tzmax < inv_ray.tmax)  and (inv_ray.at(tzmax).x.min_close(shape.pmax.x) and inv_ray.at(tzmax).x.max_close(shape.pmin.x)) and (inv_ray.at(tzmax).y.min_close(shape.pmax.y) and inv_ray.at(tzmax).y.max_close(shape.pmin.y)) and (inv_ray.at(tzmax).z.min_close(shape.pmax.z) and inv_ray.at(tzmax).z.max_close(shape.pmin.z)):
                ts.add(tzmax)

        if len(ts) == 0: return none(seq[HitRecord])

        ts.sort()
        hit_point = inv_ray.at(ts[0])
        hits.add(shape.newHitRecord(world_point = shape.transformation * hit_point , 
                            normal = shape.transformation * shape.shape_normal( hit_point, inv_ray.dir ),
                            surface_point = shape.point_to_uv(hit_point),
                            t = ts[0],
                            ray = ray))
        hit_point = inv_ray.at(ts[1])
        hits.add(shape.newHitRecord(world_point = shape.transformation * hit_point , 
                            normal = shape.transformation * shape.shape_normal( hit_point, inv_ray.dir ),
                            surface_point = shape.point_to_uv(hit_point),
                            t = ts[1],
                            ray = ray))
        return some(hits)

    elif shape.kind == ShapesUnion:
        ## Compute all the intersection of a ray with an union of shapes
        ## 
        var
            hit_points1 = shape.u_shape1.all_ray_intersections(ray)   # check all the intersections with every shapes
            hit_points2 = shape.u_shape2.all_ray_intersections(ray)
            hit_points : seq[HitRecord]

        hit_points = @[]

        if hit_points1.isNone and hit_points2.isNone:               # if no hit -> return none
            return none(seq[HitRecord])
        
        if hit_points1.isSome:                                      # when the ray hits a shape -> add the point olny if it is not inside the other shape (union wants only the external hits)
            for hit in hit_points1.get():
                if not shape.u_shape2.have_inside(hit.world_point):
                    hit_points.add(hit)

        if hit_points2.isSome:
            for hit in hit_points2.get():
                if not shape.u_shape1.have_inside(hit.world_point):
                    hit_points.add(hit)

        return some(hit_points)

    elif shape.kind == ShapesIntersection:
        ## Compute all the intersection of a ray with an union of shapes
    
        var
            hit_points1 = shape.i_shape1.all_ray_intersections(ray)         # this function does the same as ray_intersection for Shapes_Intersection and return all the inner hit poits
            hit_points2 = shape.i_shape2.all_ray_intersections(ray)         # without checking which is the closest
            hit_points : seq[HitRecord]

        hit_points = @[]

        if hit_points1.isNone and hit_points2.isNone:
            return none(seq[HitRecord])
        
        if hit_points1.isSome:
            for hit in hit_points1.get():
                if shape.i_shape2.have_inside(hit.world_point):
                    hit_points.add(hit)

        if hit_points2.isSome:
            for hit in hit_points2.get():
                if shape.i_shape1.have_inside(hit.world_point):
                    hit_points.add(hit)

        return some(hit_points)

    elif shape.kind == ShapesDifference:
        ## Compute all the intersections of a ray with an difference of shapes
        var
            hit1 = shape.d_shape1.ray_intersection(ray)

        #shape1-shape2=shape1 without points of shapes1 which lie inside shape2 and all the points which lie outside shape1

        if hit1.isNone : return none(seq[HitRecord])

        else :
            var  
                shape1_ray_intersections = shape.d_shape1.all_ray_intersections(ray)
                shape2_ray_intersections = shape.d_shape2.all_ray_intersections(ray)
                diff_intersections : seq[HitRecord]
                first_hit : HitRecord

            diff_intersections = @[]

            if shape1_ray_intersections.isSome:
                for hit in shape1_ray_intersections.get():
                    if not shape.d_shape2.have_inside(hit.world_point):    #have_inside does not consider boundary points
                        diff_intersections.add(hit)

            if shape2_ray_intersections.isSome:
                for hit in shape2_ray_intersections.get():
                    if shape.d_shape1.have_inside(hit.world_point):
                        diff_intersections.add(hit)

            if len(diff_intersections) == 0: return none(seq[HitRecord]) 
            return some(diff_intersections)

    else:
        assert false, "Invalid Shape.kind found"
        
proc have_inside*( shape : Shape, point : Point) : bool =
    if shape.kind == Sphere :
        ## Check if a point is inside a sphere
        var inv_point = point_to_vec( shape.transformation.inverse() * point )

        if inv_point.squared_norm() < 1:
            return true
        else:
            return false
    elif shape.kind == Plane :
        ## Check if a point is inside a plane -> mean that the point z is negative
        var inv_point = shape.transformation.inverse() * point
        if inv_point.z < 0 :
            return true
        else: 
            return false
    elif shape.kind == Parallelepiped :
        ## Check if a point is inside a parallelepiped 
        var inv_point = shape.transformation.inverse() * point
        if (inv_point.x > shape.pmin.x and inv_point.x < shape.pmax.x) and (inv_point.y > shape.pmin.y and inv_point.y < shape.pmax.y) and (inv_point.z > shape.pmin.z and inv_point.z < shape.pmax.z) :
            return true
        else:
            return false
    elif shape.kind == ShapesUnion:
        ## Compute if an union of shapes have inside a point
        if shape.u_shape1.have_inside(point) or shape.u_shape2.have_inside(point):  # simple logic operation
            return true
        else:
            return false
    elif shape.kind == ShapesIntersection:
        ## Check if a point is inside an intersection of shapes
        if shape.i_shape1.have_inside(point) and shape.i_shape2.have_inside(point):        # simple logic operation 
            return true
        else:
            return false
    elif shape.kind == ShapesDifference:
        ## Check if a point is inside a difference between shape1 and shape2
        if shape.d_shape1.have_inside(point) and not shape.d_shape2.have_inside(point):        # simple logic operation 
            return true
        else:
            return false
    else:
        assert false, "Invalid Shape.kind found"

