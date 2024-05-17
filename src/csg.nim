## Implementation of Constructive Solid Geometry (CGS) to create complcate shapes

import world # to import shapes with no problems
import ray
import point
import std/options

# Defining shapes union

type Shapes_Union* = ref object of Shape
    shape1*, shape2* : Shape

proc unite*(shape1, shape2 : Shape ) : Shapes_Union =
    ## Unite two shapes
    new(result)
    result.shape1 = shape1
    result.shape2 = shape2

method ray_intersection*(union : Shapes_Union, ray : Ray) : Option[HitRecord] =
    ## Ray intersection for a union of two shapes
    
    var
        hit_point1 = union.shape1.ray_intersection(ray)         # check the first intersection with every shapes
        hit_point2 = union.shape2.ray_intersection(ray)

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

method all_ray_intersections*(union: Shapes_Union, ray : Ray) : Option[seq[HitRecord]] =
    ## Compute all the intersection of a ray with an union of shapes
    
    var
        hit_points1 = union.shape1.all_ray_intersections(ray)   # check all the intersections with every shapes
        hit_points2 = union.shape2.all_ray_intersections(ray)
        hit_points : seq[HitRecord]
    
    hit_points = @[]

    if hit_points1.isNone and hit_points2.isNone:               # if no hit -> return none
        return none(seq[HitRecord])
    
    if hit_points1.isSome:                                      # when the ray hits a shape -> add the point olny if it is not inside the other shape (union wants only the external hits)
        for hit in hit_points1.get():
            if not union.shape2.have_inside(hit.world_point):
                hit_points.add(hit)

    if hit_points2.isSome:
        for hit in hit_points2.get():
            if not union.shape1.have_inside(hit.world_point):
                hit_points.add(hit)

    return some(hit_points)

method have_inside*(union: Shapes_Union, point : Point) : bool =
    ## Compute if an union of shapes have inside a point
    
    if union.shape1.have_inside(point) or union.shape2.have_inside(point):  # simple logic operation
        return true
    else:
        return false

# Define shapes intersection

type Shapes_Intersection* = ref object of Shape 
    shape1*, shape2 : Shape

proc intersect*(shape1, shape2 : Shape) : Shapes_Intersection =
    ## Intersect two shapes
    new(result)
    result.shape1 = shape1
    result.shape2 = shape2

method ray_intersection*(intersection : Shapes_Intersection, ray : Ray) : Option[HitRecord] =
    ## Ray intersection for an intersection of two shapes
    var
        shape1_ray_intersections = intersection.shape1.all_ray_intersections(ray)                   # check all the intersection between the ray and the two shapes
        shape2_ray_intersections = intersection.shape2.all_ray_intersections(ray)
        internal_intersections : seq[HitRecord]
        first_hit : HitRecord
    
    internal_intersections = @[]

    if shape1_ray_intersections.isNone and shape2_ray_intersections.isNone: return none(HitRecord)  # if the ray doesn't hit -> return none

    if shape1_ray_intersections.isSome:                                                             # add the point hitted by the ray only if inside the other shape (we want the intersection)
        for hit in shape1_ray_intersections.get():
            if intersection.shape2.have_inside(hit.world_point):
                internal_intersections.add(hit)

    if shape2_ray_intersections.isSome:
        for hit in shape2_ray_intersections.get():
            if intersection.shape1.have_inside(hit.world_point):
                internal_intersections.add(hit)

    if len(internal_intersections) == 0: return none(HitRecord)                                     # if the hit points are not inside the other shape -> return none

    first_hit = internal_intersections[0]

    for hit in internal_intersections:                                                              # check the closest
        if hit.t < first_hit.t: 
            first_hit = hit
    
    return some(first_hit)

