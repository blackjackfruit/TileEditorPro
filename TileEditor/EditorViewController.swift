//
//  ViewController.swift
//  TileEditor
//
//  Created by iury bessa on 10/28/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Cocoa

class EditorViewController: NSViewController, TileEditorProtocol, TileCollectionProtocol, BoxSelectorDelegate {
    
    @IBOutlet var tileEditor: TileEditor?
    @IBOutlet weak var tileEditorSize: NSPopUpButtonCell?
    
    @IBOutlet weak var tileViewerScrollView: NSScrollView?
    
    // All selectable colors to choose from
    @IBOutlet weak var generalSelectableColors: GeneralColorSelector?
    
    // Sets of colors to choose from
    @IBOutlet weak var selectablePalettes: PaletteSelector?
    
    // The current set of colors selected
    @IBOutlet weak var selectableColors: ColorSelector?
    
    @IBOutlet var tileCollection: TileCollection?
    
    var editorViewControllerSettings: EditorViewControllerSettings? = nil
    var pixelsPerTile = 0
    var tileNumbers: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sampleData = Data(count: 8192)
        let tileData = TileData(data: sampleData, type: .none)
        self.editorViewControllerSettings = EditorViewControllerSettings()
        self.editorViewControllerSettings?.tileData = tileData
        self.editorViewControllerSettings?.tileDataType = .nes
        
        tileViewerScrollView?.contentView.scroll(to: NSMakePoint(0,0))
        
        tileCollection?.tileCollectionDelegate = self
        
        tileEditor?.delegate = self
        tileEditor?.numberOfPixelsPerTile = 8
        tileEditor?.numberOfPixelsPerView = 8

        // TODO: Must figure out why it is necessary to create a NESPalette object and then pass it to both selectableColors and selectablePalettes. Not doing this will result in two different palettes and selectableColors not matching the selectablePalettes
        let nesPalette = NESPalette()
        selectableColors?.palettes = [nesPalette]
        selectableColors?.boxSelectorDelegate = self
        
        selectablePalettes?.palettes = [nesPalette, NESPalette(), NESPalette(), NESPalette(), NESPalette(), NESPalette(), NESPalette(), NESPalette()]
        selectablePalettes?.boxSelectorDelegate = self
        
        let generalColors = NESPalette()
        generalColors.palette = NESColors
        generalSelectableColors?.palettes = [generalColors]
        generalSelectableColors?.boxSelectorDelegate = self
        generalSelectableColors?.redraw()
        
