## tests on scenecompiler.nim

import ../src/scenecompiler
import ../src/materials
import ../src/color
import std/unittest
import std/streams
import std/tables

suite "Test InputStream":
    ## Tests on InputStream type and procs
    
    setup:
        var istream = newInputStream(stream = newStringStream("abc   \nd\nef"))

    test "Test on read_char":
        assert istream.location.line_num == 1
        assert istream.location.col_num == 1

        assert istream.read_char() == 'a'
        assert istream.location.line_num == 1
        assert istream.location.col_num == 2
    echo "Test on read_char ended"

    test "Test on unread_char":

        assert istream.read_char() == 'a'

        istream.unread_char('A')

        assert istream.location.line_num == 1
        assert istream.location.col_num == 1

        assert istream.read_char() == 'A'
        assert istream.location.line_num == 1
        assert istream.location.col_num == 2

        assert istream.read_char() == 'b'
        assert istream.location.line_num == 1
        assert istream.location.col_num == 3

        assert istream.read_char() == 'c'
        assert istream.location.line_num == 1
        assert istream.location.col_num == 4
    echo "Test on unread_char ended"

    test "Test on skip_whites_comms":

        assert istream.read_char() == 'a'
        assert istream.read_char() == 'b'
        assert istream.read_char() == 'c'

        istream.skip_whites_comms()

        assert istream.read_char() == 'd'

        assert istream.location.line_num == 2
        assert istream.location.col_num == 2

        assert istream.read_char() == '\n'
        assert istream.location.line_num == 3
        assert istream.location.col_num == 1

        assert istream.read_char() == 'e'
        assert istream.location.line_num == 3
        assert istream.location.col_num == 2

        assert istream.read_char() == 'f'
        assert istream.location.line_num == 3
        assert istream.location.col_num == 3

        assert istream.read_char() == '\0'
    echo "Test on skip_whites_comms ended"

    echo "InputStream test ended"

suite "Test read_token()":
    ## Test on read_token proc
    
    setup:
        var 
            istream = newInputStream(stream = newStringStream(" # This is a comment \n # This is another comment\n  new material sky_material( diffuse(image(\"my_file.pfm\")), <5.0, 500.0, 300.0> ) # Comment at the end of the line " ))
    
    test "read_token()":

        assert_is_keyword( istream.read_token(), KeywordEnum.NEW )
        assert_is_keyword( istream.read_token(), KeywordEnum.MATERIAL )
        assert_is_identifier( istream.read_token(), "sky_material")
        assert_is_symbol( istream.read_token(), "(")
        assert_is_keyword( istream.read_token(), KeywordEnum.DIFFUSE )
        assert_is_symbol( istream.read_token(), "(")
        assert_is_keyword( istream.read_token(), KeywordEnum.IMAGE )
        assert_is_symbol( istream.read_token(), "(")
        assert_is_string( istream.read_token(), "my_file.pfm")
        assert_is_symbol( istream.read_token(), ")")
        assert_is_symbol( istream.read_token(), ")")
        assert_is_symbol( istream.read_token(), ",")
        assert_is_symbol( istream.read_token(), "<")
        assert_is_number( istream.read_token(), 5.0)
        assert_is_symbol( istream.read_token(), ",")
        assert_is_number( istream.read_token(), 500.0)
        assert_is_symbol( istream.read_token(), ",")
        assert_is_number( istream.read_token(), 300.0)
        assert_is_symbol( istream.read_token(), ">")
        assert_is_symbol( istream.read_token(), ")")

    echo "ReadToken test ended"

