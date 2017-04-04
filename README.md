# TileEditor
NES Tile Editor for editing CHR and roms on macOS

Currently the project is limited by paint options in terms of coloring number of pixels at a time. Editing or creating files of type chr or nes roms is possible, just be forewarned that it is always a good idea have backups.

Project is written using Swift3. 

### TODO:
* Project settings
    * Allow the change of the number of tiles selectable (zooming scale 1x, 2x, 4x) at a time.
* More options for painting such as fill, square, lines, etc.
* Must replace current implementation of using NSCollection with a custom collection class for improved speed.
* Need to gray out import/export of data and palettes.
* Error checking is missing for incorrect data for importing of data.
* Need to save the selected color and select it when a file is opened 
* Need to write Unit Tests.
