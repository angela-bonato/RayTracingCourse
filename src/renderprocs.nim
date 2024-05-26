## Here we deefine all the procs in the class SolveRenderingProcs

import color
import materials
import pcg
import ray
import shapes
import std/options

# Definition of the possible rendering procs  

type SolveRenderingProcs* = proc (hit : Option[HitRecord]) : Color {.closure.}
## Definition of the proc type used by imagetracer

proc solverendproc*(hit: Option[HitRecord]): Color =
    ##Just a temporary proc which inherit from SolveRenderingProcs type, to be used in tests/test_5.nim
    return newColor(1.0, 2.0, 3.0)

proc OnOffRenderer*(hit : Option[HitRecord], background_color = newColor(0, 0, 0), hit_color = newColor(255, 255, 255)) : Color =
  ## This proc is used to determine the color of each pixel based on what the input ray hit
  if (hit.isNone) :
    return background_color  #The background will be black if default is used
  else:
    return hit_color  #The spheres will be white if default is used

proc FlatRenderer*(hit : Option[HitRecord], background_color = newColor(0,0,0)) : Color =
  ## A «flat» renderer
  ## This renderer estimates the solution of the rendering equation by neglecting any contribution of the light.
  ## It just uses the pigment of each surface to determine how to compute the final radiance.
  
  if (hit.isNone) :
    return background_color
  else:
    return hit.get().shape.material.brdf.pigment.get_color(hit.get().surface_point) + hit.get().shape.material.emitted_radiance.get_color(hit.get().surface_point)

proc PathTracer*(hit: Option[HitRecord], background_color = newColor(0,0,0), pcg: var Pcg, n_rays: int, max_depth: int, lim_depth: int, ray: Ray) : Color =
  ## The real reay-tracer algorithm
  if ray.depth > max_depth :
    return newColor(0,0,0)

  if hit.isNone :
    return background_color

  var 
    hit_material = hit.get().shape.material
    hit_color = hit_material.brdf.pigment.get_color(hit.get().surface_point)
    emitted_rad = hit_material.emitted_radiance.get_color(hit.get().surface_point)
    hit_col_lum = max(max(hit_color.r, hit_color.g), hit_color.b)

  if ray.depth >= lim_depth :
    # Russian roulette
    var q = max(0.05, 1-hit_col_lum)
    if pcg.random_float() > q :
      # Keep recursion going
      hit_color = (1.0/(1.0-q))*hit_color
    else:
      return emitted_rad

    # Monte Carlo integration
    var cum_rad = newColor(0, 0, 0)

    # Only do costly recursions if it's worth it
    if hit_col_lum > 0.0:
      for index in 0..n_rays :
        var 
          new_ray = hit_material.brdf.scatter_ray(pcg = pcg, 
                                            incoming_dir = hit.get().ray.dir, 
                                            interaction_point = hit.get().world_point,
                                            normal = hit.get().normal,
                                            depth = ray.depth+1)
          new_rad = PathTracer(hit, background_color, pcg, n_rays, max_depth, lim_depth, new_ray)
        cum_rad = cum_rad+(hit_color*new_rad)

    return emitted_rad+((1.0/float(n_rays))*cum_rad)

