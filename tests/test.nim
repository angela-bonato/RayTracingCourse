import ../src/Types
import ../src/Procs

#tests on is_close function
proc test_is_close(): void =
    var 
        col1 = newColor(1.0, 2.0, 3.0)
        col2 = newColor(1.0, 2.0, 3.0)
        col3 = newColor(3.0, 4.0, 5.0)
    
    assert col1.is_close(col2)
    assert not col1.is_close(col3)

#tests on Color creation
proc test_color_creation(): void =
    var col = newColor(1.0, 2.0, 3.0)

    assert col.r.is_close(1.0)
    assert col.g.is_close(2.0)
    assert col.b.is_close(3.0)

#tests on HdrImage creation

#tests on the overloaded operators on Color elements
proc test_overload(): void =
    var
        col1 = newColor(1.0, 2.0, 3.0)
        col2 = newColor(5.0, 7.0, 9.0)
        col3 = newColor(6.0, 9.0, 12.0)
        col4 = newColor(5.0, 14.0, 27.0)
        col5 = newColor(2.0, 4.0, 6.0)
        scalar=2.0

    assert (col1 + col2).is_close(col3)
    assert (col1 * col2).is_close(col4)
    assert (scalar * col1).is_close(col5)


proc test_image_creation(): void =
    var img = newHdrImage(7,4)

    assert img.width == 7
    assert img.height == 4

#tests on HdrImage coordinates
proc test_coordinates(): void =
    var img = newHdrImage(7, 4)

    assert img.valid_coordinates(0, 0)
    assert img.valid_coordinates(6, 3)
    assert not img.valid_coordinates(-1, 0)   #coordinates in a matrix must be positive
    assert not img.valid_coordinates(0, -1)
    assert not img.valid_coordinates(7, 0)   #width=7 means width range is from 0 to 6
    assert not img.valid_coordinates(0, 4)

#tests on HdrImage pixels conversion from array to matrix
proc test_pixel_offset(): void =
    var img = newHdrImage(7, 4)

    assert img.pixel_offset(0, 0,)==0
    assert img.pixel_offset(3, 2,)==17
    assert img.pixel_offset(6, 3,)==7*4-1

#tests on HdrImage pixels methods
proc test_get_set_pixel(): void =
    var
        img = newHdrImage(7, 4)
        col = newColor(1.0, 2.0, 3.0)

    img.setPixel(3, 2, col)

    assert col.is_close(img.getPixel(3, 2))

#doing all the tests

test_is_close()
test_color_creation()
test_overload()
test_image_creation()
test_coordinates()
test_pixel_offset()
test_get_set_pixel()