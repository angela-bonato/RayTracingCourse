## Here we define the compiler for the programming lenguange that describes the scene

import std/streams

# SourceLocation definition and procs

type SourceLocation* = object
    ## A specific position in a source file
    ## This class has the following fields:
    ## - file_name: the name of the file, or the empty string if there is no file associated with this location
    ##   (e.g., because the source code was provided as a memory stream, or through a network connection)
    ## - line_num: number of the line (starting from 1)
    ## - col_num: number of the column (starting from 1)
    file_name*: string
    line_num*: int
    col_num*: int

proc newSourceLocation*( file_name = "", line_num = 0, col_num = 0 ) : SourceLocation =
    ## SourceLocation constructor
    result.file_name = file_name
    result.line_num = line_num
    result.col_num = col_num

# InputStream definition

type InputStream* = object
    ## Type used to read the input file, with the possibiliti of look ahead one char
    stream*: Stream
    location*: SourceLocation
    saved_char*: char
    saved_location*: SourceLocation
    tab*: int

proc newInputStream*(stream: Stream, file_name = "", tab = 4) : InputStream =
    ## constructor for InputStream type
    result.stream = stream
    result.location = newSourceLocation(file_name = file_name, line_num = 1, col_num = 1)  #note: we start counting lines and colums from 1 not 0
    result.saved_char = '\0'
    result.saved_location = result.location
    result.tab = tab
    return result

proc update_pos*(istream: var InputStream, ch: char): void =
    ## update istream.location each time a char is read from the file
    if ch == '\0':  #if ch=='' do nothing
        return
    elif ch == '\n':
        istream.location.line_num += 1
        istream.location.col_num = 1
    elif ch == '\t':
        istream.location.col_num += istream.tab
    else:
        istream.location.col_num += 1

proc read_char*(istream: var InputStream): char =
    ## Read a character from the stream
    var ch: char
    if istream.saved_char != '\0':    # re-reads the previously discarted character
        ch = istream.saved_char
        istream.saved_char = '\0'
    else:
        ch = istream.stream.readChar()
    
    var loc = istream.location
    istream.saved_location = loc
    istream.update_pos(ch)
    
    return ch

proc unread_char*(istream: var InputStream, ch: char): void =
    ## Puts a char back in the position where it previously red it in order to be able to read it again
    assert istream.saved_char == '\0'
    istream.saved_char = ch
    var loc = istream.saved_location
    istream.location = loc

proc skip_whites_comms*(istream: var InputStream): void =
    ## While reading the InputStream skip white spaces and comments
    var ch = istream.read_char()
    while ch in [' ', '\t', '\n', '\r'] or ch == '#':
        if ch == '#':  #comment
            while not (istream.stream.readChar() in ['\n', '\r']):
                discard
        ch = istream.read_char()
        if ch == '\0':
            return
    istream.unread_char(ch)  #I put back at its place the first character non whitespace or comment

# GrammarError definition

type GrammarError* = object of CatchableError 
    ## An error found by the lexer/parser while reading a scene file
    ## The fields of this type are the following:
    ## - `file_name`: the name of the file, or the empty string if there is no real file
    ## - `line_num`: the line number where the error was discovered (starting from 1)
    ## - `col_num`: the column number where the error was discovered (starting from 1)
    ## - `message`: a user-frendly error message
    location*: SourceLocation
    message*: string

# Keywords definition usefull to define KeywordToken

type KeywordEnum* = enum
    ## Here we define all the keywords that a user can use to define the scene
    # generic 
    NEW = "new", MATERIAL = "material", CAMERA = "camera", ORTHOGONAL = "orthogonal", PERSPECTIVE = "perspective", FLOAT = "float",
    # shapes 
    PLANE = "plane", SPHERE = "sphere", PARALLELEPIPED = "parallelepiped",
    # CSG
    UNITE = "unite", SUBTRACT = "subtract", INTERSECT = "intersect",
    # BRDF
    DIFFUSE = "diffuse", SPECULAR = "specular", 
    # pigments
    UNIFORM = "uniform", CHECKERED = "checkered", IMAGE = "image",
    # transformations
    TRANSLATION = "translation", ROTATION_X = "rotation_x", ROTATION_Y = "rotation_y", ROTATION_Z = "rotation_y", SCALING = "scaling"

#Tokens definition

type 

    TokenKind* = enum 
        ## All possible kinds of token
        StopToken, KeywordToken, IdentifierToken, StringToken, LiteralNumberToken, SymbolToken 
    
    Token* = object 
        ## Definitions of token
        location*: SourceLocation
        
        case kind*: TokenKind 
            of StopToken: 
                discard
            of KeywordToken:
                keyword*: KeywordEnum
            of IdentifierToken:
                ident*: string
            of StringToken:
                str*: string
            of LiteralNumberToken:
                value*: float
            of SymbolToken:
                symbol*: string

## Token constructors

proc newStopToken*(location: SourceLocation): Token {.inline.} =
    Token(location: location, kind: StopToken)

proc newKeywordToken*(location: SourceLocation, keyword: KeywordEnum): Token {.inline.} =
    Token(location: location, kind: KeywordToken, keyword: keyword)

proc newIdentifierToken*(location: SourceLocation, ident: string): Token {.inline.} =
    Token(location: location, kind: IdentifierToken, ident: ident)

proc newStringToken*(location: SourceLocation, str: string): Token {.inline.} =
    Token(location: location, kind: StringToken, str: str)

proc newLiteralNumberToken*(location: SourceLocation, value: float): Token {.inline.} =
    Token(location: location, kind: LiteralNumberToken, value: value)

proc newSymbolToken*(location: SourceLocation, symbol: string): Token {.inline.} =
    Token(location: location, kind: SymbolToken, symbol: symbol)

proc to_string*(token: Token): string =
    ## returns the argument of a token as a string
    case token.kind:
        of StopToken:
            discard
        of KeywordToken:
            return $(token.keyword)
        of IdentifierToken:
            return token.ident    #already string type
        of StringToken:
            return token.str    #already string type
        of LiteralNumberToken:
            return $(token.value)
        of SymbolToken:
            return token.symbol    #already string type

