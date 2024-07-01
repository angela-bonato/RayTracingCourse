
import ../src/ray
import ../src/color
import ../src/renderprocs
import ../src/pcg
import ../src/materials
import ../src/world
import ../src/geometry
import std/unittest
import std/math


suite "Test ONB creation":
    ## Tests on creation of orthonormal basis
    
    setup:
        var pcg = newPcg()

    teardown:
        echo "ONB test ended"

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
    
    echo "Random test ended"


suite "Tests on PathTracer":
    ## Tests on PathTracer
    
    setup:
        var pcg = newPcg()

    teardown:
        echo "PathTracer test ended"

    test "Fournace test":
        for i in 0..5:
            var
                scene = newWorld()
                emitted_rad = pcg.random_float()
                reflectance = pcg.random_float() * 0.9
                enclosure_mat = newMaterial( brdf = newDiffuseBRDF(pigment = newUniformPigment(reflectance * newColor(1.0, 1.0, 1.0))),
                                             em_rad = newUniformPigment(emitted_rad * newColor(1.0, 1.0, 1.0)))
                ray = newRay(origin = newPoint(), dir = newVector(1, 0, 0))
            
            scene.add(newSphere(material = enclosure_mat))

            var 
                path_col = PathTracer(scene = scene, ray = ray, pcg = pcg, n_rays = 1, max_depth = 100, lim_depth = 101)            
                expected = emitted_rad/(1.0-reflectance) 

            assert path_col.r.almostEqual(expected)
            assert path_col.g.almostEqual(expected)
            assert path_col.b.almostEqual(expected)

    echo "Fournace test ended"