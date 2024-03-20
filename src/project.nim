
import hdrimage
import parameters
import std/os

when isMainModule:

  var params : Parameters

  try:
    params = newParameters(commandLineParams())
  except ValueError as e:
    echo "Error: ", e.msg

  