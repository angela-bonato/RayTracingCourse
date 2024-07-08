# Our compiler syntax

## Geometry

### vector

A vector can be expressed as `[x,y,z]` .

### point

A point can be expressed as `(x,y,z)` .

### color

A color can be expressed as `<r,g,b>` .

### transformation

Transformation can be:

- scaling &emsp;&emsp;&emsp;&ensp;&nbsp;-> scale the object along each axis 
- rotation_x &emsp;&emsp;  -> rotate the object around the x axis
- rotation_y &emsp;&emsp; -> rotate the object around the y axis
- rotation_z &emsp;&emsp; -> rotate the object around the z axis
- translation  &emsp;&emsp; -> translate the object of a certain vector
- identity  &emsp;&emsp;&emsp;&nbsp; -> leave the object unchanged

The syntax is:
      
      scaling(x,y,z)
      rotation_x(angle)
      rotation_y(angle)
      rotation_z(angle)
      translation(vector)
      identity

## pigment

Pigment can be:

- uniform &emsp;&emsp;  -> all of the object has the same color
- checkered &emsp;  -> the object has columns and rows with different colors
- image& &emsp; &emsp;   -> the object shows the image in the pfm file

which syntax is 

      uniform(color)
      checkered(color1, color2, row_num, col_num)
      image("pfm_image_filename")

## brdf

Brdf is the way the object reflect light.
Brdf can be:

- diffuse &emsp;&ensp; -> the object diffuses light
- specular &emsp;&nbsp;-> the object behaves like a mirror
- mixed &emsp;&ensp;&ensp;   -> the object both reflects and diffuses, higher the 'reflectivity' value more it reflects

which syntax is 

      diffuse(pigment)
      specular(pigment)
      mixed(pigment, reflectivity)

## material

Material syntax is:

      material material_name(
            brdf,
            pigment
      )

where the 'brdf' is how the material reflect light and 'pigment' is how it emits light.

## Shapes

### sphere

Sphere syntax is:

      sphere( material, transformation )

### plane

Plane syntax is:

      plane( material, transformation )

### parallelepiped

Parallelepiped syntax is:

      parallelepiped( material, transformation, point )

It creates a parallelepiped with vertices in 'origin' and in 'point'.

### csg

CSG (Constructive Solid Geometry ) allows you to create complicated shapes with simple operation between shapes, the implemented operations are:

- union &emsp;&emsp;&emsp;&emsp;&nbsp; -> unite shape1 and shape2
- intersection &emsp;&ensp; -> intersect shape1 and shape2
- subtraction &emsp;&ensp;&nbsp; -> subtract shape2 to shape1: shape1 - shape2

The syntax is:

      unite( shape1, shape2 )
      intersect( shape1, shape2 )
      subtract( shape1, shape2 )


## camera

Camera syntax is:

      camera( kind_of_camera, transformation, aspect_ratio, distance)

Where 'kind_of_camera' can be:
- perspective
- orthogonal

