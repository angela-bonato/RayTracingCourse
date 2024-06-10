## tests on scenecompiler.nim

import ../src/scenecompiler
import std/unittest
import std/streams

suite "Test InputStream":
    ## Tests on InputStream type and procs
    
    setup:
        var istream = newInputStream(stream = newStringStream("abc   \nd\nef"))

    test "Test on read_char":
        assert istream.location.line_num == 1
        assert istream.location.col_num == 1

        assert istream.read_char() == 'a'
        assert istream.location.line_num == 1
        assert istream.location.col_num == 2
    echo "Test on read_char ended"

    test "Test on unread_char":

        assert istream.read_char() == 'a'

        istream.unread_char('A')

        assert istream.location.line_num == 1
        assert istream.location.col_num == 1

        assert istream.read_char() == 'A'
        assert istream.location.line_num == 1
        assert istream.location.col_num == 2

        assert istream.read_char() == 'b'
        assert istream.location.line_num == 1
        assert istream.location.col_num == 3

        assert istream.read_char() == 'c'
        assert istream.location.line_num == 1
        assert istream.location.col_num == 4
    echo "Test on unread_char ended"

    test "Test on skip_whites_comms":

        assert istream.read_char() == 'a'
        assert istream.read_char() == 'b'
        assert istream.read_char() == 'c'

        istream.skip_whites_comms()

        assert istream.read_char() == 'd'

        assert istream.location.line_num == 2
        assert istream.location.col_num == 2

        assert istream.read_char() == '\n'
        assert istream.location.line_num == 3
        assert istream.location.col_num == 1

        assert istream.read_char() == 'e'
        assert istream.location.line_num == 3
        assert istream.location.col_num == 2

        assert istream.read_char() == 'f'
        assert istream.location.line_num == 3
        assert istream.location.col_num == 3

        assert istream.read_char() == '\0'
    echo "Test on skip_whites_comms ended"

    echo "InputStream test ended"

suite "Test read_token()":
    ## Test on read_token proc
    
    setup:
        var 
            istream = newInputStream(stream = newStringStream(" # This is a comment \n # This is another comment\n  new material sky_material( diffuse(image(\"my_file.pfm\")), <5.0, 500.0, 300.0> ) # Comment at the end of the line " ))
    
    test "read_token()":

        assert_is_keyword( istream.read_token(), KeywordEnum.NEW )
        assert_is_keyword( istream.read_token(), KeywordEnum.MATERIAL )
        assert_is_identifier( istream.read_token(), "sky_material")
        assert_is_symbol( istream.read_token(), "(")
        assert_is_keyword( istream.read_token(), KeywordEnum.DIFFUSE )
        assert_is_symbol( istream.read_token(), "(")
        assert_is_keyword( istream.read_token(), KeywordEnum.IMAGE )
        assert_is_symbol( istream.read_token(), "(")
        assert_is_string( istream.read_token(), "my_file.pfm")
        assert_is_symbol( istream.read_token(), ")")
        assert_is_symbol( istream.read_token(), ")")
        assert_is_symbol( istream.read_token(), ",")
        assert_is_symbol( istream.read_token(), "<")
        assert_is_number( istream.read_token(), 5.0)
        assert_is_symbol( istream.read_token(), ",")
        assert_is_number( istream.read_token(), 500.0)
        assert_is_symbol( istream.read_token(), ",")
        assert_is_number( istream.read_token(), 300.0)
        assert_is_symbol( istream.read_token(), ">")
        assert_is_symbol( istream.read_token(), ")")







    

        
