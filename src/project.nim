
import hdrimage
import parameters
import std/os
import std/streams

when isMainModule:

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

  img.write_png_image(params.output_png_filename)

  echo "File ", params.output_png_filename, " has been written to disk"

  input_stream.close()
 

    