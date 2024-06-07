## tests on scenecompiler.nim

import ../src/scenecompiler
import std/unittest
import std/streams

suite "Test InputStream":
    ## Tests on InputStream type and procs
    
    setup:
        var istream = newInputStream(stream = newStringStream("abc   \nd\nef"))

    teardown:
        echo "InputStream test ended"

    test "Test on read_char":
        assert istream.location.line_num == 1
        assert istream.location.col_num == 1

        assert istream.read_char() == 'a'
        assert istream.location.line_num == 1
        assert istream.location.col_num == 2
    echo "Test on read_char ended"

    test "Test on unread_char":
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

        assert istream.read_char() == ' '
    echo "Test on skip_whites_comms ended"
    





    

        
