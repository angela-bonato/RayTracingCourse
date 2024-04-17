import ../src/hdrimage
import ../src/color
import std/math

##Tests on functions related to conversion from RGB to sRGB colors##

proc test_luminosity(): void =
    #[test of luminosity(Color) function]#
    var
        col1 = newColor(1.0, 2.0, 3.0)
        col2 = newColor(9.0, 5.0, 7.0)

    assert almostEqual(2.0, col1.luminosity())
    assert almostEqual(7.0, col2.luminosity())

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

proc test_average_luminosity() : void =
            
    let img = newHdrImage(2,1)
    img.setPixel(0,0,newColor(5.0, 10.0, 15.0))
    img.setPixel(1,0,newColor(500.0, 1000.0, 1500.0))

    assert img.average_luminosity(delta=0.0).almostEqual(100.0)

proc test_normalize_image() : void =

    let img = newHdrImage(2,1)
    img.setPixel(0,0,newColor(5.0, 10.0, 15.0))
    img.setPixel(1,0,newColor(500.0, 1000.0, 1500.0))

    img.normalize_image(factor = 1000.0, luminosity = 100.0)
    assert img.get_pixel(0, 0).is_close(newColor(0.5e2, 1.0e2, 1.5e2))
    assert img.get_pixel(1, 0).is_close(newColor(0.5e4, 1.0e4, 1.5e4))


##Doing all the tests##

#test_luminosity()
#test_clamp_image()
#test_average_luminosity()
#test_normalize_image()