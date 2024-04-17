## Implementation of the Camera type and its metods. It represent the camera size and orientation, using both Ortogonal and Perspective way to see the scene.

import transformation
import ray
import vector
import point

# Camera type declaration

type Camera* = object 
    aspect_ratio* : float
    distance* : float
    transform* : Transformation

# Camera type constructors

proc newCamera*() : Camera =
    ## Empty constructor, set variables to default values
    result.aspect_ratio = 1.0
    result.distance = 1.0
    result.transform = newTransformation()

    return result

proc newCamera*( aspect_ratio : float, distance: float, transform : Transformation ) : Camera =
    ## Constructor with elements, set the variables to given values
    result.aspect_ratio = aspect_ratio
    result.distance = distance
    result.transform = transform

    return result

# Fire Ray Procs definition (useful for the two views we want to implement)

type FireRayProcs* = proc (cam: Camera, u,v : float) : Ray {.closure.}

# Fire Ray Procs definitions

proc fire_ray_orthogonal*(cam: Camera, u,v : float) : Ray =
    ## Fire rays to obtain orthogonal projection 
    var
        origin = newPoint( -1.0, (1.0 - 2*u) * cam.aspect_ratio, 2*v-1 )
        direction = newVector( 1.0, 0.0, 0.0 )

    return newRay(origin, direction).transform( cam.transform )

proc fire_ray_perspective*(cam: Camera, u,v : float) : Ray =
    ## Fire rays to obtain prospective view
    var 
        origin = newPoint( -cam.distance, 0.0, 0.0)
        direction = newVector( cam.distance, (1.0 - 2 * u) * cam.aspect_ratio, 2 * v - 1)

    return newRay(origin, direction).transform( cam.transform )