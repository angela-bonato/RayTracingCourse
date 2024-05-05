## Implementation of the world type with its methods. It is used to build the scene when producing an image

include std/sequtils
include shapes

# Declaration and constructor

type World* = ref object
    ## It is a list of all the shapes in the image
    shapes* : seq[Shape]

proc newWorld*() : World =
    ## Empty constructor
    new(result)
    result.shapes = newSeq[Shapes](0)
    return result

# Methods

proc add(scene: World, shape: Shape) : void =
    ## Used to add a new shape to the list
    add(World.shapes, shape)   #add() 

proc ray_intersection*(scene: World, ray:Ray) : Option[HitRecord]:
    ## Iteration of all the shapes in the scene to search for intersection and find the closest ones 
    var 
        closest, intersection : Option[HitRecord]

    for shape in World.shapes :
        intersection = shape.ray_intersection(ray)

        if intersection.isNone :
            continue

        if (closest.isNone) or (intersection.t < closest.t):
            closest = intersection 

    return closest