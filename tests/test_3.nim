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

##Doing all the tests##

test_luminosity()