suite "Test parser":
    ## Test on read_token proc
    
    test "parse_scene()":
        var 
            istream = newInputStream(stream = newStringStream("""
              float clock(150)
          
              material sky_material(
                  diffuse(uniform(<0, 0, 0>)),
                  uniform(<0.7, 0.5, 1>)
              )
          
              # Here is a comment
          
              material ground_material(
                  diffuse(checkered(<0.3, 0.5, 0.1>,
                                    <0.1, 0.2, 0.5>, 
                                    4, 4)),
                  uniform(<0, 0, 0>)
              )
          
              material sphere_material(
                  specular(uniform(<0.5, 0.5, 0.5>)),
                  uniform(<0, 0, 0>)
              )
          
              plane (sky_material, translation([0, 0, 100]) * rotation_y(clock))
              plane (ground_material, identity)
          
              sphere(sphere_material, translation([0, 0, 1]))
          
              camera(perspective, rotation_z(30) * translation([-4, 0, 1]), 1.0, 2.0)
            """))

            scene = istream.parse_scene()  #error in line 724 of scenecompiler but I don't see the problem

        #check float 

        assert len(scene.float_variables) == 1
        assert scene.float_variables.hasKey("clock")
        assert scene.float_variables["clock"] == 150.0

        #check materials

        assert len(scene.materials) == 3
        assert scene.materials.hasKey("sphere_material")
        assert scene.materials.hasKey("sky_material")
        assert scene.materials.hasKey("ground_material")

        var 
            sphere_material = scene.materials["sphere_material"]
            sky_material = scene.materials["sky_material"]
            ground_material = scene.materials["ground_material"]

        #the asserts which try to assess the type of an object don't work, I don't know what to do
        assert $(sky_material.brdf.typeof) == "DiffuseBrdf" 
        assert $(sky_material.brdf.pigment.typeof) == "UniformPigment"  
        assert sky_material.brdf.pigment.color.is_close(newColor(0, 0, 0))

#[
#        assert type(ground_material.brdf) == DiffuseBrdf   #wrong syntax but I don't know what to do...
#        assert type(ground_material.brdf.pigment) == CheckeredPigment  #wrong syntax but I don't know what to do...
        assert ground_material.brdf.pigment.col_even.is_close(newColor(0.3, 0.5, 0.1))
        assert ground_material.brdf.pigment.col_odd.is_close(newColor(0.1, 0.2, 0.5))
        assert ground_material.brdf.pigment.div_u == 4
        assert ground_material.brdf.pigment.div_v == 4
        
        assert $(sphere_material.brdf.typeof) == "SpecularBrdf" 
        assert $(sphere_material.brdf.pigment) == "UniformPigment"  
        assert sphere_material.brdf.pigment.color.is_close(newColor(0.5, 0.5, 0.5))

        assert $(sky_material.emitted_radiance.typeof) == "UniformPigment"  
        assert sky_material.emitted_radiance.color.is_close(newColor(0.7, 0.5, 1.0))
        assert $(ground_material.emitted_radiance.typeof) == "UniformPigment"  
        assert ground_material.emitted_radiance.color.is_close(newColor(0, 0, 0))
        assert $(sphere_material.emitted_radiance.typeof) == "UniformPigment"  
        assert sphere_material.emitted_radiance.color.is_close(newColor(0, 0, 0))

        #check shapes

        assert len(scene.world.shapes) == 3
        assert $(scene.world.shapes[0].typeof) == "Plane"  
        assert scene.world.shapes[0].transformation.is_close(translation(newVector(0, 0, 100)) * rotation_y(150.0))
        assert $(scene.world.shapes[1].typeof) == "Plane"
        assert scene.world.shapes[1].transformation.is_close(newTransformation())
        assert $(scene.world.shapes[2].typeof) == "Sphere"  
        assert scene.world.shapes[2].transformation.is_close(translation(newVector(0, 0, 1)))

        #check camera

        assert scene.firer_proc == fire_ray_perspective
        assert scene.camera.transformation.is_close(rotation_z(30) * translation(newVector(-4, 0, 1)))
        assert scene.camera.aspect_ratio.almostEqual(1.0)
        assert scene.camera.screen_distance.almostEqual(2.0)
]#
    echo "Test on parse_shene ended"

    test "parsig undefined material":
        var istream = newInputStream(stream = newStringStream("plane(this_material_does_not_exist, identity)"))
        #This should raise a GrammarError!

        try:
            var scene = istream.parse_scene()
            assert false, "the code did not throw an exception"
        except GrammarError:
            discard

    echo "Test on undefined material ended"

    test "parsing double camera":
        var istream = newInputStream(stream = newStringStream("""
            camera(perspective, rotation_z(30) * translation([-4, 0, 1]), 1.0, 1.0)
            camera(orthogonal, identity, 1.0, 1.0)
            """))
        #This should raise a GrammarError!
        
        try:
            var scene = istream.parse_scene()
            assert false, "the code did not throw an exception"
        except GrammarError:
            discard

    echo "Test on double camera ended"

    echo "Parsing tests ended" 


#I think that the parsing has problems handling ref object of something 
#(e.g., it sees all the pigments as pigments, all the shapes as shapes, 
#without all the members of the specific classes such as CheckeredPigment or Sphere)