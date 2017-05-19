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

class EditorViewController: NSViewController {
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
    
    @IBOutlet weak var toolPencil: NSButton? = nil
    @IBOutlet weak var toolStraightLine: NSButton? = nil
    @IBOutlet weak var toolFill: NSButton? = nil
    @IBOutlet weak var toolBoxEmpty: NSButton? = nil
    
    var pixelsPerTile = 0
    var tileNumbers: [Int] = []
    var previouslySetSelectablePalette = 0
    var tileDataType: ConsoleType = .nes
    
    // These paletteProtocols can be set externally (when opening a project) or if not a random Palettes will be created using the default TileDataType
    var selectablePalettes: [PaletteProtocol]? = nil
    
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
    
    var selectedPalette: PaletteProtocol? {
        get {
            return self.selectablePalettes?[self.editorViewControllerSettings.selectedPalette]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tileEditor?.datasource = self
        self.tileCollection?.tileCollectionDelegate = self
        
        // The three box selectors for all colors, palettes, and palette
        self.selectableColorsOutlet?.boxSelectorDelegate = self
        self.selectablePalettesOutlet?.boxSelectorDelegate = self
        self.generalSelectableColorsOutlet?.boxSelectorDelegate = self
    }
    
    func setup() {
        log.i("Request to update views")
        guard
            let tileData = self.editorViewControllerSettings.tileData,
            let consoleType = self.editorViewControllerSettings.consoleType
        else {
            log.i("Cannot call update without specifying needed parameters")
            log.i("tileDataType and tileData are needed before updating")
            return
        }
        
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
        
        // Setup the IBOutlets to use the correct palettes
        _ = self.setupPaletteSelectorsForControllersOutlets(colorSelector: colors,
                                                            paletteSelector: palettes,
                                                            generalColorSelector: generalColors)
        // Setup the tile editor data
        self.setupTileEditor(colorSelector: colors)
        
        // Setup the Controller Settings
        self.setupEditorViewControllerSettings()
        
        switch consoleType {
            case .nes:
                self.pixelsPerTile = 8
        }
        
        // Configuring the TileCollection will in turn call its protocol function selected(tileNumbers:) which will then call the tile editor's update function to redraw the view
        DispatchQueue.main.async {
            self.tileCollection?.configure(using: tileData)
            // Scroll to top
//            self.tileViewerScrollView?.contentView.scroll(to: NSMakePoint(0,0))
        }
        
        
        
    }
}


// MARK: Private functions
extension EditorViewController {
    func setupEditorViewControllerSettings() {
        self.editorViewControllerSettings.palettes = self.selectablePalettes
    }
    
    func setupTileEditor(colorSelector: PaletteProtocol) {
        self.tileEditor?.tileData = self.editorViewControllerSettings.tileData
        self.tileEditor?.colorPalette = colorSelector
    }
    
    func setupPaletteSelectorsForControllersOutlets(colorSelector: PaletteProtocol,
                                                    paletteSelector: [PaletteProtocol],
                                                    generalColorSelector: PaletteProtocol) -> Bool {
        guard
            let selectableColorsOutlet = self.selectableColorsOutlet,
            let selectablePalettesOutlet = self.selectablePalettesOutlet,
            let generalSelectableColorsOutlet = self.generalSelectableColorsOutlet
        else {
            return false
        }
        
        selectableColorsOutlet.palettes = [colorSelector]
        selectablePalettesOutlet.palettes = paletteSelector
        generalSelectableColorsOutlet.palettes = [generalColorSelector]
        
        selectableColorsOutlet.resetToOriginallySelectedItem()
        selectablePalettesOutlet.resetToOriginallySelectedItem()
        generalSelectableColorsOutlet.redraw()
        
        if let keyColorTuple = paletteSelector.first?.palette.first {
            let tupleKey = Int(keyColorTuple.colorCode)
            let colorNumberPositionFromGeneralColors = GeneralNESColorPalette.colorNumber(hexValue: tupleKey)
            let y = colorNumberPositionFromGeneralColors/generalSelectableColorsOutlet.boxesPerRow
            let x = colorNumberPositionFromGeneralColors-(y*generalSelectableColorsOutlet.boxesPerRow)
            generalSelectableColorsOutlet.setSelectedColor(x: x, y: y)
        } else {
            generalSelectableColorsOutlet.randomlySelectColor()
        }
        
        self.selectablePalettes = paletteSelector
        
        generalSelectableColorsOutlet.redraw()
        
        return true
    }
}
