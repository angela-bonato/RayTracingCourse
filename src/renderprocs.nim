## Here we deefine all the procs in the class SolveRenderingProcs

import world
import color
import vector
import std/options
import std/math

# Orthonormal base type definition

type OrthoNormalBase* = object
  e1 : Vector
  e2 : Vector
  e3 : Vector

proc newOrthoNormalBase*(e1,e2,e3 : Vector) : OrthoNormalBase =
  ## Creator for ONB
  result.e1 = e1
  result.e2 = e2
  result.e3 = e3

proc create_onb_from_z*( normal : Vector|Normal ) : OrthoNormalBase =
  ## Creation of a orthonormal base using the algorithm by Duff et al.
  ## It works only if normal is normalized
  var
    sign = copySign(1.0, normal.z)
    a = -1.0 / (sign + normal.z)
    b = normal.x * normal.y * a
    e1 = newVector( 1.0 + sign * normal.x * normal.x * a, sign * b, -sign * normal.x )
    e2 = newVector( b, sign + normal.y * normal.y * a, -normal.y )
    e3 = newVector( normal-x, normal.y, normal.z )

    return newOrthoNormalBase(e1, e2, e3)

# Definition of the possible rendering procs  

type SolveRenderingProcs* = proc (hit : Option[HitRecord]) : Color {.closure.}
## Definition of the proc type used by imagetracer

proc solverendproc*(hit: Option[HitRecord]): Color =
    ##Just a temporary proc which inherit from SolveRenderingProcs type, to be used in tests/test_5.nim
    return newColor(1.0, 2.0, 3.0)

proc OnOffTracer*(hit : Option[HitRecord]) : Color =
  ## This proc is used to determine the color of each pixel based on what the input ray hit
  if (hit.isNone) :
    return newColor(0, 0, 0)  #The background will be black
  else:
    return newColor(255, 255, 255)  #The spheres will be white

