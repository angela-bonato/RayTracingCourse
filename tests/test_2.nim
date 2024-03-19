import ../src/Types
import ../src/Procs_methods
import ../src/Procs_pfm
import std/streams
import std/unittest

##Tests on functions related to pfm files##

proc test_write_pfm() : void =
    #[tests on write_pfm()]#
    var 
        img_w = newHdrImage(3, 2)
        img_r : HdrImage
        mystream_write = newFileStream("tests/test_ReadWrite.pfm", fmWrite)

    img_w.setPixel(0, 0, newColor(1.0e1, 2.0e1, 3.0e1)) 
    img_w.setPixel(1, 0, newColor(4.0e1, 5.0e1, 6.0e1)) 
    img_w.setPixel(2, 0, newColor(7.0e1, 8.0e1, 9.0e1)) 
    img_w.setPixel(0, 1, newColor(1.0e2, 2.0e2, 3.0e2)) 
    img_w.setPixel(1, 1, newColor(4.0e2, 5.0e2, 6.0e2))
    img_w.setPixel(2, 1, newColor(7.0e2, 8.0e2, 9.0e2))

    img_w.write_pfm(mystream_write)

    mystream_write.close()

    var mystream_read = newFileStream("tests/test_ReadWrite.pfm", fmRead)
    img_r = mystream_read.read_pfm_image()

    assert img_r.is_close(img_w)

    mystream_read.close()

##Tests related to the reading of a pfm file##

proc test_readLine(): void =
    #[test on readline function]#
    var 
        stream = newStringStream("hello\nworld")
        line = ""

    assert stream.readLine(line)
    assert line == "hello"
    assert stream.readLine(line)
    assert line == "world"

proc test_parse_img_size(): void =
    #[test on parse_img_size()]#
    assert parse_img_size("3 2") == (3, 2)

    expect InvalidPfmFileFormat:
        var a = parse_img_size("3 2 1")
    
    expect InvalidPfmFileFormat:
        var b = parse_img_size("-1 3")

proc test_parse_endianness(): void =
    #[test on parse_endianness()]#
    assert parse_endianness("1.0") == bigEndian
    assert parse_endianness("-1.0") == littleEndian

    expect InvalidPfmFileFormat:
        var a = parse_endianness("abc")
    
    expect InvalidPfmFileFormat:
        var a = parse_endianness("0")

proc test_read_pfm_image() : void =
    #[test on read_pfm_image()]#
    let references = ["tests/reference_le.pfm", "tests/reference_be.pfm"]

    for filename in references.items :
        let 
            stream = newFileStream(filename, fmRead)
            img = stream.read_pfm_image()
        assert img.width == 3
        assert img.height == 2

        assert img.getPixel(0,0).is_close(newColor(1.0e1, 2.0e1, 3.0e1))
        assert img.getPixel(1,0).is_close(newColor(4.0e1, 5.0e1, 6.0e1))
        assert img.getPixel(2,0).is_close(newColor(7.0e1, 8.0e1, 9.0e1))
        assert img.getPixel(0,1).is_close(newColor(1.0e2, 2.0e2, 3.0e2))
        assert img.getPixel(1,1).is_close(newColor(4.0e2, 5.0e2, 6.0e2))
        assert img.getPixel(2,1).is_close(newColor(7.0e2, 8.0e2, 9.0e2))

        stream.close()

##Execute all tests##

#test_write_pfm()
#test_readLine()
#test_parse_img_size()
#test_parse_endianness()
#test_read_pfm_image()




