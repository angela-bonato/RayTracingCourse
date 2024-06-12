## Here we define the compiler for the programming lenguange that describes the scene

import std/streams
import std/strutils
import std/options
import std/tables
import materials
import world
import camera

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

# Keywords definition usefull to define KeywordToken

type KeywordEnum* = enum
    NEW, MATERIAL, CAMERA, ORTHOGONAL, PERSPECTIVE, FLOAT,
    PLANE, SPHERE, PARALLELEPIPED,
    UNITE, SUBTRACT, INTERSECT,
    DIFFUSE, SPECULAR,
    UNIFORM, CHECKERED, IMAGE,
    TRANSLATION, ROTATION_X, ROTATION_Y, ROTATION_Z, SCALING

let keywordMap* = {
  "new": NEW, "material": MATERIAL, "camera": CAMERA, "orthogonal": ORTHOGONAL, "perspective": PERSPECTIVE, "float": FLOAT,
  "plane": PLANE, "sphere": SPHERE, "parallelepiped": PARALLELEPIPED,
  "unite": UNITE, "subtract": SUBTRACT, "intersect": INTERSECT,
  "diffuse": DIFFUSE, "specular": SPECULAR,
  "uniform": UNIFORM, "checkered": CHECKERED, "image": IMAGE,
  "translation": TRANSLATION, "rotation_x": ROTATION_X, "rotation_y": ROTATION_Y, "rotation_z": ROTATION_Z, "scaling": SCALING
}.toTable

proc string_to_keyword*( str : string, location : SourceLocation ) : KeywordEnum =
    if str in keywordMap:
        let keyword = keywordMap[str]
        return keyword
    else:
        raise new(KeyError)

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


# InputStream definition

type InputStream* = object
    ## Type used to read the input file, with the possibiliti of look ahead one char
    stream*: Stream
    location*: SourceLocation
    saved_char*: char
    saved_location*: SourceLocation
    tab*: int
    saved_token : Option[Token]

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
            while not (istream.stream.readChar() in ['\n', '\r', '\0']):
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

# Token parsing procs 

proc parse_string_token*(istream : var InputStream, token_location : SourceLocation) : Token =

    var 
        token = ""
        ch : char

    while true:
        ch = istream.read_char()
        if ch == '"':
            break
        if ch == '\0':
            raise GrammarError.newException( message = "unterminated string at (" & $token_location.line_num & "," & $token_location.col_num & ") of " & token_location.file_name )
        token = token & ch

    return newStringToken(token_location, token)

proc parse_float_token*(istream : var InputStream, first_char : char, token_location : SourceLocation) : Token =

    var 
        token = $first_char
        ch : char
        value : float

    while true:
        ch = istream.read_char()
        if not ( ch.isDigit() or ch == '.' or ch in ['e', 'E'] ): 
            istream.unread_char(ch)
            break
        token = token & ch
    
    try:
        value = parseFloat(token)
    except ValueError:
        raise GrammarError.newException(message = token & " is an invalid floating-point number at (" & $token_location.line_num & "," & $token_location.col_num & ") of " & token_location.file_name )

    return newLiteralNumberToken(token_location, value)

proc parse_keyword_or_identifier_token*(istream : var InputStream, first_char : char, token_location : SourceLocation) : Token =

    var
        token = $first_char
        ch : char

    while true:
        ch = istream.read_char()
        if not (ch.isAlphaNumeric() or ch == '_') :
            istream.unread_char(ch)
            break
        token = token & ch

    try:
        return newKeywordToken(token_location, string_to_keyword(token, token_location) )
    except KeyError:
        return newIdentifierToken(token_location, token)


