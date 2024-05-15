import std/unittest
import ../src/pcg

suite "Test PCG":

    echo "Starting test on PCG random number generator"

    setup:
        var pcg = newPcg()
        echo "New test started"

    teardown:
        echo "Test finished"

    test "Test random number generator":

        assert pcg.state == 1753877967969059832'u64
        assert pcg.inc == 109'u64

        for expected in [2707161783'u32, 2068313097'u32,
                         3122475824'u32, 2211639955'u32,
                         3215226955'u32, 3421331566'u32]:
            assert expected == pcg.random()
