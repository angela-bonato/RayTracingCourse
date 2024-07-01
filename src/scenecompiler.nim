## Here we define the compiler for the programming lenguange that describes the scene

import std/streams
import std/strutils
import std/options
import std/tables
import materials
import world
import camera
import geometry
import color
import hdrimage

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

# Scene class 

type Scene* = object 
    ## Scene class that have to be red from the File
    materials* : Table[string, Material]
    world* : World
    camera* : Option[Camera]
    fire_proc* : Option[FireRayProcs]  #only way to specify camera type in our code
    float_variables* : Table[string, float]
    overridden_variables* : seq[string]

proc newScene*() : Scene =
    ## Scene class constructor
    result.materials = initTable[string, Material]()
    result.world = newWorld()
    result.float_variables = initTable[string, float]()
    result.overridden_variables = @[]

# Keywords definition usefull to define KeywordToken

type KeywordEnum* = enum
    NEW, MATERIAL, CAMERA, ORTHOGONAL, PERSPECTIVE, FLOAT,
    PLANE, SPHERE, PARALLELEPIPED,
    UNITE, SUBTRACT, INTERSECT,
    DIFFUSE, SPECULAR,
    UNIFORM, CHECKERED, IMAGE,
    IDENTITY, TRANSLATION, ROTATION_X, ROTATION_Y, ROTATION_Z, SCALING

