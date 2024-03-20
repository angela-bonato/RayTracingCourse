import ../src/hdrimage
import ../src/color
import std/streams
import std/unittest

##Tests on functions related to conversion from RGB to sRGB colors##

proc test_luminosity(): void =
    #[test of luminosity(Color) function]#
    var
        col1 = newColor(1.0, 2.0, 3.0)
        col2 = newColor(9.0, 5.0, 7.0)

    assert is_close(2.0, col1.luminosity())
    assert is_close(7.0, col2.luminosity())

proc test_clamp_image(): void = 
    #[test on clamp_image() and clamp(x)]#

    #I define a test image
    var
        img = newHdrImage(2, 1)
    
    img.setPixel(0, 0, newColor(0.5e1, 1.0e1, 1.5e1))
    img.setPixel(1, 0, newColor(0.5e3, 1.0e3, 1.5e3))

    img.clamp_image()

    #I can just check that rgb values are in [0, 1] without checking the exact conversion
    for i in img.pixels.items :
        assert (i.r >= 0.0) and (i.r <= 1.0)
        assert (i.g >= 0.0) and (i.g <= 1.0)
        assert (i.b >= 0.0) and (i.b <= 1.0)


##Doing all the tests##

test_luminosity()
test_clamp_image()
