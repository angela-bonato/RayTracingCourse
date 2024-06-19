## This is the main of our programme. It is possible to use it with different commands, thanks to cligen library.
import hdrimage
import vector
import transformation
import imagetracer
import camera
import world
import point
import ray
import color
import renderprocs
import pcg
import materials
import csg
import std/streams
import std/math

proc demo(kind_of_camera = 'p', a_factor = 0.5, gamma = 2.0, width = 640, height = 480, angle = 0.0, antial_rays = 9, algorithm = "path_tracer", num_rays = 10, max_depth = 3, lim_depth = 2, args : seq[string]) : void =
  ## Command to produce our "triangolo nero" in pfm format and then convert it in a png file
  var 
    cam = newCamera(aspect_ratio = width/height , transform = rotation_z( angle/360.0 * 2 * PI  )*traslation(newVector(-2, 0, 2))) 
    fire_ray : FireRayProcs
    img = newHdrImage(width, height)  
    im_tracer = newImageTracer(img, cam)
    scene = newWorld()
    pfm_stream_write, pfm_stream_read : Stream
    output_img : HdrImage
    pfm_filename, png_filename : string
    pcg = newPcg()
    renderproc_wrapped : SolveRenderingProc

  case algorithm:
    of "onoff":
      proc onoff(scene : World, ray : Ray) : Color =
        return OnOffRenderer(scene, ray, background_color = newColor(0, 0, 0), hit_color = newColor(255, 255, 255) )
      renderproc_wrapped = onoff
    of "flat":
      proc flat(scene : World, ray : Ray) : Color =
        return FlatRenderer(scene, ray, background_color = newColor(0, 0, 0))
      renderproc_wrapped = flat
    of "path_tracer":
      proc path_tracer(scene : World, ray : Ray) : Color =
        return PathTracer(scene, ray, background_color = newColor(0,0,0), pcg = pcg, n_rays = num_rays, max_depth = max_depth, lim_depth = lim_depth )
      renderproc_wrapped = path_tracer
    else:
      quit "Invalid algorithm argument: choose a working algorithm, you can use one of the following: \n  'onoff': give a hit color if the ray hits the shape and a background color if it doesn't \n  'flat': compute the rendering neglecting any contibution of the light, it just uses the pigment of each surface\n  'path_tracer': a real raytracing algorithm"


  if len(args) != 2:
    quit "Usage:\n  demo [optional-params] <OUT_PFM_FILENAME> <OUT_PNG_FILENAME> \n\nTo show a better usage explanation use the optional parameter -h, --help "
  pfm_filename = args[0]
  png_filename = args[1]

  #exceptions to check on the input parameters?

  # Creation of the pfm image
  
  if kind_of_camera == 'o' :  #Default is perspective
    fire_ray = fire_ray_orthogonal
  else:
    fire_ray = fire_ray_perspective

  if sqrt(float(antial_rays))!=floor(sqrt(float(antial_rays))) :
    quit "Invalid antial_rays value: choose a perfect square as antial_rays."

  var 
    sky_mat = newMaterial(brdf = newDiffuseBrdf(newUniformPigment(newColor(0, 0, 0))), 
                          em_rad = newUniformPigment(newColor(1.0, 0.9, 0.5)))
    ground_mat = newMaterial(brdf = newDiffuseBrdf(pigment = newCheckeredPigment(col_even = newColor(0.3, 0.5, 0.1), col_odd = newColor(0.1, 0.2, 0.5), div_u = 4, div_v = 4)))
    sph1_mat = newMaterial(brdf = newDiffuseBrdf(pigment = newUniformPigment(newColor(0.3, 0.4, 0.8))))
    sph2_mat = newMaterial(brdf = newSpecularBrdf(pigment = newUniformPigment(newColor(0.6, 0.2, 0.3))))

  scene.add(newSphere(material = sky_mat, transform = scaling(200, 200, 200)))
  scene.add(newPlane(material = ground_mat))
  scene.add(newSphere(material = sph1_mat, transform = traslation(newVector(0, 0, 1))))
  scene.add(newSphere(material = sph2_mat, transform = traslation(newVector(1, 2.5, 0))))

  im_tracer.fire_all_rays(fire_ray, renderproc_wrapped, scene, toInt(sqrt(float(antial_rays))))

  # Creation of the pfm file

  try:
    pfm_stream_write = openFileStream(pfm_filename, fmWrite )
  except IOError as e:
    raise InvalidPfmFileFormat.newException(e.msg)

  im_tracer.image.write_pfm(pfm_stream_write)
  
  echo "File ", pfm_filename, " has been written to disk"
  pfm_stream_write.close()

  # Conversion to png file

  try:
    pfm_stream_read = openFileStream(pfm_filename, fmRead )
  except IOError as e:
    raise InvalidPfmFileFormat.newException(e.msg)

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
    input_pfm_filename, output_png_filename : string

  if len(args) != 2:
    quit "Usage:\n pfm2png [optional-params] <OUT_PFM_FILENAME> <OUT_PNG_FILENAME> \n\nTo show a better usage explanation use the optional parameter -h, --help "
  input_pfm_filename = args[0]
  output_png_filename = args[1]

  try:
    input_stream = openFileStream(input_pfm_filename, fmRead )
  except IOError as e:
    raise InvalidPfmFileFormat.newException(e.msg)

  img = read_pfm_image(input_stream)

  echo "File ", input_pfm_filename, " has been read from disk."

  img.normalize_image(a_factor)
  img.clamp_image()

  img.write_png_image(output_png_filename, gamma)

  echo "File ", output_png_filename, " has been written to disk"

  input_stream.close()


#Thi is the actual main
when isMainModule:
  import cligen; dispatchMulti([demo, help={ "kind_of_camera":"set kind of camera, could be perspective 'p' or orthogonal 'o' ", 
                                             "args":"<OUT_PFM_FILENAME> <OUT_PNG_FILENAME>",
                                             "angle":"set the angle of view, in 360°",
                                             "width":"set the width of the generated image",
                                             "height":"set the height of the generated image",
                                             "algorithm":"set the algorithm used to solve the rendering, it can be: \n  'onoff': give a hit color if the ray hits the shape and a background color if it doesn't \n  'flat': compute the rendering neglecting any contibution of the light, it just uses the pigment of each surface\n  'path_tracer': a real raytracing algorithm",
                                             "antial_rays":"set the number of rays used to perform antialiasing, it must be a perfect square. if==0 antialising is turned off",
                                             "num_rays":"set the number of diffused rays to perform MC integration in the path_tracer algorithm",
                                             "max_depth":"set the max depth (number of times the ray is scattered) to perform MC integration in the path_tracer algorithm",
                                             "lim_depth":"set the depth (number of time the ray is scattered) at wich the russian roulette is activated"}],
                               [pfm2png, help={ "args":"<IN_PFM_FILENAME> <OUT_PNG_FILENAME>"}])
 

    