method all_ray_intersections*(intersection : Shapes_Intersection, ray : Ray) : Option[seq[HitRecord]] =
    ## Compute all the intersection of a ray with an union of shapes
    
    var
        hit_points1 = intersection.shape1.all_ray_intersections(ray)         # this function does the same as ray_intersection for Shapes_Intersection and return all the inner hit poits
        hit_points2 = intersection.shape2.all_ray_intersections(ray)         # without checking which is the closest
        hit_points : seq[HitRecord]
    
    hit_points = @[]

    if hit_points1.isNone and hit_points2.isNone:
        return none(seq[HitRecord])
    
    if hit_points1.isSome:
        for hit in hit_points1.get():
            if intersection.shape2.have_inside(hit.world_point):
                hit_points.add(hit)

    if hit_points2.isSome:
        for hit in hit_points2.get():
            if intersection.shape1.have_inside(hit.world_point):
                hit_points.add(hit)

    return some(hit_points)

method have_inside*(intersection : Shapes_Intersection, point : Point) : bool = 
    ## Check if a point is inside an intersection of shapes
    
    if intersection.shape1.have_inside(point) and intersection.shape2.have_inside(point):        # simple logic operation 
        return true
    else:
        return false

# Define shapes difference

type Shapes_Difference* = ref object of Shape 
    shape1*, shape2 : Shape

proc subtract*(shape1, shape2 : Shape) : Shapes_Difference =
    ## Returns the difference between two shapes (shape1-shape2, it is not commutative)
    new(result)
    result.shape1 = shape1
    result.shape2 = shape2

method ray_intersection*(difference : Shapes_Difference, ray : Ray) : Option[HitRecord] =
    ## Ray intersection for the difference between two shapes (returns only the intersection nearest to the observer)
    var
        hit1 = difference.shape1.ray_intersection(ray)
        hit2 = difference.shape2.ray_intersection(ray)
    
    #shape1-shape2=shape1 without points of shapes1 which lie inside shape2 and all the points which lie outside shape1

    if hit1.isNone : return none(HitRecord)

    elif (hit1.get().t <= hit2.get().t) or (hit1.isSome and hit2.isNone) : return hit1
    
    else :
        var  
            shape1_ray_intersections = difference.shape1.all_ray_intersections(ray)
            shape2_ray_intersections = difference.shape2.all_ray_intersections(ray)
            diff_intersections : seq[HitRecord]
            first_hit : HitRecord
    
        diff_intersections = @[]

        if shape1_ray_intersections.isSome:
            for hit in shape1_ray_intersections.get():
                if not difference.shape2.have_inside(hit.world_point):    #have_inside does not consider boundary points
                    diff_intersections.add(hit)
        
        if shape2_ray_intersections.isSome:
            for hit in shape2_ray_intersections.get():
                if difference.shape1.have_inside(hit.world_point):
                    diff_intersections.add(hit)

        if len(diff_intersections) == 0: return none(HitRecord) 

        first_hit = diff_intersections[0]

        for hit in diff_intersections: 
            if hit.t < first_hit.t: 
                first_hit = hit
    
        return some(first_hit)

method all_ray_intersections*(difference : Shapes_Difference, ray : Ray) : Option[seq[HitRecord]] =
    ## Compute all the intersections of a ray with an difference of shapes
    var
        hit1 = difference.shape1.ray_intersection(ray)
        
    #shape1-shape2=shape1 without points of shapes1 which lie inside shape2 and all the points which lie outside shape1

    if hit1.isNone : return none(seq[HitRecord])

    else :
        var  
            shape1_ray_intersections = difference.shape1.all_ray_intersections(ray)
            shape2_ray_intersections = difference.shape2.all_ray_intersections(ray)
            diff_intersections : seq[HitRecord]
            first_hit : HitRecord
    
        diff_intersections = @[]

        if shape1_ray_intersections.isSome:
            for hit in shape1_ray_intersections.get():
                if not difference.shape2.have_inside(hit.world_point):    #have_inside does not consider boundary points
                    diff_intersections.add(hit)
        
        if shape2_ray_intersections.isSome:
            for hit in shape2_ray_intersections.get():
                if difference.shape1.have_inside(hit.world_point):
                    diff_intersections.add(hit)

        if len(diff_intersections) == 0: return none(seq[HitRecord]) 
        return some(diff_intersections)

method have_inside*(difference : Shapes_Difference, point : Point) : bool = 
    ## Check if a point is inside a difference between shape1 and shape2
    if difference.shape1.have_inside(point) and not difference.shape2.have_inside(point):        # simple logic operation 
        return true
    else:
        return false

