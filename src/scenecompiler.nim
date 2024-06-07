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
                str*: string
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

proc newIdentifierToken*(location: SourceLocation, str: string): Token {.inline.} =
    Token(location: location, kind: IdentifierToken, str: str)

proc newStringToken*(location: SourceLocation, str: string): Token {.inline.} =
    Token(location: location, kind: StringToken, str: str)

proc newLiteralNumberToken*(location: SourceLocation, value: float): Token {.inline.} =
    Token(location: location, kind: LiteralNumberToken, value: value)

proc newSymbolToken*(location: SourceLocation, value: string): Token {.inline.} =
    Token(location: location, kind: SymbolToken, value: value)

proc to_string*(token: Token): string =
    ## returns the argumetn of a token as strings
    case token.kind:
        of KeywordToken:
            return $(token.keyword)
        of IdentifierToken:
            return token.str    #already string type
        of StringToken:
            return token.str    #already string type
        of LiteralNumberToken:
            return $(token.value)
        of SymbolToken:
            return token.symbol    #already string type

