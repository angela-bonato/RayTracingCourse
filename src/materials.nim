## Here we define everything about the Pigment (which associate a specific color to an (u,v) point) the BRDF and finally the Material types.

import hdrimage
import shapes
import color
import normal
import vector
import std/math

# Virtual definitions for Pigment

type Pigment* = ref object of RootObj
    ## Virtual definition

method get_color*(pig : Pigment, coord : Vec2d) : Color {.base.} =
    ## Virtual get_color method
    quit "Called get_color of Pigment, it is a virtual method!"

# Uniform pigment

type UniformPigment* = ref object of Pigment
    ## Definition of the UniformPigmrnt type, it associates a single color to the shape on which it is called.
    color* : Color

proc newUniformPigment*(mycol : Color) : Pigment =
    ## Costructor of UniformPigment
    let unipig = new UniformPigment
    unipig.color = mycol
    return Pigment(unipig)

method get_color*(unipig : UniformPigment, coord : Vec2d) : Color =
    ## Definition of get_color method specific for UniformPigment
    return unipig.color

# Checkered pigment

type CheckeredPigment* = ref object of Pigment
    ## Definition of the Checkered type of pigment, it creates a checkered texture of the shape on which it is called
    col_even*, col_odd* : Color     #the two colors used in the checkered texture
    div_u*, div_v* : int    #number of divisions along the u and v axes to define the squares or rectangles of the texture

proc newCheckeredPigment*(cole,colo : Color, divu,divv : int) : Pigment =
    ## Constructor of CheckeredPigment
    let chepig = new CheckeredPigment
    chepig.col_even = cole
    chepig.col_odd = colo
    chepig.div_u = divu
    chepig.div_v = divv
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

proc newImagePigment*(myimg : HdrImage) : Pigment =
    ## Constructor of ImagePigment
    let impig = new ImagePigment
    impig.image = myimg
    return Pigment(impig)

method get_color*(impig : ImagePigment, coord : Vec2d) : Color =
    ## Definition of get_color method specific for ImagePigment
    var 
        #I associate to (u,v) point, a pixel of the hdrimage (i.e., colum and row indexes in the image)
        ind_col = int(coord.u * float(impig.image.width))
        ind_row = int(coord.v * float(impig.image.height))
    
    if ind_col >= impig.image.width:
        ind_col = impig.image.width - 1
    if ind_row >= impig.image.height:
        ind_row = impig.image.height - 1
    
    return impig.image.get_pixel(ind_col, ind_row)     #Color of the pixel correspondent to the (u,v) point

# Virtual definitions for BRDF

type Brdf* = ref object of RootObj
    ## Virtual definition

method eval*(brdf : Brdf, normal : Normal, in_dir,out_dir : Vector, coord: Vec2d) : Color {.base.} =
    ## Virtual eval method
    quit "Called eval of Brdf, it is a virtual method!"

# Diffusive BRDF

type DiffuseBrdf* = ref object of Brdf
    ## Definition of the DiffuseBrdf type, it is constant for the shape on which it is called.
    pigment* : Pigment
    reflectance* : float

proc newDiffuseBrdf*(mypig = newUniformPigment(newColor(255, 255, 255)), refl = 1.0) : Brdf =
    ## Costructor of DiffuseBrdf with possible default arguments
    let difb = new DiffuseBrdf
    difb.pigment = mypig
    difb.reflectance = refl
    return Brdf(difb)

method eval*(difb : DiffuseBrdf, normal : Normal, in_dir,out_dir : Vector, coord: Vec2d) : Color =
    ## Definition of eval method specific for DiffuseBrdf
    return (difb.reflectance / PI) * difb.pigment.get_color(coord)

# Material type definition

type Material* = ref object 
    ## Definition of type Material
    brdf* : Brdf
    emitted_radiance* : Pigment

proc newMaterial*(mybrdf = newDiffuseBrdf(), mypig = newUniformPigment(newColor(0,0,0))) : Material =
    ## Material constructor with possibility of using default arguments
    new(result)
    result.brdf = mybrdf
    result.emitted_radiance = mypig
    return result


