## Implementation of the type Parameters used in the pfm2png command, to obtain the vaule of a-factor and gamma to use in the hdr -> ldr conversion

import std/strutils

# Parameters declaration

type Parameters* = object
    ## Parameters useful to convert an image from pfm to png
    input_pfm_filename* : string
    output_png_filename* : string
    a_factor* : float        # scale factor on the luminosity
    gamma* : float           # exponent for non-linear response of the schreen

# Parameters constructors

proc newParameters*() : Parameters =
    ## Empty constructor, initializethe variables to standard values
    result.input_pfm_filename = ""
    result.output_png_filename = ""
    result.a_factor = 0.2
    result.gamma = 1.0

    return result

proc newParameters*(input_pfm_filename, output_png_filename : string, a_factor, gamma : float) : Parameters =
    ## Constructor with elements, initialize the variables to given values
    result.input_pfm_filename = input_pfm_filename
    result.output_png_filename = output_png_filename
    result.a_factor = a_factor
    result.gamma = gamma

    return result

proc newParameters*(argv : seq[string]) : Parameters =   
    ## Constructor that uses command line params, parameters needed form input: <INPUT_PFM_FILE> <A_FACTOR> <GAMMA> <OUTPUT_PNG_FILE>
    if len(argv) != 4:
        raise newException(IOError,"Usage: nimble run project <INPUT_PFM_FILE> <A_FACTOR> <GAMMA> <OUTPUT_PNG_FILE>")

    result.input_pfm_filename = argv[0]

    try:
        result.a_factor = parseFloat(argv[1])
    except ValueError as e:
        raise newException(IOError, "Problem in converting A_FACTOR to float: " & e.msg) 

    try:
        result.gamma = parseFloat(argv[2])
    except ValueError as e:
        raise newException(IOError, "Problem in converting GAMMA to float: " & e.msg) 

    result.output_png_filename = argv[3]