proc read_token*( istream : var InputStream ) : Token =

    var 
        ch : char
        token_location : SourceLocation

    if istream.saved_token.isSome():
        result = istream.saved_token.get()
        istream.saved_token = none(Token)
        return result

    istream.skip_whites_comms()

    ch = istream.read_char()

    if ch == '\0':
        # No more characters in the file, so return a StopToken
        return newStopToken(istream.location)

    # At this point we must check what kind of token begins with the "ch" character (which has been
    # put back in the stream with self.unread_char). First, we save the position in the stream
    token_location = istream.location

    if ch in ['(',')','[',']','<','>',',','*']:
        # One-character symbol
        return newSymbolToken(token_location, $ch) 
    elif ch == '"':
        # A literal string (used for file names)
        return istream.parse_string_token(token_location)
    elif ch.isDigit() or ch in ['+','-','.']:
        # A floating point number
        return istream.parse_float_token(ch, token_location)
    elif ch.isAlphaAscii() or ch == '_':
        # Since it begins with an alphabetic character, it must either be a keyword or a identifier
        return istream.parse_keyword_or_identifier_token(ch, token_location)
    else:
        # We got some weird character, like '@` or `&`
        raise GrammarError.newException( message = "Invalid character " & $ch & " at (" & $token_location.line_num & "," & $token_location.col_num & ") of " & token_location.file_name )

proc unread_token*(istream : var InputStream, token: Token) : void =
        ## Make as if `token` were never read from `input_file`
        assert istream.saved_token.isNone()
        istream.saved_token = some(token)


# Useful procs for test

proc assert_is_keyword*(token: Token, keyword : KeywordEnum) : void =
    assert token.kind == KeywordToken
    assert token.keyword == keyword, "Token " & token.to_string() & " is not equal to keyword " & $keyword

proc assert_is_identifier*(token: Token, identifier : string) : void =
    assert token.kind == IdentifierToken
    assert token.ident == identifier, "Expecting identifier " & identifier & " instead of " & token.to_string()

proc assert_is_symbol*(token: Token, symbol : string) : void =
    assert token.kind == SymbolToken
    assert token.symbol == symbol, "Expecting symbol " & symbol & " instead of " & token.to_string()

proc assert_is_number*(token: Token, num : float) : void =
    assert token.kind == LiteralNumberToken
    assert token.value == num, "Token " & token.to_string() & " is not equal to number " & $num

proc assert_is_string*(token: Token, str: string) : void =
    assert token.kind == StringToken
    assert token.str == str, "Token " & token.to_string() & " is not equal to string " & str


# Scene class 

type Scene* : object 
    ## Scene class that have to be red from the File
    materials : Table[string, Material]
    world : World
    camera : Option[Camera]
    float_variables : Table[string, float]
    overridden_variables : seq[string]

# expect_* procs

proc expect_symbol*( istream: InputStream, symbol: string) : void = 
    ## Read a token from input_file and check that it is the expected symbol
    var token = istream.read_token()
    if token.kind != SymbolToken or token.symbol != symbol:
        raise GrammarError.newException( message = "Missing " & symbol & " at (" & $token_location.line_num & "," & $token_location.col_num & ") of " & token_location.file_name )

proc expect_keywords*( istream: InputStream, keywords: seq[KeywordEnum] ) : KeywordEnum =
    ## Read a token from input_file and check that it is one of the expected keywords
    var token = istream.read_token()
    if (token.kind != KeywordToken) or (token.keyword not in keywords) :
        raise GrammarError.newException( message = "Got unexpected or wrong kewyword at (" & $token_location.line_num & "," & $token_location.col_num & ") of " & token_location.file_name )
    return token.keyword

proc expect_number*( istream: InputStream, scene: Scene) : float =
    ## Read a token and check if it is a number (could be LiteralNumber or Identifier ) 
    var token = istream.read_token()
    if token.kind == LiteralNumberToken:
        return token.value
    elif token.kind == IdentifierToken:
        var variable_name = token.ident 
        if not scene.float_variables.hasKey(variable_name):
            raise GrammarError.newException( message = "Unknown variable " & variable_name )
        return scene.float_variables[variable_name]

    raise GrammarError.newException( message = "Missing number at (" & $token_location.line_num & "," & $token_location.col_num & ") of " & token_location.file_name )

proc expect_string*( istream: InputStream ) : string =
    ## Read a token and check if it is a string
    var token = istream.read_token()
    if token.kind != StringToken:
        raise GrammarError.newException( message = "Missing string at (" & $token_location.line_num & "," & $token_location.col_num & ") of " & token_location.file_name )
    return token.str

proc expect_identifier*( istream: InputStream ) : string =
    ## Read a token and check if it is an identifier
    var token = istream.read_token()
    if token.kind != IdentifierToken:
        raise GrammarError.newException( message = "Missing identifier at (" & $token_location.line_num & "," & $token_location.col_num & ") of " & token_location.file_name )
    return token.ident

