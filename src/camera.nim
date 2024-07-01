## Implementation of the Camera type and its metods. It represent the camera size and orientation, using both Ortogonal and Perspective way to see the scene.

import geometry
import ray

# Camera type declaration

type Camera* = object 
    aspect_ratio* : float
    distance* : float
    transform* : Transformation

# Camera type constructors

proc newCamera*(aspect_ratio = 1.0, distance = 1.0, transform = newTransformation()) : Camera =
    ## Hybrid onstructor: when a value is passed as argument it is assigned as defined calling the constructor, when it is not passed the constructor uses the default value. 
    result.aspect_ratio = aspect_ratio
    result.distance = distance
    result.transform = transform

    return result

# Fire Ray Procs definition (useful for the two views we want to implement)

type FireRayProcs* = proc (cam: Camera, u,v : float) : Ray {.closure.}     #typical proc to fire a ray that hit the coordinate (u,v) of the camera

# Fire Ray Procs definitions

proc fire_ray_orthogonal*(cam: Camera, u,v : float) : Ray =
    ## Fire rays to obtain orthogonal projection (all the rays are parallel and they are perpendicular to the camera schreen)
    var
        origin = newPoint( -1.0, (1.0 - 2*u) * cam.aspect_ratio, 2*v-1 )
        direction = newVector( 1.0, 0.0, 0.0 )

    return newRay(origin, direction).transform( cam.transform )

proc fire_ray_perspective*(cam: Camera, u,v : float) : Ray =
    ## Fire rays to obtain prospective view (all the rays start from a common poin: the viewer position)
    var 
        origin = newPoint( -cam.distance, 0.0, 0.0)
        direction = newVector( cam.distance, (1.0 - 2 * u) * cam.aspect_ratio, 2 * v - 1)

    return newRay(origin, direction).transform( cam.transform )