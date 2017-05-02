# TileEditor
NES Tile Editor for editing CHR and roms on macOS.

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
* Must replace current implementation of using NSCollection with a custom collection class for improved speed.
* Need to gray out import/export of data and palettes.
* Error checking is missing for incorrect data for importing of data.
* Need to save the selected color and select it when a file is opened
* Need to write Unit Tests.
