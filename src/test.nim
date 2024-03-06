#tests on is_close function
var col=Color(1.0, 2.0, 3.0)

assert col.is_close(Color(1.0, 2.0, 3.0))
assert not col.is_close(Color(3.0, 4.0, 5.0))

#tests on Color creation
proc test_color_creation():void=
    var col=Color(1.0, 2.0, 3.0)

    assert col.r.is_close(1.0)
    assert col.g.is_close(2.0)
    assert col.b.is_close(3.0)

#tests on the overloaded operators on Color elements
var
    col1=Color(1.0, 2.0, 3.0)
    col2=Color(5.0, 7.0, 9.0)
    scalar:float32
scalar=2.0

assert (col1 + col2).is_close(Color(6.0, 9.0, 12.0))
assert (col1 * col2).is_close(Color(5.0, 14.0, 27.0))
assert (col1 * scalar).is_close(Color(2.0, 4.0, 6.0))

#tests on HdrImage creation
proc test_image_creation():void=
    var img=HdrImage(7, 4)

    assert img.width==7
    assert img.height==4

#tests on HdrImage coordinates
proc test_coordinates():void=
    var img=HdrImage(7, 4)

    assert img.valid_coordinates(0, 0)
    assert img.valid_coordinates(6, 3)
    assert not img.valid_coordinates(-1, 0)   #coordinates in a matrix must be positive
    assert not img.valid_coordinates(0, -1)
    assert not img.valid_coordinates(7, 0)   #width=7 means width range is from 0 to 6
    assert not img.valid_coordinates(0, 4)

#tests on HdrImage pixels conversion from array to matrix
proc test_pixel_offset():void=
    var img=HdrImage(7, 4)

    assert img.pixel_offset(0, 0,)==0
    assert img.pixel_offset(3, 2,)==17
    assert img.pixel_offset(6, 3,)==7*4-1

#tests on HdrImage pixels methods
proc test_get_set_pixel():void=
    var
        img=HdrImage(7, 4)
        col=Color(1.0, 2.0, 3.0)

    img.setPixel(3, 2, col)

    assert col.is_close(img.getPixel(3, 2))