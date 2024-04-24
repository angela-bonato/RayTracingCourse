
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![release](https://img.shields.io/github/v/release/angela-bonato/RayTracingCourse)
![Top Language](https://img.shields.io/github/languages/top/angela-bonato/RayTracingCourse)

## v0.1.1

This code allows you to read PFM files and to convert them to PNG files. It can also perform tone mapping and gamma correction.

## Usage

To use this program run it with: **nimble run project \<INPUT_PFM_FILE\> \<A_FACTOR\> \<GAMMA\> \<OUTPUT_PNG_FILE\>**. It will convert the **INPUT_PFM_FILE** to **OUTPUT_PNG_FILE** using the given **GAMMA** and **A_VALUE**.

Some example of the conversion of the file ***memorial.pfm*** using different value of **GAMMA** and **A_VALUE**.

<!DOCTYPE html>
<html lang="it">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
    .container {
        display: flex;
        flex-wrap: wrap;
        justify-content: center;
    }
    .image-box {
        margin: 10px;
        text-align: center;
    }
</style>
</head>
<body>

<div class="container">
    <div class="image-box">
        <img src="examples/memorial_1_0.15.png" alt="Immagine 1" width="128" height="192">
        <p>A_VALUE=0.15  GAMMA=1.0</p>
    </div>
    <div class="image-box">
        <img src="examples/memorial_1_0.25.png" alt="Immagine 2" width="128" height="192">
        <p>A_VALUE=0.25  GAMMA=1.0</p>
    </div>
    <div class="image-box">
        <img src="examples/memorial_2_0.15.png" alt="Immagine 3" width="128" height="192">
        <p>A_VALUE=0.15  GAMMA=2.0</p>
    </div>
    <div class="image-box">
        <img src="examples/memorial_2_0.25.png" alt="Immagine 3" width="128" height="192">
        <p>A_VALUE=0.25  GAMMA=2.0</p>
    </div>
</div>


</body>
</html>
