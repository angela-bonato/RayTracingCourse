## Here we define the compiler for the programming lenguange that describes the scene

# SourceLocation definition and procs

type SourceLocation* = object
    ## A specific position in a source file
    ## This class has the following fields:
    ## - file_name: the name of the file, or the empty string if there is no file associated with this location
    ##   (e.g., because the source code was provided as a memory stream, or through a network connection)
    ## - line_num: number of the line (starting from 1)
    ## - col_num: number of the column (starting from 1)
    file_name : string
    line_num : int
    col_num : int

proc newSourceLocation*( file_name = "", line_num = 0, col_num = 0 ) : SourceLocation =
    ## SourceLocation constructor
    result.file_name = file_name
    result.line_num = line_num
    result.col_num = col_num

# GrammarError definition

type GrammarError* = object of CatchableError 
    ## An error found by the lexer/parser while reading a scene file
    ## The fields of this type are the following:
    ## - `file_name`: the name of the file, or the empty string if there is no real file
    ## - `line_num`: the line number where the error was discovered (starting from 1)
    ## - `col_num`: the column number where the error was discovered (starting from 1)
    ## - `message`: a user-frendly error message
    location : SourceLocation
    msg : string