
import hdrimage
import parameters
import vector
import imagetracer
import camera
import std/os
import std/streams

when isMainModule:
  echo "Hello, world!"

#[
  Firt example how to define the fire_ray proc
  
  var
    kind_of_camera : string
    fire_ray : FireRayProcs

  if kind_of_camera == "o" :
    fire_ray = fire_ray_orthogonal
  else:
    fire_ray = fire_ray_perspective
]#

#[
  var 
    params : Parameters
    input_stream : Stream
    img : HdrImage

  try:
    params = newParameters(commandLineParams())
  except CatchableError as e:
    echo e.msg

  try:
    input_stream = newFileStream( params.input_pfm_filename, fmRead )
  except CatchableError as e:
    echo e.msg

  try:
    img = read_pfm_image(input_stream)
  except CatchableError as e:
    echo e.msg

  echo "File ", params.input_pfm_filename, " has been read from disk."

  img.normalize_image(params.a_factor)
  img.clamp_image()

  img.write_png_image(params.output_png_filename, params.gamma)

  echo "File ", params.output_png_filename, " has been written to disk"

  input_stream.close()
]#
 

    