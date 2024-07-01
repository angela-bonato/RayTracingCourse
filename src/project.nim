## This is the main of our programme. It is possible to use it with different commands, thanks to cligen library.
import hdrimage
import geometry
import imagetracer
import camera
import world
import ray
import color
import renderprocs
import pcg
import scenecompiler
import std/options
import std/strutils
import std/streams
import std/math

proc render(a_factor = 0.5, gamma = 2.0, width = 640, height = 480, angle = NaN, antial_rays = 9, algorithm = "path_tracer", num_rays = 10, max_depth = 3, lim_depth = 2, args : seq[string]) : void =
  ## Command to produce an image from a file that describe the scene
  
  # check input file 

  var filename, inputfile : string

  if (len(args) != 1) or (not args[0].contains(".txt")) :
    quit "Usage:\n  render [optional-params] <IN_TXT_FILENAME> \n\nTo show a better usage explanation use the optional parameter -h, --help "
  var n = args[0].find(".txt")
  input_file = args[0]
  filename = args[0][0 .. ^n]

  # create and initialize variables

  var
    instream = newInputStream( newFileStream(inputfile, fmRead), inputfile ) 
    scene = parse_scene(instream)
    cam = get(scene.camera)
    fire_ray = get(scene.fire_proc)
    img = newHdrImage(width, height)
    im_tracer = newImageTracer( img, cam )
    world = scene.world
    output_img : HdrImage 
    pfm_stream_write, pfm_stream_read : Stream
    renderproc_wrapped : SolveRenderingProc
    pfm_filename = (filename & ".pfm")
    png_filename = (filename & ".png")
    pcg = newPcg()

  # check if a value of angle is given, and modify the camera transformation

  if angle != NaN :
    var new_cam_transform = rotation_z( angle/360 * 2 * PI ) * cam.transform
    cam.transform = new_cam_transform

  # check the algorithm to use

  case algorithm:
    of "onoff":
      proc onoff(world : World, ray : Ray) : Color =
        return OnOffRenderer(world, ray, background_color = newColor(0, 0, 0), hit_color = newColor(255, 255, 255) )
      renderproc_wrapped = onoff
    of "flat":
      proc flat(world : World, ray : Ray) : Color =
        return FlatRenderer(world, ray, background_color = newColor(0, 0, 0))
      renderproc_wrapped = flat
    of "path_tracer":
      proc path_tracer(world : World, ray : Ray) : Color =
        return PathTracer(world, ray, background_color = newColor(0,0,0), pcg = pcg, n_rays = num_rays, max_depth = max_depth, lim_depth = lim_depth )
      renderproc_wrapped = path_tracer
    else:
      quit "Invalid algorithm argument: choose a working algorithm, you can use one of the following: \n  'onoff': give a hit color if the ray hits the shape and a background color if it doesn't \n  'flat': compute the rendering neglecting any contibution of the light, it just uses the pigment of each surface\n  'path_tracer': a real raytracing algorithm"

  #  check if antial_rays is a perfect square

  if sqrt(float(antial_rays))!=floor(sqrt(float(antial_rays))) :
    quit "Invalid antial_rays value: choose a perfect square as antial_rays."

  # fire all rays!!

  im_tracer.fire_all_rays(fire_ray, renderproc_wrapped, world, toInt(sqrt(float(antial_rays))))

  # Creation of the pfm file
  
  pfm_stream_write = newFileStream(pfm_filename, fmWrite)
  im_tracer.image.write_pfm(pfm_stream_write)

  echo "File ", pfm_filename, " has been written to disk"
  pfm_stream_write.close()

  # Conversion to png file

  try:
    pfm_stream_read = newFileStream(pfm_filename, fmRead)
  except CatchableError as e:
    echo e.msg

  try:
    output_img = read_pfm_image(pfm_stream_read)
  except CatchableError as e:
    echo e.msg

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
    input_pfm_filename, output_png_filename : string

  if len(args) != 2:
    quit "Usage:\n  demo [optional-params] <IN_PFM_FILENAME> <OUT_PNG_FILENAME> \n\nTo show a better usage explanation use the optional parameter -h, --help "

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
  import cligen; dispatchMulti([pfm2png, help={ "args":"<IN_PFM_FILENAME> <OUT_PNG_FILENAME>"}],
                               [render, help={"args":"<INPUT TXT FILE> ",
                                              "angle":"set the angle of view, in 360°",
                                              "width":"set the width of the generated image",
                                              "height":"set the height of the generated image",
                                              "algorithm":"set the algorithm used to solve the rendering, it can be: \n  'onoff': give a hit color if the ray hits the shape and a background color if it doesn't \n  'flat': compute the rendering neglecting any contibution of the light, it just uses the pigment of each surface\n  'path_tracer': a real raytracing algorithm",
                                              "antial_rays":"set the number of rays used to perform antialiasing, it must be a perfect square. if==0 antialising is turned off",
                                              "num_rays":"set the number of diffused rays to perform MC integration in the path_tracer algorithm",
                                              "max_depth":"set the max depth (number of times the ray is scattered) to perform MC integration in the path_tracer algorithm",
                                              "lim_depth":"set the depth (number of time the ray is scattered) at wich the russian roulette is activated"} ])
 

    