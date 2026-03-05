# ChimbaBenchXPL [![Github Releases](https://img.shields.io/github/downloads/Shedou/ChimbaBenchXPL/total.svg)](https://github.com/Shedou/ChimbaBenchXPL/releases)
Portable benchmark for old or weak computers (Windows XP+ | Debian 8+ | OpenGL 2.1+).

Download: [https://github.com/Shedou/ChimbaBenchXPL/releases](https://github.com/Shedou/ChimbaBenchXPL/releases)

## System requirements:
OS (32-bit): Windows XP+, Debian 8+.\
OS (64-bit): Windows 7+, Debian 8+.\
CPU: With SSE2 support and better. (tested on s754 Sempron 2800+ Palermo).\
GPU: OpenGL 2.1 support required. GeForce 6000+ and Radeon HD 2000+.

You can run it using the CPU instead of the GPU using the Mesa library (opengl32.dll).

## Development tools (All In One)
Godot Engine 2.1.5 + Custom Builds + Templates + Rcedit: https://github.com/Shedou/godot-engine-toolset-v215

## Useful materials
Primary development takes place on the [Chimbalix Linux](https://github.com/Shedou/Chimbalix) distribution. Examples may not work on other Linux distributions.
### Icons
The process of creating a proper ICO file for integration into Windows executables:
```
convert -background transparent icon.png -define icon:auto-resize=256,128,64,48,32,16 favicon.ico
```
Embedding an icon into an executable file using rcedit:
```
wine rcedit-x86.exe executable.exe --set-icon favicon.ico
```
