## Here we define everything about the Vec2d, the Pigment (which associate a specific color to an (u,v) point) the BRDF and finally the Material types.

import hdrimage
import color
import geometry
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

type 

    PigmentKind* = enum 
        ##All possible kind of pigments
        UniformPigment, CheckeredPigment, ImagePigment
    
    Pigment* = object
        ## Actual definition
        case kind*: PigmentKind
            of UniformPigment:
                ## Definition of the UniformPigmrnt type, it associates a single color to the shape on which it is called.
                color* : Color
            of CheckeredPigment:
                ## Definition of the Checkered type of pigment, it creates a checkered texture of the shape on which it is called
                col_even*, col_odd* : Color     #the two colors used in the checkered texture
                div_u*, div_v* : int    #number of divisions along the u and v axes to define the squares or rectangles of the texture
            of ImagePigment:
                ## Definition of the Image type of pigment, it uses an HdrImage as texture for the shape on which it is called
                image* : HdrImage

# Constructors

proc newUniformPigment*(color : Color): Pigment {.inline.} =
    ## Costructor of UniformPigment
    Pigment(kind: UniformPigment, color: color)

proc newCheckeredPigment*(col_even,col_odd : Color, div_u,div_v : int): Pigment {.inline.} =
    ## Constructor of CheckeredPigment
    Pigment(kind: CheckeredPigment, col_even: col_even, col_odd: col_odd, div_u: div_u, div_v: div_v)

proc newImagePigment*(image : HdrImage): Pigment {.inline.} =
    ## Constructor of ImagePigment
    Pigment(kind: ImagePigment, image: image)

#methods

proc get_color*(pig : Pigment, coord : Vec2d) : Color =
    ##Each type of pigment has it's own definition
   
    if pig.kind == UniformPigment:
        ## Definition of get_color proc specific for UniformPigment
        return pig.color

    elif pig.kind == CheckeredPigment:
        ## Definition of get_color method specific for CheckeredPigment
        var
            sq_u = 1.0/float(pig.div_u)     #side of a square along u
            sq_v = 1.0/float(pig.div_v)     #side of a square along v
            ind_u = int(coord.u/sq_u)   #index of the square in which the u coordinate lies (indexation starts with 0) 
            ind_v = int(coord.v/sq_v)   #index of the square in which the v coordinate lies (indexation starts with 0) 
        #color_even is used when both column and row indexes are odd or eve, color_odd is used in all the othes cases
        if (ind_u %% 2 == 0 and ind_v %% 2 == 0) or (not ind_u %% 2 == 0 and not ind_v %% 2 == 0) :
            return pig.col_even
        else:
            return pig.col_odd

    elif pig.kind == ImagePigment:
        ## Definition of get_color proc specific for ImagePigment
        var 
            #I associate to (u,v) point, a pixel of the hdrimage (i.e., colum and row indexes in the image)
            ind_col = int(coord.u * float(pig.image.width))
            ind_row = int(coord.v * float(pig.image.height))

        if ind_col >= pig.image.width:
            ind_col = pig.image.width - 1
        if ind_row >= pig.image.height:
            ind_row = pig.image.height - 1

        return pig.image.get_pixel(ind_col, ind_row)     #Color of the pixel correspondent to the (u,v) point

    else:
        assert false, "Invalid Pigment.kind found"

# Definitions for BRDF

type 

    BrdfKind* = enum 
        ##All possible kinds of brdf
        SpecularBrdf, DiffuseBrdf
    
    Brdf* = object 
        ## Actual definition
        pigment* : Pigment

        case kind*: BrdfKind
            of SpecularBrdf:
                ## Definition of the SpecularBrdf type
                threshold_angle_rad* : float
            of DiffuseBrdf:
                ## Definition of the DiffuseBrdf type, it is constant for the shape on which it is called.
                reflectance* : float

#Constructors

proc newDiffuseBrdf*(pigment = newUniformPigment(newColor(255, 255, 255)), refl = 1.0) : Brdf {.inline.} =
    ## Costructor of DiffuseBrdf with possible default arguments
    Brdf(pigment: pigment, kind: DiffuseBrdf, reflectance: refl)

proc newSpecularBrdf*(pigment = newUniformPigment(newColor(255, 255, 255)), ta_rad = PI/1800.0 ) : Brdf {.inline.} =
    ## Constructor of SpecularBrdf
    Brdf(pigment: pigment, kind: SpecularBrdf, threshold_angle_rad: ta_rad)
    
#methods

proc eval*(brdf : Brdf, normal : Normal, in_dir,out_dir : Vector, coord: Vec2d) : Color =
    if brdf.kind == DiffuseBrdf:
        ## Definition of eval method specific for DiffuseBrdf
        return (brdf.reflectance / PI) * brdf.pigment.get_color(coord)

    elif brdf.kind == SpecularBrdf:
        ## Definition of eval method specific for SpecularBrdf
        ## We provide this implementation for reference, but we are not going to use it (neither in the
        ## path tracer nor in the point-light tracer)
        var 
            theta_in = arccos( normalized(normal).dot(in_dir) )
            theta_out = arccos( normalized(normal).dot(out_dir) )

        if abs(theta_in - theta_out) < brdf.threshold_angle_rad:
                return brdf.pigment.get_color(coord)
        else:
            return newColor(0.0, 0.0, 0.0)

    else:
        assert false, "Invalid Brdf.kind found"

proc scatter_ray*(brdf: Brdf, pcg: var Pcg, incoming_dir: Vector, interaction_point: Point, normal: Normal, depth: int) : Ray =
    if brdf.kind == DiffuseBrdf:
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

    elif brdf.kind == SpecularBrdf:
        ## scatter_ray method for a SpecularBrdf   
        var
            ray_dir = newVector(incoming_dir.x, incoming_dir.y, incoming_dir.z).normalized()
            normal = newVector(normal.x, normal.y, normal.z).normalized()

        return newRay(origin=interaction_point,
                   dir=ray_dir - normal * 2 * normal.dot(ray_dir),
                   tmin=1e-3,
                   tmax=Inf,
                   depth=depth)
    
    else:
        assert false, "Invalid Brdf.kind found"
    
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

proc is_close*(pigment1, pigment2 : Pigment) : bool =
    if pigment1.kind != pigment2.kind :
        return false
    elif pigment1.kind == UniformPigment:
        return  pigment1.color.is_close(pigment2.color) 
    elif pigment1.kind == CheckeredPigment:
        return ( pigment1.col_even.is_close(pigment2.col_even) and pigment1.col_odd.is_close(pigment2.col_odd) and (pigment1.div_u == pigment2.div_u) and (pigment1.div_v == pigment2.div_v) )
    elif pigment1.kind == ImagePigment:
        return pigment1.image.is_close(pigment2.image)

proc is_close*(brdf1, brdf2 : Brdf) : bool =
    if brdf1.kind != brdf2.kind :
        return false
    elif brdf1.kind == DiffuseBrdf:
        return ( brdf1.pigment.is_close(brdf2.pigment) and brdf1.reflectance.almostEqual(brdf2.reflectance) )
    elif brdf1.kind == SpecularBrdf:
        return ( brdf1.pigment.is_close(brdf2.pigment) and brdf1.threshold_angle_rad.almostEqual(brdf2.threshold_angle_rad) )

proc is_close*(mat1, mat2 : Material) : bool =
    return ( mat1.brdf.is_close(mat2.brdf) and mat1.emitted_radiance.is_close(mat2.emitted_radiance) )