        self.update()
    }
    func update() {
        NSLog("Request to update views")
        guard let editorViewControllerSettings = editorViewControllerSettings,
            let tileDataType = editorViewControllerSettings.tileDataType,
            let tileData = editorViewControllerSettings.tileData,
            let tiles = editorViewControllerSettings.tileData?.tiles else {
            NSLog("Cannot call update without specifying needed parameters")
            NSLog("tileDataType and tileData are needed before updating")
            return
        }
        
        switch tileDataType {
            case TileDataType.nes:
                pixelsPerTile = 8
            case .none:
                pixelsPerTile = 8
        case .unknown:
            NSLog("View controller did not set tile data type, thus we cannot draw anything")
            return
        }
        
        tileEditor?.tileData = tileData
        tileEditor?.numberOfPixelsPerTile = pixelsPerTile
        tileEditor?.numberOfPixelsPerView = Int(ZoomSize.x4.rawValue)*pixelsPerTile

        let numberOfColumns = 16
        let numberOfRows = (tiles.count/numberOfColumns)/(pixelsPerTile*pixelsPerTile)
        
        tileCollection?.tileData = tileData
        tileCollection?.configure(numberOfTilesHorizontally: numberOfColumns,
                                  numberOfTilesVertically: numberOfRows)
        _ = tileCollection?.setHighlightedArea(startingIndex: IndexPath.init(item: 0, section: 0), dimension: 4)
    }
    
    @IBAction func tileEditorSizeChanged(_ sender: NSPopUpButtonCell) {
        switch sender.indexOfSelectedItem {
        case 0:
            editorViewControllerSettings?.zoomSize = .x1
        case 1:
            editorViewControllerSettings?.zoomSize = .x2
        case 2:
            editorViewControllerSettings?.zoomSize = .x4
        default:
            editorViewControllerSettings?.zoomSize = .x8
        }
    }
    
    //MARK: TileEditor Protocols
    func pixelDataChanged(tileNumbers: [Int]) {
        guard let tileCollection = tileCollection else {
            NSLog("WARN: No tile viewer set")
            return
        }
        
        tileCollection.update(tileNumbers: tileNumbers)
    }
    
    //MARK: FileCollection Protocols
    internal func tiles(selected: [[Int]], zoomSize: ZoomSize) {
        tileEditor?.tilesSelected = selected
        tileEditor?.numberOfPixelsPerView = Int(zoomSize.rawValue)*pixelsPerTile
        tileEditor?.zoomSize = zoomSize
        tileEditor?.update()
    }
    
    //MARK: BoxSelector
    var previouslySetSelectablePalette = 0
    // This function will be called different times depending on which selector (selectablePalettes/generalSelectableColors) is called.
    func selected(boxSelector: Selector, palette: (number: Int, box: Int), boxSelected: (x: Int, y: Int)) {
        
        guard let boxSelectorProtocol = boxSelector.boxSelectorProtocol,
              let generalSelectableColors = generalSelectableColors,
              var selectableColors = selectableColors,
              var selectablePalettes = selectablePalettes else {
            NSLog("Box selector delegate was not set properly")
            return
        }
        
        if boxSelector == selectableColors {
            _ = selectablePalettes.select(boxNumber: palette.box)
            _ = selectableColors.select(boxNumber: palette.box)
            
            tileEditor?.colorFromPalette = palette.box
        }
        else if boxSelector == selectablePalettes {
            let newColorPalette = selectablePalettes.palettes[palette.number]
            
            if palette.number != previouslySetSelectablePalette {
                selectableColors.palettes[0] = newColorPalette
                previouslySetSelectablePalette = palette.number
            }
            
            _ = selectablePalettes.select(paletteNumber: palette.number)
            
            tileEditor?.colorPalette = newColorPalette
            tileEditor?.update()
            
            selectableColors.redraw()
        }
        // If a different color is selected from generalSelectableColors, update the color for the selectableColors and the box selected from selectablePalettes
        else if boxSelector == generalSelectableColors {
            
            // calculate which color was selected based off of the boxSelected
            let numberOfBoxesHorizontally = boxSelectorProtocol.maximumBoxesPerRow
            let colorFromPalette = (numberOfBoxesHorizontally*boxSelected.y)+boxSelected.x
            guard
                let availableColors = generalSelectableColors.paletteSelected?.values.count,
                availableColors > colorFromPalette else {
                NSLog("Failed: selectedBoxSelectablePalette")
                return
            }
            
            guard 
                let paletteForSelectablePalettes = selectablePalettes.paletteSelected,
                let paletteForColorsSelector = selectableColors.paletteSelected,
                let palette = generalSelectableColors.paletteSelected?.palette[colorFromPalette]
                else {
                NSLog("Failed: selectedBoxSelectablePalette")
                return
            }
            
            paletteForSelectablePalettes.palette[selectableColors.currentBoxSelected] = palette
            _ = selectablePalettes.update(paletteNumber: selectablePalettes.currentPaletteSelected,
                                          withPalette: paletteForSelectablePalettes)
            
            paletteForColorsSelector.palette[selectableColors.currentBoxSelected] = palette
            _ = selectableColors.update(paletteNumber: 0,
                                        withPalette: paletteForColorsSelector)
            
            selectablePalettes.redraw()
        }
    }
}

