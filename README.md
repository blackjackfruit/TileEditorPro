# TileEditorPro

[![Langues swift4](https://img.shields.io/badge/language-swift4-red.svg)](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/)
[![IDE Xcode9](https://img.shields.io/badge/IDE-Xcode9-blue.svg)](https://developer.apple.com/xcode/)
[![OS macOS](https://img.shields.io/badge/OS-macOS-brightgreen.svg)](https://www.apple.com)

NES TileEditorPro for editing CHR and roms on macOS. This project depends on the TileEditor framework which was written to isolate the application code from the data, graphics editing and viewing.

Project is written using Swift4.

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
