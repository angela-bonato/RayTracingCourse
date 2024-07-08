
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![release](https://img.shields.io/github/v/release/angela-bonato/RayTracingCourse)
![Top Language](https://img.shields.io/github/languages/top/angela-bonato/RayTracingCourse)

# v1.0.0

This program is a first look into rendering. It can produce images using different rendering algorithms, like the path tracer. Since the program output is a PNG image and a PFM file, it can also works as a PFM to PNG converter, performing tone mapping and gamma correction if necessary.

This code is written in [Nim](https://nim-lang.org/) and developed during the course "Numeric calculation for photorealistic images generation" held by professor [Maurizio Tomasi](https://github.com/ziotom78) at Unimi.

## Table of Content

- [Getting started](#getting-started)
- [Basic usage with examples](#basic-usage-with-examples)
    - [pfm2png](#pfm2png)
    - [render](#render)
- [Animation](#animation)
- [Gallery](#gallery)
- [License](#license)

## Getting started

The code has been tested with stable and devel Nim versions from 2.0.2 on, with Ubuntu 22.04.4 or higher.

To use it, the installation of [nim-simplepng](https://github.com/jrenner/nim-simplepng) and [cligen](https://github.com/c-blake/cligen) libraries is required. The installation through [nimble](https://github.com/nim-lang/nimble) package manager is advised. Therefore, you can simply run:

    nimble install <LIBRARY_NAME>

## Basic usage with examples

To use this program you have to compile it using:

    nimble build

and then run it via

    ./project <COMMAND> <ARGUMENTS>

Two commands are available: `pfm2png` and `render`. Keep reading to learn about them or run

    ./project <COMMAND> -h

for a quick guide.

### pfm2png

Use this option to convert an `INPUT_PFM_FILE` to an `OUTPUT_PNG_FILE`.
To use it run

    ./project pfm2png <INPUT_PFM_FILE> <OUTPUT_PNG_FILE>
    
To perform tone mapping and/or gamma correction during the conversion, you can specify `<GAMMA>` and/or `<A_VALUE>` using

    ./project pfm2png -a=<A_VALUE> -g=<GAMMA> <INPUT_PFM_FILE> <OUTPUT_PNG_FILE>

These are optional arguments so you can either specify them both, just one of them or none of them as in the previous case.

Here are some example of the conversion of the file `memorial.pfm` using different values of `<GAMMA>` and `<A_VALUE>`.

<p align="center">
<div style="text-align: center;">
<table style="margin: 0px auto;">
    <tr>
        <td> 
            <img src="readme_images/memorial_1_0.15.png" alt="Image 1" width="154" height="231">
            <p>A_VALUE=0.15  GAMMA=1.0</p> 
        </td>
        <td> 
            <img src="readme_images/memorial_1_0.25.png" alt="Image 2" width="154" height="231">
            <p>A_VALUE=0.25  GAMMA=1.0</p>
        </td>
    </tr>
    <tr>
        <td> 
            <img src="readme_images/memorial_2_0.15.png" alt="Image 3" width="154" height="231">
            <p>A_VALUE=0.15  GAMMA=2.0</p>
        </td>
        <td> 
            <img src="readme_images/memorial_2_0.25.png" alt="Image 4" width="154" height="231">
            <p>A_VALUE=0.25  GAMMA=2.0</p>
        </td>
    </tr>
</table>
</div>

### render

Use this option to create an image. The scene disposition has to be written in a txt file, using an easy lenguage we created and which basic syntax is explained in [this file](syntax_doc.md). 

All the txt files in `examples` are written in that lenguage, so you can use them as references.

To use this program as a ray-tracer and produce the demo image run

    ./project render examples/demo.txt

As in the previous case, it is possible to add some optional arguments to the command to adjust some aspects of the generated image. 
To learn about the optional parameters run:

    ./project render -h

Here is the default demo image produced:

<p align="center">
<img  style="center" src="readme_images/demo.png" width="320" height="240">

## Animation

With this code it is also possible to produce an animation with the camera rotates around the scene. 

To create the frames you can install *parallel* and then run

    parallel -j <NUM_CORES> ./generate_image.sh '{}' ::: $(seq 0 359) <txt_scene_description>

All the images used as frames for the animation will be saved in the `animation` directory.

If you have [ffmpeg](https://ffmpeg.org/) installed on your pc, to create the animation you just have to run

    ./generate_animation.sh

<p align="center">
<img  style="center" src="readme_images/demo.gif" width="320" height="240">

## Gallery

Some examples of what can be done with our code are shown below. All the txt scene description are in the `examples` directory.

<div style="text-align: center;">
<table style="margin: 0px auto;">
    <tr>
        <td> 
            <img src="readme_images/bowl.png" alt="Image 1" width="320" height="240">
        </td>
        <td> 
            <img src="readme_images/complete.png" alt="Image 2" width="320" height="240">
        </td>
    </tr>
    <tr>
        <td> 
            <img src="readme_images/cornellbox.png" alt="Image 2" width="320" height="240">
        </td>
        <td> 
            <img src="readme_images/spheres.png" alt="Image 3" width="320" height="240">
        </td>
    </tr>
    <tr>
        <td> 
            <img src="readme_images/table.png" alt="Image 2" width="320" height="240">
        </td>
    </tr>
</table>
</div>

## License

The code is released under the GPL3 License. See the file [LICENSE.md](./LICENSE.md) for more information.