import ../src/Types
import ../src/Procs
import std/streams
import std/unittest

##Tests on write_pfm##

proc test_write_pfm() : void =
    var 
        img = newHdrImage(3, 2)
        col1 = newColor(1.0e1, 2.0e1, 3.0e1)
        col2 = newColor(4.0e1, 5.0e1, 6.0e1)
        col3 = newColor(7.0e1, 8.0e1, 9.0e1)
        col4 = newColor(1.0e2, 2.0e2, 3.0e2)
        col5 = newColor(4.0e2, 5.0e2, 6.0e2)
        col6 = newColor(7.0e2, 8.0e2, 9.0e2)
        mystream = newFileStream("prova.pfm", fmWrite)
    
    #[This is the correct binary version of img]#
    var refbytes=[
    0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x2d, 0x31, 0x2e, 0x30, 0x0a,
    0x00, 0x00, 0xc8, 0x42, 0x00, 0x00, 0x48, 0x43, 0x00, 0x00, 0x96, 0x43,
    0x00, 0x00, 0xc8, 0x43, 0x00, 0x00, 0xfa, 0x43, 0x00, 0x00, 0x16, 0x44,
    0x00, 0x00, 0x2f, 0x44, 0x00, 0x00, 0x48, 0x44, 0x00, 0x00, 0x61, 0x44,
    0x00, 0x00, 0x20, 0x41, 0x00, 0x00, 0xa0, 0x41, 0x00, 0x00, 0xf0, 0x41,
    0x00, 0x00, 0x20, 0x42, 0x00, 0x00, 0x48, 0x42, 0x00, 0x00, 0x70, 0x42,
    0x00, 0x00, 0x8c, 0x42, 0x00, 0x00, 0xa0, 0x42, 0x00, 0x00, 0xb4, 0x42
    ]
    
    img.setPixel(0, 0, col1) 
    img.setPixel(1, 0, col2) 
    img.setPixel(2, 0, col3) 
    img.setPixel(0, 1, col4) 
    img.setPixel(1, 1, col5)
    img.setPixel(2, 1, col6)

    img.write_pfm(mystream)

    #assert mystream.read() == refbytes
    #echo refbytes

    mystream.close()

proc test_readLine(): void =
    var 
        stream = newStringStream("hello\nworld")
        line = ""

    assert stream.readLine(line)
    assert line == "hello"
    assert stream.readLine(line)
    assert line == "world"

proc text_parse_endianness(): void =
    assert parse_endianness("1.0") == bigEndian
    assert parse_endianness("-1.0") == littleEndian

    expect InvalidPfmFileFormat:
        var a = parse_endianness("abc")
    
    expect InvalidPfmFileFormat:
        var a = parse_endianness("0")


##Execute all tests##

#test_write_pfm()
#test_readLine()
text_parse_endianness()





