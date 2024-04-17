## Definition of Ray type and its methods. In a backword ray-tracing prospective, each ray object represents a light ray that the camera sends onto the screen (i.e., the image).

import point
import vector
import geometryalgebra
import transformation

#Ray type declaration

type Ray* = object   # It needs to be fast so I use stack memory
    ## Ray type declaration
    origin*: Point  # Origin point of the ray
    dir*: Vector    # Direction in which the ray points
    tmin*, tmax*: float32   # Minimum and maximum distance spanned by the ray
    depth*: int # Number of bouncings that the ray can perform

# Ray type constructors

proc newRay*(origin : Point, dir : Vector, depth = 0, tmin = 1e-5, tmax = Inf): Ray =       
    ## Ray constructor is declared in a way that allows both having default values for tmin, tmax and depth while taking origin and dir as arguments, and specifying also the constant values as arguments.
    result.origin = origin
    result.dir = dir
    result.depth = depth    # If not specified in the arguments, takes default value 0
    result.tmin = tmin      # If not specified in the arguments, takes default value 1e-5
    result.tmax = tmax      # If not specified in the arguments, takes default value +inf
    return result

# Usefull methods for Ray class

proc is_close*(ray1, ray2 : Ray): bool =
    ## is_close version for comparaisons between rays. For two rays to be equal, is enought for them to have same origin and dir.
    return (is_close(ray1.origin, ray2.origin)) and (is_close(ray1.dir, ray2.dir))  # We can use is_close methods defined for Point and Vector objects

proc at*(ray : Ray, t : float): Point =
    ## Returns the point in which the ray falls after a length t from its origin, along its direction.
    return ray.origin + ray.dir * t   # We defined these operations in Point and Vector algebra

proc transform*(ray : Ray, tr : Transformation): Ray =
    ## Action of a trasformation on a ray.
    return newRay(tr * ray.origin,tr * ray.dir,   # A trasformation acts only on the ray origin and direction
                    ray.depth, ray.tmin, ray.tmax)