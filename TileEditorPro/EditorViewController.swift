//
//  ViewController.swift
//  TileEditor
//
//  Created by iury bessa on 10/28/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Cocoa
import TileEditor

enum EditorType {
    case NES
}

class EditorViewController: NSViewController, TileEditorProtocol, TileCollectionProtocol, BoxSelectorDelegate {
    
    // Must set this variable externally so that the tileEditor, palettes, tileCollection, etc. can be set properly
    var editorViewControllerSettings: EditorViewControllerSettings {
        get {
            guard let editorViewControllerSettings = self._editorViewControllerSettings else {
                let editorViewControllerSettings = EditorViewControllerSettings()
                self._editorViewControllerSettings = editorViewControllerSettings
                return editorViewControllerSettings
            }
            return editorViewControllerSettings
        } set {
            self._editorViewControllerSettings = newValue
        }
    }
    private var _editorViewControllerSettings: EditorViewControllerSettings? = nil
    
    @IBOutlet weak var tileEditor: TileEditor?
    @IBOutlet weak var tileEditorSize: NSPopUpButtonCell?
    
    @IBOutlet weak var tileViewerScrollView: NSScrollView?
    
    // The current set of colors selected
    @IBOutlet weak var selectableColorsOutlet: ColorSelector?
    
    // Sets of colors to choose from
    @IBOutlet weak var selectablePalettesOutlet: PaletteSelector?
    
    // All selectable colors to choose from
    @IBOutlet weak var generalSelectableColorsOutlet: GeneralColorSelector?
    
    @IBOutlet weak var tileCollection: TileCollection?
    
    var pixelsPerTile = 0
    var tileNumbers: [Int] = []
    
    // The colors currently selected from the selectable palettes
    
    // These paletteProtocols can be set externally (when opening a project) or if not a random Palettes will be created using the default TileDataType
    var selectablePalettes: [PaletteProtocol]? = nil
    var selectedPalette: PaletteProtocol? {
        get {
            return self.selectablePalettes?[self.editorViewControllerSettings.selectedPalette]
        }
    }
    
    var tileDataType: ConsoleType = .nes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = setupPaletteSelectors()
        _ = setupEditorViewControllerSettings()
        
        self.tileEditor?.delegate = self
        self.tileCollection?.tileCollectionDelegate = self
        self.selectableColorsOutlet?.boxSelectorDelegate = self
        self.selectablePalettesOutlet?.boxSelectorDelegate = self
        self.generalSelectableColorsOutlet?.boxSelectorDelegate = self
        
