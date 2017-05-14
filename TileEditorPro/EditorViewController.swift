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

class EditorViewController: NSViewController, TileEditorProtocol, TileCollectionDelegate, BoxSelectorDelegate {
    
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
    var previouslySetSelectablePalette = 0
    
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
        
        self.tileEditor?.delegate = self
        self.tileCollection?.tileCollectionDelegate = self
        self.selectableColorsOutlet?.boxSelectorDelegate = self
        self.selectablePalettesOutlet?.boxSelectorDelegate = self
        self.generalSelectableColorsOutlet?.boxSelectorDelegate = self
    }
    
    private func setupEditorViewControllerSettings() {
        self.editorViewControllerSettings.palettes = self.selectablePalettes
    }
    private func setupTileEditor() {
        self.tileEditor?.tileData = self.editorViewControllerSettings.tileData
    }
    private func setupPaletteSelectors(colorSelector: ColorSelector, paletteSelector: PaletteSelector, generalColorSelector: GeneralColorSelector) {
        let colors: PaletteProtocol
        let palettes: [PaletteProtocol]
        let generalColors: PaletteProtocol
        switch self.tileDataType {
        case .nes:
            // the value left of the question marks is the variable set externally such as when the TileEditorDocument configures EditorViewController and the right is a random color and palettes
            colors = self.selectedPalette ?? NESPalette()
            palettes = self.selectablePalettes ?? [colors, NESPalette(), NESPalette(), NESPalette(), NESPalette(), NESPalette(), NESPalette(), NESPalette()]
            generalColors = GeneralNESColorPalette()
        }
        
        colorSelector.reset()
        paletteSelector.reset()
        paletteSelector.redraw()
        
        colorSelector.palettes = [colors]
        paletteSelector.palettes = palettes
        
        if let keyColorTuple = palettes.first?.palette.first {
            let tupleKey = Int(keyColorTuple.key)
            generalColorSelector.palettes = [generalColors]
            let colorNumberPositionFromGeneralColors = GeneralNESColorPalette.colorNumber(hexValue: tupleKey)
            let y = colorNumberPositionFromGeneralColors/generalColorSelector.boxesPerRow
            let x = colorNumberPositionFromGeneralColors-(y*generalColorSelector.boxesPerRow)
            generalColorSelector.setSelectedColor(x: x, y: y)
        } else {
            generalColorSelector.palettes = [generalColors]
            generalColorSelector.randomlySelectColor()
        }
        self.selectablePalettes = palettes
        
        generalColorSelector.redraw()
    }
    
    func update() {
        log.i("Request to update views")
        guard
            let tileData = self.editorViewControllerSettings.tileData,
            let consoleType = editorViewControllerSettings.consoleType,
            let colorSelector = self.selectableColorsOutlet,
            let paletteSelector = self.selectablePalettesOutlet,
            let generalColorsSelector = self.generalSelectableColorsOutlet
        else {
            log.i("Cannot call update without specifying needed parameters")
            log.i("tileDataType and tileData are needed before updating")
            return
        }
        
        self.setupTileEditor()
        self.setupEditorViewControllerSettings()
        self.setupPaletteSelectors(colorSelector: colorSelector, paletteSelector: paletteSelector, generalColorSelector: generalColorsSelector)
        
        switch consoleType {
            case .nes:
                pixelsPerTile = 8
        }
        
        self.tileCollection?.configure(tileData: tileData)
        self.tileCollection?.update()
        self.tileViewerScrollView?.contentView.scroll(to: NSMakePoint(0,0))
    }
    
    //MARK: TileEditor Protocols
    func pixelDataChanged(tileNumbers: [Int]) {
        guard
            let tileCollection = self.tileCollection
        else {
            log.w("WARN: No tile viewer set")
            return
        }
        tileCollection.update(tileNumbers: tileNumbers)
    }
    
    @IBAction func changeZoomSize(_ sender: Any) {
        if let popUpButton = sender as? NSPopUpButton {
            var zoomSize: ZoomSize = .x4
            if popUpButton.titleOfSelectedItem == "x1" {
                zoomSize = .x1
            } else if popUpButton.titleOfSelectedItem == "x2" {
                zoomSize = .x2
            }
            self.tileEditor?.zoomSize = zoomSize
            self.tileCollection?.zoomSize = zoomSize
            self.tileCollection?.update()
        }
    }
    //MARK: FileCollection Protocols
    internal func tiles(selected: [[Int]]) {
        let flatArrayOfSelectedTiles = selected.flatMap { $0 }
        tileEditor?.visibleTiles = flatArrayOfSelectedTiles
        tileEditor?.update()
    }
}

//MARK: BoxSelectors
extension EditorViewController {
    // This function will be called different times depending on which selector (selectablePalettes/generalSelectableColors) is called.
    func selected(boxSelector: BoxSelector, palette: (number: Int, box: Int), boxSelected: (x: Int, y: Int)) {
        
        guard let boxSelectorProtocol = boxSelector.boxSelectorProtocol,
            let generalSelectableColorsOutlet = generalSelectableColorsOutlet,
            let selectableColorsOutlet = selectableColorsOutlet,
            let selectablePalettesOutlet = selectablePalettesOutlet
            else {
                log.e("Box selector delegate was not set properly")
                return
        }
        
        if boxSelector == selectableColorsOutlet {
            log.i("Updated Color Selector")
            _ = selectablePalettesOutlet.select(boxNumber: palette.box)
            _ = selectableColorsOutlet.select(boxNumber: palette.box)
            
            tileEditor?.colorFromPalette = palette.box
        }
        else if boxSelector == selectablePalettesOutlet {
            log.i("Updated Selectable Palettes Selector")
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
            log.i("Updated General Color Selector")
            
            
            // calculate which color was selected based off of the boxSelected
            let numberOfBoxesHorizontally = boxSelectorProtocol.boxesPerRow
            let colorFromPalette = (numberOfBoxesHorizontally*boxSelected.y)+boxSelected.x
            guard
                let availableColors = generalSelectableColorsOutlet.paletteSelected?.values.count,
                availableColors > colorFromPalette else {
                    log.w("Failed: selectedBoxSelectablePalette")
                    return
            }
            
            guard
                let paletteForSelectablePalettes = selectablePalettesOutlet.paletteSelected,
                let paletteForColorsSelector = selectableColorsOutlet.paletteSelected,
                let colorFromGeneralColorSelector = generalSelectableColorsOutlet.paletteSelected?.palette[colorFromPalette]
                else {
                    log.w("Failed: selectedBoxSelectablePalette")
                    return
            }
            let boxSelectedFromColorSelector = selectableColorsOutlet.currentBoxSelected
            paletteForSelectablePalettes.palette[boxSelectedFromColorSelector] = colorFromGeneralColorSelector
            _ = selectablePalettesOutlet.update(paletteNumber: selectablePalettesOutlet.currentPaletteSelected,
                                                withPalette: paletteForSelectablePalettes)
            
            paletteForColorsSelector.palette[boxSelectedFromColorSelector] = colorFromGeneralColorSelector
            _ = selectableColorsOutlet.update(paletteNumber: 0,
                                              withPalette: paletteForColorsSelector)
            
            selectablePalettesOutlet.redraw()
        }
    }
}

