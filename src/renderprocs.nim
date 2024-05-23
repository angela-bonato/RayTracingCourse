## Here we deefine all the procs in the class SolveRenderingProcs

import world
#import shapes
import color
import vector
import normal
import materials
import std/options
import std/math

# Definition of the possible rendering procs  

type SolveRenderingProcs* = proc (hit : Option[HitRecord]) : Color {.closure.}
## Definition of the proc type used by imagetracer

proc solverendproc*(hit: Option[HitRecord]): Color =
    ##Just a temporary proc which inherit from SolveRenderingProcs type, to be used in tests/test_5.nim
    return newColor(1.0, 2.0, 3.0)

proc OnOffTracer*(hit : Option[HitRecord]) : Color =
  ## This proc is used to determine the color of each pixel based on what the input ray hit
  if (hit.isNone) :
    return newColor(0, 0, 0)  #The background will be black
  else:
    return newColor(255, 255, 255)  #The spheres will be white

proc FlatRenderer*(hit : Option[HitRecord], background_color = newColor(0,0,0)) : Color =
  ## A «flat» renderer
  ## This renderer estimates the solution of the rendering equation by neglecting any contribution of the light.
  ## It just uses the pigment of each surface to determine how to compute the final radiance.
  
  if (hit.isNone) :
    return background_color
  else:
    return hit.get().shape.material.brdf.pigment.get_color(hit.get().surface_point) + hit.get().shape.material.emitted_radiance.get_color(hit.get().surface_point)