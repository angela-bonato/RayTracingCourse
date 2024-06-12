## Here we define everything about the Vec2d, the Pigment (which associate a specific color to an (u,v) point) the BRDF and finally the Material types.

import hdrimage
import color
import geometryalgebra
import normal
import vector
import point
import ray
import pcg
import std/math

# Orthonormal base type definition

type OrthoNormalBase* = object
  e1* : Vector
  e2* : Vector
  e3* : Vector

proc newOrthoNormalBase*(e1,e2,e3 : Vector) : OrthoNormalBase =
  ## Creator for ONB
  result.e1 = e1
  result.e2 = e2
  result.e3 = e3

proc create_onb_from_z*(normal : Vector|Normal ) : OrthoNormalBase =
  ## Creation of a orthonormal base using the algorithm by Duff et al.
  ## It works only if normal is normalized
  var
    sign = copySign(1.0, normal.z)
    a = -1.0 / (sign + normal.z)
    b = normal.x * normal.y * a
    e1 = newVector( 1.0 + sign * normal.x * normal.x * a, sign * b, -sign * normal.x )
    e2 = newVector( b, sign + normal.y * normal.y * a, -normal.y )
    e3 = newVector( normal.x, normal.y, normal.z )

  return newOrthoNormalBase(e1, e2, e3)

# Vec2d type declaration

type Vec2d* = object # It represent a point in the shape independant u,v coordinates
    u* : float
    v* : float

proc newVec2d*(u = 0.0,v = 0.0) : Vec2d =
    ## Constructor for Vec2d
    result.u = u
    result.v = v
    return result

proc is_close*( vec1, vec2 : Vec2d ) : bool =
    ## is_close method for Vec2d
    return (vec1.u.almostEqual(vec2.u) and
            vec1.v.almostEqual(vec2.v) )
    
proc print*( vec : Vec2d ) : void =
    ## print method for Vec2d
    echo "Vec2d( u=", vec.u, ", v=", vec.v, " )"

# Virtual definitions for Pigment

type Pigment* = ref object of RootObj
    ## Virtual definition

method get_color*(pigment : Pigment, coord : Vec2d) : Color {.base.} =
    ## Virtual get_color method
    quit "Called get_color of Pigment, it is a virtual method!"

# Uniform pigment

type UniformPigment* = ref object of Pigment
    ## Definition of the UniformPigmrnt type, it associates a single color to the shape on which it is called.
    color* : Color

proc newUniformPigment*(color : Color) : Pigment =
    ## Costructor of UniformPigment
    let unipig = new UniformPigment
    unipig.color = color
    return Pigment(unipig)

method get_color*(unipig : UniformPigment, coord : Vec2d) : Color =
    ## Definition of get_color method specific for UniformPigment
    return unipig.color

# Checkered pigment

type CheckeredPigment* = ref object of Pigment
    ## Definition of the Checkered type of pigment, it creates a checkered texture of the shape on which it is called
    col_even*, col_odd* : Color     #the two colors used in the checkered texture
    div_u*, div_v* : int    #number of divisions along the u and v axes to define the squares or rectangles of the texture

proc newCheckeredPigment*(col_even,col_odd : Color, div_u,div_v : int) : Pigment =
    ## Constructor of CheckeredPigment
    let chepig = new CheckeredPigment
    chepig.col_even = col_even
    chepig.col_odd = col_odd
    chepig.div_u = div_u
    chepig.div_v = div_v
    return Pigment(chepig)

method get_color*(chepig : CheckeredPigment, coord : Vec2d) : Color =
    ## Definition of get_color method specific for CheckeredPigment
    var
        sq_u = 1.0/float(chepig.div_u)     #side of a square along u
        sq_v = 1.0/float(chepig.div_v)     #side of a square along v
        ind_u = int(coord.u/sq_u)   #index of the square in which the u coordinate lies (indexation starts with 0) 
        ind_v = int(coord.v/sq_v)   #index of the square in which the v coordinate lies (indexation starts with 0) 
    #color_even is used when both column and row indexes are odd or eve, color_odd is used in all the othes cases
    if (ind_u %% 2 == 0 and ind_v %% 2 == 0) or (not ind_u %% 2 == 0 and not ind_v %% 2 == 0) :
        return chepig.col_even
    else:
        return chepig.col_odd

# Image pigment

type ImagePigment* = ref object of Pigment
    ## Definition of the Image type of pigment, it uses an HdrImage as texture for the shape on which it is called
    image* : HdrImage

proc newImagePigment*(image : HdrImage) : Pigment =
    ## Constructor of ImagePigment
    let impig = new ImagePigment
    impig.image = image
    return Pigment(impig)

