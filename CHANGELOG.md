# v1.0.0

- Implement a compiler to allow the user to describe the scene in a .txt file

# v0.3.0

- Add bash script to parallelize the production of animations
- Adjurned demo command
- Add antialiasing option 
- Add rendering algorithms (FlatRender and PathTracer)
- Add pcg random generator to perform ray-tracing
- Add Material classes and now each Shape has a Material member
- Add Pigment classes (UniformPigment, CheckeredPigment and ImagePigment )
- Add Brdf classes (SpecularBrdf and DiffuseBrdf)
- Fixed exception handling

# v0.2.1

- Fixed bugs in Parallelepiped class

# v0.2.0

- Add geometry classes (vectors, points, matrixes ecc) used for rendering
- Add classes to create a scene and a camera (which defines the pov of the image that will be produced)
- Add shape classes (sphere, plane, parallelepiped)
- Add CSG class to compose more complex shapes
- Produce a demo image (both in pfm and png format)
- Add multidispatch commands to run the program with two different functionalities (production of an image or only conversion form pfm to png file)
- Add types and procs to deal with BRDF

# v0.1.1

- Add missing README.md of v0.1.0

# v0.1.0

- Read PFM files
- Do tone mapping
- Do gamma correction
- Save files in PNG format
