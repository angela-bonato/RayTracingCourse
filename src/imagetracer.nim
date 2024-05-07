## Implementation of the ImageTracer type and its methods. It connect the Camera type to the HdrImage type.

import camera
import hdrimage
import ray
import color
import world
import std/options

# ImageTracer typer declaration

type ImageTracer* = object
    image* : HdrImage
    camera* : Camera

# ImageTracer trace constructor

proc newImageTracer*() : ImageTracer =
    ## Empty constructor, initialize all the variables to default values
    result.image = newHdrImage()
    result.camera = newCamera()

    return result

proc newImageTracer*(image : HdrImage, camera : Camera) : ImageTracer =
    ## Constructor with elements, initialize the variables to given values
    result.image = image
    result.camera = camera

    return result

# ImageTracer procs

proc fire_ray_pixel*(img_tracer: ImageTracer, col,row :int, fire_ray_image : FireRayProcs, u_pixel=0.5, v_pixel=0.5) : Ray =
    ## Fires a ray from a pixel of the screen -> give the center of the pixel in the continuum space of the camera to fire the ray
    var 
        u = (float(col) + u_pixel) / float(img_tracer.image.width )      
        v = 1.0 - (float(row) + v_pixel) / float(img_tracer.image.height )

    return img_tracer.camera.fire_ray_image(u,v)

type SolveRenderingProcs* = proc (hit : Option[HitRecord]) : Color {.closure.}

#[
proc fire_all_rays*(img_tracer: ImageTracer, fire_ray_image : FireRayProcs, solve_rendering: SolveRenderingProcs) : void =
    ## Fires all the rays, iterating over the rows and the columns of the image
    for row in countup(0,img_tracer.image.height-1):
        for col in countup(0,img_tracer.image.width-1):
            var 
                ray = img_tracer.fire_ray_pixel(col, row, fire_ray_image)
                color = solve_rendering(ray)
            img_tracer.image.setPixel(col, row, color)
]#

proc fire_all_rays*(img_tracer: ImageTracer, fire_ray_image : FireRayProcs, solve_rendering: SolveRenderingProcs, scene: World) : void =
    ## fire_all_rays alternative version
    for row in countup(0,img_tracer.image.height-1):
        for col in countup(0,img_tracer.image.width-1):
            var 
                img_ray = img_tracer.fire_ray_pixel(col, row, fire_ray_image)
                hit = scene.ray_intersections(img_ray)
                color = solve_rendering(hit)
            img_tracer.image.setPixel(col, row, color)
            