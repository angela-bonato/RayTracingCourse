import std/unittest
import ../src/hdrimage
import ../src/color
import ../src/materials
import ../src/world
import ../src/ray
import ../src/geometry
import ../src/renderprocs

suite "Test Pigment":
    ## Tests on all Pigment types
    echo "Started tests on Pigment"
    
    setup:
        echo "New test started"

    teardown:
        echo "Test ended"

    test "UniformPigment":
        var 
            color = newColor(1.0, 2.0, 3.0)
            unipig = newUniformPigment(color)

        assert unipig.get_color(newVec2d(0.0, 0.0)).is_close(color)
        assert unipig.get_color(newVec2d(1.0, 0.0)).is_close(color)
        assert unipig.get_color(newVec2d(0.0, 1.0)).is_close(color)
        assert unipig.get_color(newVec2d(1.0, 1.0)).is_close(color)

    test "CheckeredPigment":
        var 
            col1 = newColor(1.0, 2.0, 3.0)
            col2 = newColor(10.0, 20.0, 30.0)
            chepig = newCheckeredPigment(col1, col2, 2, 2)
        
        assert chepig.get_color(newVec2d(0.25, 0.25)).is_close(col1)
        assert chepig.get_color(newVec2d(0.75, 0.25)).is_close(col2)
        assert chepig.get_color(newVec2d(0.25, 0.75)).is_close(col2)
        assert chepig.get_color(newVec2d(0.75, 0.75)).is_close(col1)

    test "ImagePigment":
        var texture = newHdrImage(3, 2)
        texture.setPixel(0, 0, newColor(1.0, 2.0, 3.0))
        texture.setPixel(1, 0, newColor(2.0, 3.0, 1.0))
        texture.setPixel(2, 0, newColor(4.0, 5.0, 6.0))
        texture.setPixel(0, 1, newColor(2.0, 1.0, 3.0))
        texture.setPixel(1, 1, newColor(3.0, 2.0, 1.0))
        texture.setPixel(2, 1, newColor(6.0, 5.0, 4.0))

        var impig = newImagePigment(texture)
        
        assert impig.get_color(newVec2d(0.0, 0.0)).is_close(newColor(1.0, 2.0, 3.0))
        assert impig.get_color(newVec2d(0.5, 0.0)).is_close(newColor(2.0, 3.0, 1.0))
        assert impig.get_color(newVec2d(1.0, 0.0)).is_close(newColor(4.0, 5.0, 6.0))
        assert impig.get_color(newVec2d(0.0, 1.0)).is_close(newColor(2.0, 1.0, 3.0))
        assert impig.get_color(newVec2d(0.5, 1.0)).is_close(newColor(3.0, 2.0, 1.0))
        assert impig.get_color(newVec2d(1.0, 1.0)).is_close(newColor(6.0, 5.0, 4.0))
    
    echo "Ended tests on Pigment"

suite "Test SolveRenderingProcs":
    ## Tests on SolveRenderingProcs types
    echo "Started tests on SolveRenderingProcs"
    
    setup:
        var
            shape_color = newColor(50,150,250)
            shape_pigment = newUniformPigment(shape_color)
            shape_brdf = newDiffuseBrdf( pigment = shape_pigment )
            material = newMaterial(brdf = shape_brdf)
            sphere = newSphere(material = material)
            ray1 = newRay(origin = newPoint(0,0,-2), dir = newVector(0,0,1))
            ray2 = newRay(origin = newPoint(0,0,-2), dir = newVector(0,0,-1))
        echo "New test started"

    teardown:
        echo "Test ended"

    test "Test on FlatRenderer":
        var
            background_color = newColor(20,30,40)
            scene = newWorld() 
        
        scene.add(sphere)
            
        var 
            color1 = FlatRenderer(scene, ray1, background_color)
            color2 = FlatRenderer(scene, ray2, background_color)

        assert color1.is_close(shape_color)
        assert color2.is_close(background_color)


    echo "Ended tests on SolveRenderingProcs"
        