method get_color*(impig : ImagePigment, coord : Vec2d) : Color =
    ## Definition of get_color method specific for ImagePigment
    var 
        #I associate to (u,v) point, a pixel of the hdrimage (i.e., colum and row indexes in the image)
        ind_col = int( coord.u * float(impig.image.width))
        ind_row = int((1- coord.v) * float(impig.image.height))
    
    if ind_col >= impig.image.width:
        ind_col = impig.image.width - 1
    if ind_row >= impig.image.height:
        ind_row = impig.image.height - 1
    
    return impig.image.get_pixel(ind_col, ind_row)     #Color of the pixel correspondent to the (u,v) point

# Virtual definitions for BRDF

type Brdf* = ref object of RootObj
    ## Virtual definition
    pigment* : Pigment

method eval*(brdf : Brdf, normal : Normal, in_dir,out_dir : Vector, coord: Vec2d) : Color {.base.} =
    ## Virtual eval method
    quit "Called eval of Brdf, it is a virtual method!"

method scatter_ray*(bdrf: Brdf, pcg: var Pcg, incoming_dir: Vector, interaction_point: Point, normal: Normal, depth: int) : Ray {.base.} =
    ## Virtual scatter_ray method
    quit "Called scatter_ray of Brdf, it is a virtual method!"

# Diffusive BRDF

type DiffuseBrdf* = ref object of Brdf
    ## Definition of the DiffuseBrdf type, it is constant for the shape on which it is called.
    # Pigment
    reflectance* : float

proc newDiffuseBrdf*(pigment = newUniformPigment(newColor(255, 255, 255)), refl = 1.0) : Brdf =
    ## Costructor of DiffuseBrdf with possible default arguments
    let difb = new DiffuseBrdf
    difb.pigment = pigment
    difb.reflectance = refl
    return Brdf(difb)

method eval*(difb : DiffuseBrdf, normal : Normal, in_dir,out_dir : Vector, coord: Vec2d) : Color =
    ## Definition of eval method specific for DiffuseBrdf
    return (difb.reflectance / PI) * difb.pigment.get_color(coord)

method scatter_ray*(difb : DiffuseBrdf, pcg: var Pcg, incoming_dir: Vector, interaction_point: Point, normal: Normal, depth: int) : Ray =
    ## scatter_ray method for a DiffusiveBrdf   
    var
        onb = create_onb_from_z(normal)
        cos_theta_sq = pcg.random_float()
        cos_theta = sqrt(cos_theta_sq)
        sin_theta = sqrt(1.0 - cos_theta_sq)
        phi = 2 * PI * pcg.random_float()

    return newRay( origin = interaction_point, 
                   dir = onb.e1 * cos(phi) * cos_theta + onb.e2 * sin(phi) * cos_theta + onb.e3 * sin_theta,
                   t_min = 10e-3,
                   depth = depth )


# Specular BRDF

type SpecularBrdf* = ref object of Brdf
    ## Definition of the SpecularBrdf type
    # Pigment
    threshold_angle_rad* : float

proc newSpecularBrdf*(pigment = newUniformPigment(newColor(255, 255, 255)), ta_rad = PI/1800.0 ) : Brdf =
    ## Constructor of SpecularBrdf
    let spec = new SpecularBrdf
    spec.pigment = pigment
    spec.threshold_angle_rad = ta_rad
    return Brdf(spec)

method eval*(spec : SpecularBrdf, normal : Normal, in_dir,out_dir : Vector, coord: Vec2d) : Color =
    ## Definition of eval method specific for SpecularBrdf
    ## We provide this implementation for reference, but we are not going to use it (neither in the
    ## path tracer nor in the point-light tracer)
    var 
        theta_in = arccos( normalized(normal).dot(in_dir) )
        theta_out = arccos( normalized(normal).dot(out_dir) )
    
    if abs(theta_in - theta_out) < spec.threshold_angle_rad:
            return spec.pigment.get_color(coord)
    else:
        return newColor(0.0, 0.0, 0.0)

method scatter_ray*(spec : SpecularBrdf, pcg: var Pcg, incoming_dir: Vector, interaction_point: Point, normal: Normal, depth: int) : Ray =
    ## scatter_ray method for a SpecularBrdf   
    var
        ray_dir = newVector(incoming_dir.x, incoming_dir.y, incoming_dir.z).normalized()
        normal = newVector(normal.x, normal.y, normal.z).normalized()

    return newRay(origin=interaction_point,
               dir=ray_dir - normal * 2 * normal.dot(ray_dir),
               tmin=1e-3,
               tmax=Inf,
               depth=depth)

# Material type definition

type Material* = ref object 
    ## Definition of type Material
    brdf* : Brdf
    emitted_radiance* : Pigment

proc newMaterial*(brdf = newDiffuseBrdf(), em_rad = newUniformPigment(newColor(0,0,0))) : Material =
    ## Material constructor with possibility of using default arguments
    new(result)
    result.brdf = brdf
    result.emitted_radiance = em_rad
    return result