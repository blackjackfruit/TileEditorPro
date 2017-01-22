//
//  ViewController.swift
//  TileEditor
//
//  Created by iury bessa on 10/28/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, TileEditorProtocol, PaletteSelectorProtocol, TileCollectionProtocol {
    
    @IBOutlet var tileEditor: TileEditor?
    @IBOutlet weak var tileEditorSize: NSPopUpButtonCell?
    @IBOutlet var paletteSelector: PaletteSelector?
    @IBOutlet weak var tileViewerScrollView: NSScrollView?
    @IBOutlet weak var selectableColors: ColorSelector?
    @IBOutlet weak var selectablePalettes: ColorSelector?
    
    @IBOutlet var tileCollection: TileCollection?
    
    var zoomSize: ZoomSize = .x4
    var tileData: TileData? = nil
    var tileDataType: TileDataType? = .nes
    var pixelsPerTile = 0
    var tileNumbers: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paletteSelector?.paletteSelectinoDelegate = self
        tileViewerScrollView?.contentView.scroll(to: NSMakePoint(0,0))
        
        tileCollection?.tileCollectionDelegate = self
        
        tileEditor?.delegate = self
        tileEditor?.colorFromPalette = paletteSelector!.currentPalette
        tileEditor?.numberOfPixelsPerTile = 8
        tileEditor?.numberOfPixelsPerView = 8
        
        // Default Colors for the palettes selections
        selectablePalettes?.palettes = [Palette(), Palette(), Palette(), Palette(),
                                        Palette(), Palette(), Palette(), Palette()]
        selectablePalettes?.numberOfColorsHorizontally = 16
        selectablePalettes?.update()
        
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
            CGColor.init(red: 0.533, green: 0.078, blue: 0.000, alpha: 1.0)
        ]
        selectableColors?.palettes = [nesColors]
        selectableColors?.numberOfColorsHorizontally = 8
        selectableColors?.useFullView = false
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

//        fileViewer?.updateView(zoomSize: zoomSize)
    }
    
    //MARK: TileViewEditor Protocols
    func pixelDataChanged(tileNumbers: [Int]) {
        guard let tileCollection = tileCollection else {
            NSLog("WARN: No tile viewer set")
            return
        }
        
        tileCollection.update(tileNumbers: tileNumbers)
    }
    
    //MARK: FileViewer Protocols
    internal func tiles(selected: [[Int]], zoomSize: ZoomSize) {
        tileEditor?.tilesSelected = selected
        tileEditor?.numberOfPixelsPerView = Int(zoomSize.rawValue)*pixelsPerTile
        tileEditor?.zoomSize = zoomSize
        tileEditor?.update()
    }
    
    //MARK: PaletteSelection
    func paletteSelectionChanged(value: Int, paletteType: Int) {
        tileEditor?.colorFromPalette = value
    }
}

