import std/unittest
import ../src/hdrimage
import ../src/shapes
import ../src/color
import ../src/materials

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
        var texture = newHdrImage(2, 2)
        texture.setPixel(0, 0, newColor(1.0, 2.0, 3.0))
        texture.setPixel(1, 0, newColor(2.0, 3.0, 1.0))
        texture.setPixel(0, 1, newColor(2.0, 1.0, 3.0))
        texture.setPixel(1, 1, newColor(3.0, 2.0, 1.0))

        var impig = newImagePigment(texture)

        assert impig.get_color(newVec2d(0.0, 0.0)).is_close(newColor(1.0, 2.0, 3.0))
        assert impig.get_color(newVec2d(1.0, 0.0)).is_close(newColor(2.0, 3.0, 1.0))
        assert impig.get_color(newVec2d(0.0, 1.0)).is_close(newColor(2.0, 1.0, 3.0))
        assert impig.get_color(newVec2d(1.0, 1.0)).is_close(newColor(3.0, 2.0, 1.0))
    
    echo "Ended tests on Pigment"