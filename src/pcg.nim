## Random number generator, using pcg algorithm

# Pcg type declaration

type Pcg* = object
    state* : uint64
    inc* : uint64

# Pcg procs

proc random*(pcg : var Pcg) : uint32 =
    ## Generate a pseudo-random number
    
    var oldstate = pcg.state

    pcg.state = oldstate * 6364136223846793005'u64 + pcg.inc

    var 
        xorshifted = uint32(((oldstate shr 18) xor oldstate) shr 27)
        rot = int32( oldstate shr 59 )

    return uint32( (xorshifted shr rot) or (xorshifted shl ((-rot) and 31)) )

proc random_float(pcg : var Pcg) : float =
    ## Generate a pseudo random number in the interval [0,1]
    return int64(pcg.random()) / int64(0xffffffff)  #conversion to int64 because division between uint32 is not implemented, int64 is used instead of int32 to avoid change of sign

# Pcg type constructor

proc newPcg*(init_state = uint64(42), init_seq = uint64(54)) : Pcg =
    ## Pcg random number generator constructor
    ## It inizialize it
    result.state = 0
    result.inc = ( init_seq shl 1 ) or 1
    var tmp = result.random()
    result.state += init_state
    tmp = result.random()
