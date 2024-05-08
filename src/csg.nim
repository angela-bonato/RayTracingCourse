## Implementation of Constructive Solid Geometry (CGS) to create complcate shapes

import world # to import shapes with no problems
import ray
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
        hit_point1 = union.shape1.ray_intersection(ray)
        hit_point2 = union.shape2.ray_intersection(ray)

    if hit_point1.isNone and hit_point2.isNone:
        return none(HitRecord)

    if hit_point1.isNone and hit_point2.isSome:
        return hit_point2

    if hit_point1.isSome and hit_point2.isNone:
        return hit_point1

    if hit_point1.isSome and hit_point2.isSome:
        if hit_point1.get().t < hit_point2.get().t:
            return hit_point1
        else:
            return hit_point2

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
        shape1_ray_intersections = intersection.shape1.all_ray_intersections(ray)
        shape2_ray_intersections = intersection.shape2.all_ray_intersections(ray)
        internal_intersections : seq[HitRecord]
        first_hit : HitRecord
    
    internal_intersections = @[]

    if shape1_ray_intersections.isNone and shape2_ray_intersections.isNone: return none(HitRecord)

    if shape1_ray_intersections.isSome:
        for hit in shape1_ray_intersections.get():
            if intersection.shape2.have_inside(hit.world_point):
                internal_intersections.add(hit)

    if shape2_ray_intersections.isSome:
        for hit in shape2_ray_intersections.get():
            if intersection.shape1.have_inside(hit.world_point):
                internal_intersections.add(hit)

    if len(internal_intersections) == 0: return none(HitRecord)

    first_hit = internal_intersections[0]

    for hit in internal_intersections:
        if hit.t < first_hit.t:
            first_hit = hit
    
    return some(first_hit)