        _ = setupTileEditor()
    }
    
    private func setupEditorViewControllerSettings() -> Bool {
        
        self.editorViewControllerSettings.palettes = self.selectablePalettes
        
        return true
    }
    private func setupTileEditor() {
        switch self.tileDataType {
        case .nes:
            tileEditor?.numberOfPixelsPerTile = 8
            tileEditor?.numberOfPixelsPerView = 8
        }
    }
    private func setupPaletteSelectors() -> Bool {
        let colors: PaletteProtocol
        let palettes: [PaletteProtocol]
        let generalColors: PaletteProtocol
        switch self.tileDataType {
        case .nes:
            colors = self.selectedPalette ?? NESPalette()
            palettes = self.selectablePalettes ?? [colors, NESPalette(), NESPalette(), NESPalette(), NESPalette(), NESPalette(), NESPalette(), NESPalette()]
            generalColors = GeneralNESColorPalette()
        }
        
        self.selectableColorsOutlet?.palettes = [colors]
        self.selectablePalettesOutlet?.palettes = palettes
        self.generalSelectableColorsOutlet?.palettes = [generalColors]
        self.generalSelectableColorsOutlet?.boxHighlighter = false
        
        self.selectablePalettes = palettes
        
        return true
    }
    func update() {
        let tileData = self.editorViewControllerSettings.tileData
        self.tileEditor?.tileData = tileData

        NSLog("Request to update views")
        guard
            let consoleType = editorViewControllerSettings.consoleType,
            let tiles = tileData?.tiles else {
            NSLog("Cannot call update without specifying needed parameters")
            NSLog("tileDataType and tileData are needed before updating")
            return
        }
        
        _ = setupEditorViewControllerSettings()
        _ = setupPaletteSelectors()
        
        self.generalSelectableColorsOutlet?.redraw()
        
        switch consoleType {
            case .nes:
                pixelsPerTile = 8
        }
        self.editorViewControllerSettings.tileData = tileData
        
        self.tileEditor?.tileData = tileData
        self.tileEditor?.numberOfPixelsPerTile = pixelsPerTile
        self.tileEditor?.numberOfPixelsPerView = Int(ZoomSize.x4.rawValue)*pixelsPerTile

        let numberOfColumns = 16
        let numberOfRows = (tiles.count/numberOfColumns)/(pixelsPerTile*pixelsPerTile)
        
        self.tileCollection?.tileData = tileData
        self.tileCollection?.configure(numberOfTilesHorizontally: numberOfColumns,
                                  numberOfTilesVertically: numberOfRows)
        _ = self.tileCollection?.setHighlightedArea(startingIndex: IndexPath.init(item: 0, section: 0), dimension: 4)
        
        self.tileViewerScrollView?.contentView.scroll(to: NSMakePoint(0,0))
    }
    
    @IBAction func tileEditorSizeChanged(_ sender: NSPopUpButtonCell) {
        switch sender.indexOfSelectedItem {
        case 0:
            editorViewControllerSettings.zoomSize = .x1
        case 1:
            editorViewControllerSettings.zoomSize = .x2
        case 2:
            editorViewControllerSettings.zoomSize = .x4
        default:
            editorViewControllerSettings.zoomSize = .x8
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
    func selected(boxSelector: BoxSelector, palette: (number: Int, box: Int), boxSelected: (x: Int, y: Int)) {
        
        guard let boxSelectorProtocol = boxSelector.boxSelectorProtocol,
              let generalSelectableColorsOutlet = generalSelectableColorsOutlet,
              let selectableColorsOutlet = selectableColorsOutlet,
              let selectablePalettesOutlet = selectablePalettesOutlet   else {
            NSLog("Box selector delegate was not set properly")
            return
        }
        
        if boxSelector == selectableColorsOutlet {
            _ = selectablePalettesOutlet.select(boxNumber: palette.box)
            _ = selectableColorsOutlet.select(boxNumber: palette.box)
            
            tileEditor?.colorFromPalette = palette.box
        }
        else if boxSelector == selectablePalettesOutlet {
            
            let newColorPalette = selectablePalettesOutlet.palettes[palette.number]
            
            if palette.number != previouslySetSelectablePalette {
                selectableColorsOutlet.palettes[0] = newColorPalette
                previouslySetSelectablePalette = palette.number
            }
            
            _ = selectablePalettesOutlet.select(paletteNumber: palette.number)
            
            tileEditor?.colorPalette = newColorPalette
            tileEditor?.update()
            
            selectableColorsOutlet.redraw()
        }
        // If a different color is selected from generalSelectableColors, update the color for the selectableColors and the box selected from selectablePalettes
        else if boxSelector == generalSelectableColorsOutlet {
            
            // calculate which color was selected based off of the boxSelected
            let numberOfBoxesHorizontally = boxSelectorProtocol.maximumBoxesPerRow
            let colorFromPalette = (numberOfBoxesHorizontally*boxSelected.y)+boxSelected.x
            guard
                let availableColors = generalSelectableColorsOutlet.paletteSelected?.values.count,
                availableColors > colorFromPalette else {
                NSLog("Failed: selectedBoxSelectablePalette")
                return
            }
            
            guard 
                let paletteForSelectablePalettes = selectablePalettesOutlet.paletteSelected,
                let paletteForColorsSelector = selectableColorsOutlet.paletteSelected,
                let palette = generalSelectableColorsOutlet.paletteSelected?.palette[colorFromPalette]
                else {
                NSLog("Failed: selectedBoxSelectablePalette")
                return
            }
            
            paletteForSelectablePalettes.palette[selectableColorsOutlet.currentBoxSelected] = palette
            _ = selectablePalettesOutlet.update(paletteNumber: selectablePalettesOutlet.currentPaletteSelected,
                                          withPalette: paletteForSelectablePalettes)
            
            paletteForColorsSelector.palette[selectableColorsOutlet.currentBoxSelected] = palette
            _ = selectableColorsOutlet.update(paletteNumber: 0,
                                        withPalette: paletteForColorsSelector)
            
            selectablePalettesOutlet.redraw()
        }
    }
}