let keywordMap* = {
  "new": NEW, "material": MATERIAL, "camera": CAMERA, "orthogonal": ORTHOGONAL, "perspective": PERSPECTIVE, "float": FLOAT,
  "plane": PLANE, "sphere": SPHERE, "parallelepiped": PARALLELEPIPED,
  "unite": UNITE, "subtract": SUBTRACT, "intersect": INTERSECT,
  "diffuse": DIFFUSE, "specular": SPECULAR,
  "uniform": UNIFORM, "checkered": CHECKERED, "image": IMAGE,
  "identity": IDENTITY, "translation": TRANSLATION, "rotation_x": ROTATION_X, "rotation_y": ROTATION_Y, "rotation_z": ROTATION_Z, "scaling": SCALING
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

# InputStream definition

type InputStream* = object
    ## Type used to read the input file, with the possibiliti of look ahead one char
    stream*: Stream
    location*: SourceLocation
    saved_char*: char
    saved_location*: SourceLocation
    tab*: int
    saved_token* : Option[Token]

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

# expect_* procs

proc expect_symbol*( istream: var InputStream, symbol: string) : void = 
    ## Read a token from input_file and check that it is the expected symbol
    var token = istream.read_token()
    if token.kind != SymbolToken or token.symbol != symbol:
        raise GrammarError.newException( message = "Missing " & symbol & " at (" & $token.location.line_num & "," & $token.location.col_num & ") of " & token.location.file_name )

proc expect_keywords*( istream: var InputStream, keywords: seq[KeywordEnum] ) : KeywordEnum =
    ## Read a token from input_file and check that it is one of the expected keywords
    var token = istream.read_token()
    if  ( (token.kind != KeywordToken) or not (token.keyword in keywords) ) :
        raise GrammarError.newException( message = "Got unexpected or wrong kewyword at (" & $token.location.line_num & "," & $token.location.col_num & ") of " & token.location.file_name )
    return token.keyword

proc expect_number*( istream: var InputStream, scene: Scene) : float =
    ## Read a token and check if it is a number (could be LiteralNumber or Identifier ) 
    var token = istream.read_token()
    if token.kind == LiteralNumberToken:
        return token.value
    elif token.kind == IdentifierToken:
        var variable_name = token.ident 
        if not scene.float_variables.hasKey(variable_name):
            raise GrammarError.newException( message = "Unknown variable " & variable_name )
        return scene.float_variables[variable_name]

    raise GrammarError.newException( message = "Missing number at (" & $token.location.line_num & "," & $token.location.col_num & ") of " & token.location.file_name )

proc expect_string*( istream: var InputStream ) : string =
    ## Read a token and check if it is a string
    var token = istream.read_token()
    if token.kind != StringToken:
        raise GrammarError.newException( message = "Missing string at (" & $token.location.line_num & "," & $token.location.col_num & ") of " & token.location.file_name )
    return token.str

proc expect_identifier*( istream: var InputStream ) : string =
    ## Read a token and check if it is an identifier
    var token = istream.read_token()
    if token.kind != IdentifierToken:
        raise GrammarError.newException( message = "Missing identifier at (" & $token.location.line_num & "," & $token.location.col_num & ") of " & token.location.file_name )
    return token.ident

#Parsing the scene

proc parse_vector*(istream: var InputStream, scene: Scene) : Vector =
    ##Read tokens and returns the corresponding vector
    ##syntax should be [x_component, y_component, z_component]
    istream.expect_symbol("[")
    var x = istream.expect_number(scene)
    istream.expect_symbol(",")
    var y = istream.expect_number(scene)
    istream.expect_symbol(",")
    var z = istream.expect_number(scene)
    istream.expect_symbol("]")

    return newVector(x, y, z)

proc parse_point*(istream: var InputStream, scene: Scene) : Point =
    ##Read tokens and returns the corresponding point
    ##syntax should be (x_component, y_component, z_component)
    istream.expect_symbol("(")
    var x = istream.expect_number(scene)
    istream.expect_symbol(",")
    var y = istream.expect_number(scene)
    istream.expect_symbol(",")
    var z = istream.expect_number(scene)
    istream.expect_symbol(")")

    return newPoint(x, y, z)

proc parse_color*(istream: var InputStream, scene: Scene) : Color =
    ##Read tokens and returns the corresponding color
    ##syntax should be <r_component, g_component, b_component>
    istream.expect_symbol("<")
    var red = istream.expect_number(scene)
    istream.expect_symbol(",")
    var green = istream.expect_number(scene)
    istream.expect_symbol(",")
    var blue = istream.expect_number(scene)
    istream.expect_symbol(">")

    return newColor(red, green, blue)

proc parse_pigment*(istream: var InputStream, scene: Scene) : Pigment =
    ##Read tokens and returns the corresponding pigment
    var keyword = istream.expect_keywords(@[UNIFORM, CHECKERED, IMAGE])
    istream.expect_symbol("(")
    var parsed_pig : Pigment

    #different pigments are initialized in different ways so I have to study all possible cases
    if keyword == UNIFORM :
        ##syntax should be uniform(<r_component, g_component, b_component>)
        var color = istream.parse_color(scene)
        parsed_pig = newUniformPigment(color)
    elif keyword == CHECKERED :
        ##syntax should be checkered(<r_comp1, g_comp1, b_comp1>, <r_comp2, g_comp2, b_comp2>, int, int)
        var color1 = istream.parse_color(scene)
        istream.expect_symbol(",")
        var color2 = istream.parse_color(scene)
        istream.expect_symbol(",")
        var div_u = int(istream.expect_number(scene))  #we want this to be optional?
        istream.expect_symbol(",")
        var div_v = int(istream.expect_number(scene))  #we want this to be optional?
        parsed_pig = newCheckeredPigment(color1, color2, div_u, div_v)
    elif keyword == IMAGE :
        ##syntax should be image(filename)
        var 
            filename = istream.expect_string()
            fstream = newFileStream(filename, fmRead )
            pigm_image = read_pfm_image(fstream)
        parsed_pig = newImagePigment(pigm_image) 
    else :
        assert false, "This line should be unreachable"  ###CONTROLLA STA COSAA

    istream.expect_symbol(")")
    return parsed_pig

proc parse_brdf*(istream: var InputStream, scene: Scene) : Brdf =
    ##Read tokens and returns the corresponding brdf
    var keyword = istream.expect_keywords(@[DIFFUSE, SPECULAR])
    istream.expect_symbol("(")
    var parsed_pig = istream.parse_pigment(scene)

    #different kinds of brdf 
    if keyword == DIFFUSE :
        ##syntax should be diffuse(pigment, float) or diffuse(pigment)

        #there is the possibility of specifying the reflectance but is optional so two things can happen
        var next_kw = istream.read_token()

        if next_kw.symbol == ",":
            #there is the specification of the reflectance
            var parsed_refl = istream.expect_number(scene)
            istream.expect_symbol(")")
            return newDiffuseBrdf(pigment = parsed_pig, refl = parsed_refl)
        elif next_kw.symbol == ")":
            #use default reflectance
            return newDiffuseBrdf(pigment = parsed_pig)
        else:  #there is an error but should I raise it here?
            istream.unread_token(next_kw)
    
    elif keyword == SPECULAR :
        ##syntax should be specular(pigment, float) or specular(pigment)

        #there is the possibility of specifying the threshold_angle_rad but is optional so two things can happen
        var next_kw = istream.read_token()

        if next_kw.symbol == ",":
            #there is the specification of the threshold_angle_rad
            var parsed_ang = istream.expect_number(scene)
            istream.expect_symbol(")")
            return newSpecularBrdf(pigment = parsed_pig, ta_rad = parsed_ang)
        elif next_kw.symbol == ")":
            #use default threshold_angle_rad
            return newSpecularBrdf(pigment = parsed_pig)
        else:  #there is an error but should I raise it here?
            istream.unread_token(next_kw)        
    
    else:  #there is an error but should I raise it here?
        assert false, "This line should be unreachable"  ###CONTROLLA STA COSAA

proc parse_material*(istream: var InputStream, scene: Scene) : (string, Material) =
    ##Read tokens and returns the corresponding material
    ##syntax should be material name(brdf, pigment)
    var label = istream.expect_identifier()
    istream.expect_symbol("(")
    var parsed_brdf = istream.parse_brdf(scene)
    istream.expect_symbol(",")
    var parsed_rad = istream.parse_pigment(scene)
    istream.expect_symbol(")")

    return (label, newMaterial(brdf = parsed_brdf, em_rad = parsed_rad))

proc parse_transformation*(istream: var InputStream, scene: Scene) : Transformation =
    ##Read tokens and returns the corresponding transformation
    var parsed_tr = newTransformation()

    #transformations can be multiplied many times so we have to implement a proc which can read a single transformation as well as a series of matrix
    #to do this we use the fact that our language is LL(1)
    while true :
        var keyword = istream.expect_keywords(@[IDENTITY, TRANSLATION, ROTATION_X, ROTATION_Y, ROTATION_Z, SCALING])

        if keyword == IDENTITY:
            discard
        elif keyword == TRANSLATION:
            ##syntax should be translation(vector)
            istream.expect_symbol("(")
            parsed_tr = parsed_tr * translation(istream.parse_vector(scene))
            istream.expect_symbol(")")
        elif keyword == ROTATION_X:
            ##syntax should be rotation_x(float)
            istream.expect_symbol("(")
            parsed_tr = parsed_tr * rotation_x(istream.expect_number(scene))
            istream.expect_symbol(")")
        elif keyword == ROTATION_Y:
            ##syntax should be rotation_y(float)
            istream.expect_symbol("(")
            parsed_tr = parsed_tr * rotation_y(istream.expect_number(scene))
            istream.expect_symbol(")")
        elif keyword == ROTATION_Z:
            ##syntax should be rotation_z(float)
            istream.expect_symbol("(")
            parsed_tr = parsed_tr * rotation_z(istream.expect_number(scene))
            istream.expect_symbol(")")
        elif keyword == SCALING:
            ##syntax should be scaling(x_factor, y_factor, z_factor)
            istream.expect_symbol("(")
            var x = istream.expect_number(scene)
            istream.expect_symbol(",")
            var y = istream.expect_number(scene)
            istream.expect_symbol(",")
            var z = istream.expect_number(scene)
            istream.expect_symbol(")")
            parsed_tr = parsed_tr * scaling(x, y, z)

        #check if there is another transformation or not
        var next_kw = istream.read_token()
        if not(next_kw.kind == SymbolToken) or not(next_kw.symbol == "*") :
            istream.unread_token(next_kw)
            break
    
    return parsed_tr

proc parse_sphere*(istream: var InputStream, scene: Scene) : Shape =
    ##Read tokens and returns the corresponding sphere
    ##syntax should be sphere(material, transformation*transformation*ecc)
    istream.expect_symbol("(")
    
    var mat_name = istream.expect_identifier()
    if not (scene.materials.hasKey(mat_name)) :
        raise GrammarError.newException( message = "Unknown material at (" & $istream.location.line_num & "," & $istream.location.col_num & ") of " & istream.location.file_name )

    istream.expect_symbol(",")
    var parsed_tr = istream.parse_transformation(scene)
    istream.expect_symbol(")")

    return newSphere(transform = parsed_tr, material = scene.materials[mat_name])

proc parse_plane*(istream: var InputStream, scene: Scene) : Shape =
    ##Read tokens and returns the corresponding plane
    ##syntax should be plane(material, transformation*transformation*ecc)
    istream.expect_symbol("(")
    
    var mat_name = istream.expect_identifier()
    if not (scene.materials.hasKey(mat_name)) : 
        raise GrammarError.newException( message = "Unknown material at (" & $istream.location.line_num & "," & $istream.location.col_num & ") of " & istream.location.file_name )

    istream.expect_symbol(",")
    var parsed_tr = istream.parse_transformation(scene)
    istream.expect_symbol(")")

    return newPlane(transform = parsed_tr, material = scene.materials[mat_name])

proc parse_parallelepiped*(istream: var InputStream, scene: Scene) : Shape =
    ##Read tokens and returns the corresponding parallelepiped
    ##syntax should be parallelepiped(material, transformation, point)
    istream.expect_symbol("(")
    
    var mat_name = istream.expect_identifier()
    if not (scene.materials.hasKey(mat_name)) :
        raise GrammarError.newException( message = "Unknown material at (" & $istream.location.line_num & "," & $istream.location.col_num & ") of " & istream.location.file_name )

    istream.expect_symbol(",")
    var parsed_tr = istream.parse_transformation(scene)
    istream.expect_symbol(",")
    var parsed_pmax = istream.parse_point(scene)
    istream.expect_symbol(")")

    return newParallelepiped(transform = parsed_tr, material = scene.materials[mat_name], p_max = parsed_pmax)

proc parse_union*(istream: var InputStream, scene: Scene) : Shape
proc parse_intersection*(istream: var InputStream, scene: Scene) : Shape
proc parse_difference*(istream: var InputStream, scene: Scene) : Shape 

proc parse_shape*(istream: var InputStream, scene: Scene) : Shape =
    ##Wrap sphere or plane or parallelepiped to be used in csg parsing
    var keyword = istream.expect_keywords(@[SPHERE, PLANE, PARALLELEPIPED, UNITE, INTERSECT, SUBTRACT])
    
    if keyword == SPHERE :
        return istream.parse_sphere(scene)
    elif keyword == PLANE :
        return istream.parse_plane(scene)
    elif keyword == PARALLELEPIPED :
        return istream.parse_parallelepiped(scene)
    elif keyword == UNITE :
        return istream.parse_union(scene)
    elif keyword == INTERSECT :
        return istream.parse_intersection(scene)
    elif keyword == SUBTRACT :
        return istream.parse_difference(scene)
    else:  #there is an error but should I raise it here?
        assert false, "This line should be unreachable"  ###CONTROLLA STA COSAA    

proc parse_union*(istream: var InputStream, scene: Scene) : Shape =
    ##Read tokens and returns the corresponding csg union
    ##syntax should be unite(shape, shape)
    istream.expect_symbol("(")
    var parsed_sh1 = istream.parse_shape(scene)
    istream.expect_symbol(",")
    var parsed_sh2 = istream.parse_shape(scene)
    istream.expect_symbol(")")

    return unite(parsed_sh1, parsed_sh2)

proc parse_intersection*(istream: var InputStream, scene: Scene) : Shape =
    ##Read tokens and returns the corresponding csg intersection
    ##syntax should be intersect(shape, shape)
    istream.expect_symbol("(")
    var parsed_sh1 = istream.parse_shape(scene)
    istream.expect_symbol(",")
    var parsed_sh2 = istream.parse_shape(scene)
    istream.expect_symbol(")")

    return intersect(parsed_sh1, parsed_sh2)

proc parse_difference*(istream: var InputStream, scene: Scene) : Shape =
    ##Read tokens and returns the corresponding csg difference
    ##syntax should be subtract(shape, shape)
    istream.expect_symbol("(")
    var parsed_sh1 = istream.parse_shape(scene)
    istream.expect_symbol(",")
    var parsed_sh2 = istream.parse_shape(scene)
    istream.expect_symbol(")")

    return subtract(parsed_sh1, parsed_sh2)

proc parse_camera*(istream: var InputStream, scene: Scene) : (Camera, FireRayProcs) =  #I don't know if it is right but it is the only way to define the camera type
    ##Read tokens and returns the corresponding camera
    ##syntax should be camera(type, transformation, float)
    istream.expect_symbol("(")
    var type_kw = istream.expect_keywords(@[PERSPECTIVE, ORTHOGONAL])
    istream.expect_symbol(",")
    var parsed_tr = istream.parse_transformation(scene)
    istream.expect_symbol(",")
    var axp_ratio = istream.expect_number(scene)
    istream.expect_symbol(",")
    var dist = istream.expect_number(scene)
    istream.expect_symbol(")")
    var 
        parsed_camera = newCamera(aspect_ratio = axp_ratio, transform = parsed_tr, distance = dist)
        parsed_proc : FireRayProcs

    if type_kw == PERSPECTIVE:
        parsed_proc = fire_ray_perspective
    elif type_kw == ORTHOGONAL:
        parsed_proc = fire_ray_orthogonal

    return (parsed_camera, parsed_proc)

proc parse_scene*(istream: var InputStream, variables = initTable[string, float]()) : Scene =  #initialize empty table if variables is not provided as argument
    ##Read scene description and returns the corresponding Scene object
    var 
        scene = newScene()
        vars = variables    
    scene.float_variables = vars
    for k in variables.keys:
        scene.overridden_variables.add(k)

    while true:
        var what = istream.read_token()
        if what.kind == StopToken :
            break

        if not(what.kind == KeywordToken):
            raise GrammarError.newException(message = "At location (" & $what.location.line_num & "," & $what.location.col_num & ") of " & what.location.file_name & " expected a keyword instead of " & $what)  #correct?
        if what.keyword == FLOAT :
            var 
                variable_name = istream.expect_identifier()
                variable_loc = istream.location   #for error message
            istream.expect_symbol("(")
            var variable_value = istream.expect_number(scene)
            istream.expect_symbol(")")

            if (variable_name in scene.float_variables) and not(variable_name in scene.overridden_variables):
                raise GrammarError.newException(message = "At location (" & $variable_loc.line_num & "," & $variable_loc.col_num & ") of " & variable_loc.file_name & " variable " & variable_name & " cannot be redefined.")
            if not(variable_name in scene.overridden_variables):
                #define the variable only if it was not defined outside scene file (e.g., from command line)
                scene.float_variables[variable_name] = variable_value
        
        elif (what.keyword == SPHERE) or (what.keyword == PLANE) or (what.keyword == PARALLELEPIPED) or (what.keyword == UNITE) or (what.keyword == INTERSECT) or (what.keyword == SUBTRACT) :
            istream.unread_token(what)  #parse proc will read it again and decide which specific proc to call
            scene.world.add(istream.parse_shape(scene))

        elif what.keyword == CAMERA:
            if isSome(scene.camera):
                raise GrammarError.newException(message = "At location (" & $what.location.line_num & "," & $what.location.col_num & ") of " & what.location.file_name & " you cannot define more than a camera")
            var (camera, fire_proc) = istream.parse_camera(scene)
            scene.camera = some(camera)
            scene.fire_proc = some(fire_proc)

        elif what.keyword == MATERIAL:
            var (name, material) = istream.parse_material(scene)
            scene.materials[name] = material 
        
        else:
            raise GrammarError.newException(message = "At location (" & $what.location.line_num & "," & $what.location.col_num & ") of " & what.location.file_name & " unexpected token " & $what)  #correct?

    return scene