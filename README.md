# TileEditorPro

[![Langues swift3](https://img.shields.io/badge/language-swift3-red.svg)]
[![IDE Xcode8](https://img.shields.io/badge/IDE-Xcode8-blue.svg)]
[![OS macOS](https://img.shields.io/badge/OS-macOS-brightgreen.svg)]

NES TileEditorPro for editing CHR and roms on macOS. Also bundled with TileEditorPro is a framework called TileEditor which was written to isolate the application code from graphics editing and viewing. The TileEditor.framework has three apps which demonstrate the different facets of TileEditorPro.  

Project is written using Swift3.

# Setup
To get this project to compile, cocoapods will be needed.
1. To install cocoapods easily, download Homebrew. Instructions for installing Homebrew can be found at https://brew.sh
2. Run the terminal command `brew install cocoapods`
3. Navigate to the project where you downloaded TileEditorPro and issue command `pod install`

### TODO:
* Add support for other platforms (gba, snes, genesis, etc.)
* Project settings
    * Allow the change of the number of tiles selectable (zooming scale 1x, 2x, 4x) at a time.
* More options for painting such as fill, square, lines, etc.
* Need to write Unit Tests.
