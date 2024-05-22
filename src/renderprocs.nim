## Here we deefine all the procs in the class SolveRenderingProcs

import world
import color
import std/options

type SolveRenderingProcs* = proc (hit : Option[HitRecord]) : Color {.closure.}
## Definition of the proc type used by imagetracer

proc solverendproc*(hit: Option[HitRecord]): Color =
    ##Just a temporary proc which inherit from SolveRenderingProcs type, to be used in tests/test_5.nim
    return newColor(1.0, 2.0, 3.0)

proc OnOffTracer*(hit : Option[HitRecord], back_color = newColor(0, 0, 0), hit_color = newColor(255, 255, 255)) : Color =
  ## This proc is used to determine the color of each pixel based on what the input ray hit
  if (hit.isNone) :
    return back_color  #The background will be black if default is used
  else:
    return hit_color  #The spheres will be white if default is used

#Da sistemaree
