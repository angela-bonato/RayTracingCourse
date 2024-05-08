import ../src/color
import ../src/hdrimage
import std/math

##Tests on Color and HRDImage classes##

proc test_col_is_close(): void =
    #[tests on is_close function for clolors and floats]#
    var 
        col1 = newColor(1.0, 2.0, 3.0)
    
    assert col1.is_close(newColor(1.0, 2.0, 3.0))
    assert not col1.is_close(newColor(3.0, 4.0, 5.0))

proc test_img_is_close(): void =
    #[tests on is_close function for HdrImage and ints]#
    var 
        img1 = newHdrImage(1, 2)
        img2 = newHdrImage(1, 2)
        img3 = newHdrImage(3, 2)
        col1 = newColor(1.0, 2.0, 3.0)
        col2 = newColor(3.0, 4.0, 5.0)
    
    img1.setPixel(0, 0, col1)
    img1.setPixel(0, 1, col2)

    img2.setPixel(0, 0, col1)
    img2.setPixel(0, 1, col2)
    
    assert img1.is_close(img2)
    assert not img1.is_close(img3)

proc test_color_creation(): void =
    #[tests on Color creation]#
    var col = newColor(1.0, 2.0, 3.0)

    assert col.r.almostEqual(1.0)
    assert col.g.almostEqual(2.0)
    assert col.b.almostEqual(3.0)

proc test_overload(): void =
    #[tests on the overloaded operators on Color elements]#
    var
        col1 = newColor(1.0, 2.0, 3.0)
        col2 = newColor(5.0, 7.0, 9.0)
        scalar=2.0

    assert (col1 + col2).is_close(newColor(6.0, 9.0, 12.0))
    assert (col1 * col2).is_close(newColor(5.0, 14.0, 27.0))
    assert (scalar * col1).is_close(newColor(2.0, 4.0, 6.0))

proc test_image_creation(): void =
    #[tests on HdrImage creation]#
    var img = newHdrImage(7,4)

    assert img.width == 7
    assert img.height == 4

proc test_coordinates(): void =
    #[tests on HdrImage coordinates]#
    var img = newHdrImage(7, 4)

    assert img.valid_coordinates(0, 0)
    assert img.valid_coordinates(6, 3)
    assert not img.valid_coordinates(-1, 0)   #coordinates in a matrix must be positive
    assert not img.valid_coordinates(0, -1)
    assert not img.valid_coordinates(7, 0)   #width=7 means width range is from 0 to 6
    assert not img.valid_coordinates(0, 4)

proc test_pixel_offset(): void =
    #[tests on HdrImage pixels conversion from array to matrix]#
    var img = newHdrImage(7, 4)

    assert img.pixel_offset(0, 0,)==0
    assert img.pixel_offset(3, 2,)==17
    assert img.pixel_offset(6, 3,)==7*4-1

proc test_get_set_pixel(): void =
    #[tests on HdrImage pixels methods]#
    var
        img = newHdrImage(7, 4)
        col = newColor(1.0, 2.0, 3.0)

    img.setPixel(3, 2, col)

    assert col.is_close(img.getPixel(3, 2))

#doing all the tests

test_col_is_close()
test_img_is_close()
test_color_creation()
test_overload()
test_image_creation()
test_coordinates()
test_pixel_offset()
test_get_set_pixel()