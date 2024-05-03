
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![release](https://img.shields.io/github/v/release/angela-bonato/RayTracingCourse)
![Top Language](https://img.shields.io/github/languages/top/angela-bonato/RayTracingCourse)

# v0.1.1

This code allows you to read PFM files and to convert them to PNG files. It can also perform tone mapping and gamma correction.

## Installation

The code is written in Nim, it has been tested with stable and devel Nim versions from 2.0.2 on. It is supported on Ubuntu 23.04 or higher.

To use the converter, the installation of the [nim-simplepng](https://github.com/jrenner/nim-simplepng) library is required. Using the [nimble](https://github.com/nim-lang/nimble) package manager is advised.

## Usage

To use this program run it with: 

    nimble run project <INPUT_PFM_FILE> <A_FACTOR> <GAMMA> <OUTPUT_PNG_FILE>
    
It will convert the `INPUT_PFM_FILE` to `OUTPUT_PNG_FILE` using the given **GAMMA** and **A_VALUE**.

Some example of the conversion of the file `memorial.pfm` using different values of **GAMMA** and **A_VALUE**.

<!DOCTYPE html>
<html lang="it">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>

<div class="container" style="display: flex; flex-wrap: wrap; justify-content: center;">
    <div class="image-box" style="margin: 10px; text-align: center;">
        <img src="examples/memorial_1_0.15.png" alt="Immagine 1" width="154" height="231">
        <p>A_VALUE=0.15  GAMMA=1.0</p>
    </div>
    <div class="image-box" style="margin: 10px; text-align: center;">
        <img src="examples/memorial_1_0.25.png" alt="Immagine 1" width="154" height="231">
        <p>A_VALUE=0.25  GAMMA=1.0</p>
    </div>
</div>

<div class="container" style="display: flex; flex-wrap: wrap; justify-content: center;">
 <div class="image-box" style="margin: 10px; text-align: center;">
        <img src="examples/memorial_2_0.15.png" alt="Immagine 1" width="154" height="231">
        <p>A_VALUE=0.15  GAMMA=2.0</p>
    </div>
    <div class="image-box" style="margin: 10px; text-align: center;">
        <img src="examples/memorial_2_0.25.png" alt="Immagine 1" width="154" height="231">
        <p>A_VALUE=0.25  GAMMA=2.0</p>
    </div>
</div>

</body>
</html>

## License

The code is released under the GPL3 License. See the file [LICENSE.md](./LICENSE.md) for more information.
