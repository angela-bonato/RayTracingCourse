## This is the main of our programme. It is possible to use it with different commands, thanks to cligen library.
import hdrimage
import vector
import imagetracer
import camera
import world
import color
import std/options
import std/streams
import transformation


proc OnOffTracer(hit : Option[HitRecord]) : Color =
  ## This proc is used to determine the color of each pixel based on what the input ray hit
  if (hit.isNone) :  #is this the right sintax? 
    return newColor(0, 0, 0)  #The background will be black
  else:
    return newColor(255, 255, 255)  #The spheres will be white

proc demo(kind_of_camera = 'p', a_factor = 0.18, gamma = 2.0, args : seq[string]) : void =
  ## Command to produce our "triangolo nero" in pfm format and then convert it in a png file
  var 
    cam = newCamera(transform = translation(newVector(-1, 0, 0))) #This should define an observer in (-2, 0, 0) and a squared screen cetered in (-1, 0, 0)
    fire_ray : FireRayProcs
    img = newHdrImage(960, 960)  #change the arguments with the desired dimension
    im_tracer = newImageTracer(img, cam)
    scene = newWorld()
    tracer = OnOffTracer
    pfm_stream_write, pfm_stream_read : Stream
    output_img : HdrImage
    pfm_filename = args[0]
    png_filename = args[1]
    
  #exceptions to check on the input parameters?

  ## Creation of the pfm image
  
  if kind_of_camera == 'o' :  #Default is perspective
    fire_ray = fire_ray_orthogonal
  else:
    fire_ray = fire_ray_perspective

  # These are the 10 spheres placed in the scene, scaling(10, 10, 10) means that each sphere has radius=1/10
  #[
  scene.add(newSphere(translation(newVector(0.5, -0.5, 0.5))*scaling(0.1, 0.1, 0.1)))
  scene.add(newSphere(translation(newVector(-0.5, -0.5, 0.5))*scaling(0.1, 0.1, 0.1)))
  scene.add(newSphere(translation(newVector(-0.5, 0.5, 0.5))*scaling(0.1, 0.1, 0.1)))
  scene.add(newSphere(translation(newVector(0.5, 0.5, 0.5))*scaling(0.1, 0.1, 0.1)))
  scene.add(newSphere(translation(newVector(0.5, -0.5, -0.5))*scaling(0.1, 0.1, 0.1)))
  scene.add(newSphere(translation(newVector(-0.5, -0.5, -0.5))*scaling(0.1, 0.1, 0.1)))
  scene.add(newSphere(translation(newVector(-0.5, 0.5, -0.5))*scaling(0.1, 0.1, 0.1)))
  scene.add(newSphere(translation(newVector(0.5, 0.5, -0.5))*scaling(0.1, 0.1, 0.1)))
  scene.add(newSphere(translation(newVector(0, 0, -0.5))*scaling(0.1, 0.1, 0.1)))
  scene.add(newSphere(translation(newVector(0, 0.5, 0))*scaling(0.1, 0.1, 0.1)))
  ]#
  scene.add(newSphere())

  #how to make scene and im_tracer talk to each other? I have to use scene.ray_intersection on each ray of the image then produce a hitRecord from which I can produce the image? boh

  im_tracer.fire_all_rays(fire_ray, tracer, scene)

  ## Creation of the pfm file
  
  pfm_stream_write = newFileStream(pfm_filename, fmWrite)
  im_tracer.image.write_pfm(pfm_stream_write)
  
  echo "File ", pfm_filename, " has been written to disk"
  pfm_stream_write.close()

  ## Conversion to png file
  
  pfm_stream_read = newFileStream(pfm_filename, fmRead)
  output_img = read_pfm_image(pfm_stream_read)

  output_img.normalize_image(a_factor)
  output_img.clamp_image()
  output_img.write_png_image(png_filename, gamma)

  echo "File ", png_filename, " has been written to disk"
  pfm_stream_read.close()


#check on default values of parameters
proc pfm2png(a_factor = 0.18, gamma = 2.0, args : seq[string]) : void =
  ## Command to convert a pfm file into a png one
  var
    input_stream : Stream
    img : HdrImage
    input_pfm_filename = args[0]
    output_png_filename = args[1]

  try:
    input_stream = newFileStream(input_pfm_filename, fmRead )
  except CatchableError as e:
    echo e.msg

  try:
    img = read_pfm_image(input_stream)
  except CatchableError as e:
    echo e.msg

  echo "File ", input_pfm_filename, " has been read from disk."

  img.normalize_image(a_factor)
  img.clamp_image()

  img.write_png_image(output_png_filename, gamma)

  echo "File ", output_png_filename, " has been written to disk"

  input_stream.close()


#Thi is the actual main
when isMainModule:
  import cligen; dispatchMulti([demo], [pfm2png])
 

    