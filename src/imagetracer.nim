## Implementation of the ImageTracer type and its methods. It connect the Camera type to the HdrImage type.

import camera
import hdrimage
import ray
import world
import renderprocs

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

proc MC_fire_ray_pixel*(img_tracer: ImageTracer, col,row : int, fire_ray_image: FireRayProcs, s_min: float, s_max: float, pcg_a: var Pcg) : Ray =
    ## Fires a ray from a random point of a portion of a pixel of the screen
    var
        u_pixel = pcg_a.random_float()*(s_max-s_min)+s_min
        v_pixel = pcg_a.random_float()*(s_max-s_min)+s_min
        u = (float(col) + u_pixel) / float(img_tracer.image.width )      
        v = 1.0 - (float(row) + v_pixel) / float(img_tracer.image.height )

    return img_tracer.camera.fire_ray_image(u,v)

proc fire_all_rays*(img_tracer: ImageTracer, fire_ray_image : FireRayProcs, solve_rendering: SolveRenderingProc, scene: World, antial: int) : void =
    ## fire_all_rays 
    if antial == 0 :
        ## antialising turned off
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
        ## antialising turned on
        pcg_a = newPcg()
        var square = 1.0/float(antial)
        for a in 0..antial:
            # ranges for stratified sampilng, usefull to call MC_fire_ray_pixel
            var 
                s_min = a*square
                s_max = (a+1)*square
                color = newColor(0, 0, 0)
            for row in countup(0,img_tracer.image.height-1):
                for col in countup(0,img_tracer.image.width-1):
                    #progress bar
                    var counter = toInt( (row*img_tracer.image.width + col) / (img_tracer.image.height*img_tracer.image.width) * 100 )
                    stdout.styledWriteLine(fgRed, "0% ", fgWhite, '#'.repeat counter, if counter > 50: fgGreen else: fgYellow, "\t", $counter , "%")
                    cursorUp 1
                    eraseLine()
                    
                    #fire rays
                    var img_ray = img_tracer.MC_fire_ray_pixel(col, row, fire_ray_image, s_min, s_max, pcg_a)
                    color = color + solve_rendering(scene, img_ray)
                    if a==antial-1:
                        img_tracer.image.setPixel(col, row, (1.0/float(a))*color)

            #progress bar again
            stdout.resetAttributes()
