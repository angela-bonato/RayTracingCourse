include ../src/materials
include ../src/pcg
include ../src/geometryalgebra
include std/unittest


suite "Test ONB creation":
    ## Tests on creation of orthonormal basis
    
    setup:
        var pcg = newPcg()

    test "Random test on create_onb_from_z":
        for i in 0..1000:
            var
                x = pcg.random_float()
                y = pcg.random_float()
                z = pcg.random_float()
                normal = newNormal(x,y,z).normalized()
                onb = create_onb_from_z(normal)

            assert onb.e3.x.almostEqual(normal.x)
            assert onb.e3.y.almostEqual(normal.y)
            assert onb.e3.z.almostEqual(normal.z)

            assert (1.0+onb.e1.dot(onb.e2)).almostEqual(1.0)
            assert (1.0+onb.e2.dot(onb.e3)).almostEqual(1.0)
            assert (1.0+onb.e3.dot(onb.e1)).almostEqual(1.0)

            assert onb.e1.norm().almostEqual(1.0)
            assert onb.e2.norm().almostEqual(1.0)
            assert onb.e3.norm().almostEqual(1.0)
