## Implementation of the ImageTracer type and its methods. It connect the Camera type to the HdrImage type.

import camera
import hdrimage
import ray
import world
import renderprocs
import pcg
import color
import std/terminal
import std/strutils

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

proc MC_fire_ray_pixel*(img_tracer: ImageTracer, col,row : int, fire_ray_image: FireRayProcs, u_min,u_max,v_min,v_max: float, pcg_a: var Pcg) : Ray =
    ## Fires a ray from a random point of a portion of a pixel of the screen
    var
        u_pixel = pcg_a.random_float()*(u_max-u_min)+u_min
        v_pixel = pcg_a.random_float()*(v_max-v_min)+v_min
        u = (float(col) + u_pixel) / float(img_tracer.image.width )      
        v = 1.0 - (float(row) + v_pixel) / float(img_tracer.image.height )

    return img_tracer.camera.fire_ray_image(u,v)

proc fire_all_rays*(img_tracer: ImageTracer, fire_ray_image : FireRayProcs, solve_rendering: SolveRenderingProc, scene: World, antial: int) : void =
    ## fire_all_rays 
    if antial == 0 :
        echo "Called fire_all_rays without antialiasing"
        ## antialiasing turned off
        for row in countup(0,img_tracer.image.height-1):
            for col in countup(0,img_tracer.image.width-1):
                
                #progress bar
                var counter = toInt( (row*img_tracer.image.width + col) / (img_tracer.image.height*img_tracer.image.width) * 100 )
                stdout.styledWriteLine(fgRed, "0% ", fgWhite, '#'.repeat counter, if counter > 50: fgGreen else: fgYellow, "\t", $counter , "%")
                cursorUp 1
                eraseLine()

                #fire rays
                var 
                    img_ray = img_tracer.fire_ray_pixel(col, row, fire_ray_image)
                    color = solve_rendering(scene, img_ray)
                img_tracer.image.setPixel(col, row, color)

        #progress bar again
        stdout.resetAttributes()

    else:
        ## antialiasing turned on
        echo "Called fire_all_rays with antialiasing"
        var 
            pcg_a = newPcg()
            square = 1.0/float(antial)
        for a in countup(0, antial-1):
            for b in countup(0, antial-1):
                #progress bar
                var counter = toInt(float(a*antial + b) / float(antial*antial) * 100)
                stdout.styledWriteLine(fgRed, "0% ", fgWhite, '#'.repeat counter, if counter > 50: fgGreen else: fgYellow, "\t", $counter , "%")
                cursorUp 1
                eraseLine()
                
                # ranges for stratified sampilng, usefull to call MC_fire_ray_pixel
                var 
                    u_min = float(a)*square
                    u_max = (float(a)+1.0)*square
                    v_min = float(b)*square
                    v_max = (float(b)+1.0)*square
                for row in countup(0,img_tracer.image.height-1):
                    for col in countup(0,img_tracer.image.width-1):                    
                        #fire rays
                        var 
                            img_ray = img_tracer.MC_fire_ray_pixel(col, row, fire_ray_image, u_min, u_max, v_min, v_max, pcg_a)
                            color = solve_rendering(scene, img_ray)
                        img_tracer.image.setPixel(col, row, img_tracer.image.getPixel(col, row)+color)

                        if a==antial-1 and b==antial-1:
                            img_tracer.image.setPixel(col, row, (1.0/float(antial*antial))*img_tracer.image.getPixel(col, row))

        #progress bar again
        stdout.resetAttributes()
