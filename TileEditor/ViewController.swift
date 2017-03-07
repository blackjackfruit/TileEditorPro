//
//  ViewController.swift
//  TileEditor
//
//  Created by iury bessa on 10/28/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, TileEditorProtocol, TileCollectionProtocol, BoxSelectorDelegate {
    
    @IBOutlet var tileEditor: TileEditor?
    @IBOutlet weak var tileEditorSize: NSPopUpButtonCell?
    
    @IBOutlet weak var tileViewerScrollView: NSScrollView?
    @IBOutlet weak var selectableColors: BoxSelector?
    @IBOutlet weak var selectablePalettes: BoxSelector?
    @IBOutlet weak var colorSelector: BoxSelector?
    
    @IBOutlet var tileCollection: TileCollection?
    
    var zoomSize: ZoomSize = .x4
    var tileData: TileData? = nil
    var tileDataType: TileDataType? = .nes
    var pixelsPerTile = 0
    var tileNumbers: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tileViewerScrollView?.contentView.scroll(to: NSMakePoint(0,0))
        
        tileCollection?.tileCollectionDelegate = self
        
        tileEditor?.delegate = self
        tileEditor?.numberOfPixelsPerTile = 8
        tileEditor?.numberOfPixelsPerView = 8
        
        // Default colors for the available colors
        let nesColors = Palette()
        nesColors.colors = [
            CGColor.init(red: 0.486, green: 0.486, blue: 0.486, alpha: 1.0),
            CGColor.init(red: 0.000, green: 0.000, blue: 0.988, alpha: 1.0),
            CGColor.init(red: 0.000, green: 0.000, blue: 0.737, alpha: 1.0),
            CGColor.init(red: 0.266, green: 0.156, blue: 0.737, alpha: 1.0),
            CGColor.init(red: 0.580, green: 0.000, blue: 0.518, alpha: 1.0),
            CGColor.init(red: 0.659, green: 0.000, blue: 0.125, alpha: 1.0),
            CGColor.init(red: 0.659, green: 0.063, blue: 0.000, alpha: 1.0),
            CGColor.init(red: 0.533, green: 0.078, blue: 0.000, alpha: 1.0),
            CGColor.init(red: 0.737, green: 0.737, blue: 0.737, alpha: 1.0),
            CGColor.init(red: 0.000, green: 0.471, blue: 0.973, alpha: 1.0),
            CGColor.init(red: 0.000, green: 0.345, blue: 0.973, alpha: 1.0),
//            CGColor.init(red: 0.000, green: 0.0, blue: 0.0, alpha: 1.0)
        ]
        
        colorSelector?.palettes = [Palette()]
        colorSelector?.numberOfBoxesHorizontally = 4
        colorSelector?.boxHighlighter = true
        colorSelector?.useFullView = true
        colorSelector?.delegate = self
        colorSelector?.update()
        
        // Default Colors for the palettes selections
        selectablePalettes?.palettes = [Palette(), Palette(), Palette(), Palette(), Palette(), Palette(), Palette(), Palette()]
        selectablePalettes?.numberOfBoxesHorizontally = 16
        selectablePalettes?.paletteHighlighter = true
        selectablePalettes?.boxHighlighter = false
        selectablePalettes?.delegate = self
        selectablePalettes?.update()
        
        selectableColors?.palettes = [nesColors]
        selectableColors?.numberOfBoxesHorizontally = 8
        selectableColors?.useFullView = false
        selectableColors?.boxHighlighter = true
        selectableColors?.delegate = self
        selectableColors?.update()
    }
    func update() {
        NSLog("Request to update views")
        guard let tileDataType = tileDataType, let tileData = tileData, let tiles = tileData.tiles else {
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
            zoomSize = .x1
        case 1:
            zoomSize = .x2
        case 2:
            zoomSize = .x4
        default:
            zoomSize = .x8
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
    // This function will be called different times depending on which selector (selectablePalettes/selectableColors) is called.
    func selected(boxSelector: BoxSelector, palette: (number: Int, box: Int), boxSelected: (x: Int, y: Int)) {
        if boxSelector == colorSelector {
            selectablePalettes?.selectedBox = palette.box
            tileEditor?.colorFromPalette = palette.box
        }
        else if boxSelector == selectablePalettes {
            guard let newColorPalette = selectablePalettes?.palettes[palette.number] else {
                NSLog("Failed to get the newColorPalette to update colorSelector")
                return
            }
            if palette.number != previouslySetSelectablePalette {
                colorSelector?.palettes[0] = newColorPalette
                previouslySetSelectablePalette = palette.number
            }
            
            tileEditor?.colorPalette = newColorPalette
            tileEditor?.update()
            
            colorSelector?.update()
        }
        // If a different color is selected from selectableColors, update the color for the colorSelector and the box selected from selectablePalettes
        else if boxSelector == selectableColors {
            
            // calculate which color was selected based off of the boxSelected
            let colorFromPalette = (boxSelector.numberOfBoxesHorizontally*boxSelected.y)+boxSelected.x
            guard
                let availableColors = selectableColors?.palettes[0].colors.count,
                availableColors > colorFromPalette else {
                NSLog("Failed: selectedBoxSelectablePalette")
                return
            }
            
            guard let colorSelected = selectableColors?.palettes[0].colors[colorFromPalette],
                let selectedBoxColorSelector = colorSelector?.palette else {
                NSLog("Failed: selectedBoxSelectablePalette")
                return
            }
            
            let paletteForSelectablePalettes = selectablePalettes?.currentPaletteSelected
            paletteForSelectablePalettes?.colors[selectedBoxColorSelector.box] = colorSelected
            
            let paletteForColorsSelector = colorSelector?.currentPaletteSelected
            paletteForColorsSelector?.colors[selectedBoxColorSelector.box] = colorSelected
            
            selectablePalettes?.update()
        }
    }
}

