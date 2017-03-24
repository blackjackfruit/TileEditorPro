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
        
        // Default colors for the available colors
        let nesColors = Palette()
        nesColors.colors = [
            // Blue, Gray, and Purple
            CGColor.init(red: 0.486274509803922, green: 0.486274509803922, blue: 0.486274509803922, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.0, blue: 0.988235294117647, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.0, blue: 0.737254901960784, alpha: 1.0),
            CGColor.init(red: 0.266666666666667, green: 0.156862745098039, blue: 0.737254901960784, alpha: 1.0),
            
            CGColor.init(red: 0.737254901960784, green: 0.737254901960784, blue: 0.737254901960784, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.470588235294118, blue: 0.972549019607843, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.345098039215686, blue: 0.972549019607843, alpha: 1.0),
            CGColor.init(red: 0.407843137254902, green: 0.266666666666667, blue: 0.988235294117647, alpha: 1.0),
            
            CGColor.init(red: 0.972549019607843, green: 0.972549019607843, blue: 0.972549019607843, alpha: 1.0),
            CGColor.init(red: 0.235294117647059, green: 0.737254901960784, blue: 0.988235294117647, alpha: 1.0),
            CGColor.init(red: 0.407843137254902, green: 0.533333333333333, blue: 0.988235294117647, alpha: 1.0),
            CGColor.init(red: 0.596078431372549, green: 0.470588235294118, blue: 0.972549019607843, alpha: 1.0),
            
            CGColor.init(red: 0.988235294117647, green: 0.988235294117647, blue: 0.988235294117647, alpha: 1.0),
            CGColor.init(red: 0.643137254901961, green: 0.894117647058824, blue: 0.988235294117647, alpha: 1.0),
            CGColor.init(red: 0.72156862745098, green: 0.72156862745098, blue: 0.972549019607843, alpha: 1.0),
            CGColor.init(red: 0.847058823529412, green: 0.72156862745098, blue: 0.972549019607843, alpha: 1.0),
            
            
            // Red
            CGColor.init(red: 0.580392156862745, green: 0.0, blue: 0.517647058823529, alpha: 1.0),
            CGColor.init(red: 0.658823529411765, green: 0.0, blue: 0.125490196078431, alpha: 1.0),
            CGColor.init(red: 0.658823529411765, green: 0.0627450980392157, blue: 0.0, alpha: 1.0),
            CGColor.init(red: 0.533333333333333, green: 0.0784313725490196, blue: 0.0, alpha: 1.0),
            
            CGColor.init(red: 0.847058823529412, green: 0.0, blue: 0.8, alpha: 1.0),
            CGColor.init(red: 0.894117647058824, green: 0.0, blue: 0.345098039215686, alpha: 1.0),
            CGColor.init(red: 0.972549019607843, green: 0.219607843137255, blue: 0.0, alpha: 1.0),
            CGColor.init(red: 0.894117647058824, green: 0.36078431372549, blue: 0.0627450980392157, alpha: 1.0),
            
            CGColor.init(red: 0.972549019607843, green: 0.470588235294118, blue: 0.972549019607843, alpha: 1.0),
            CGColor.init(red: 0.972549019607843, green: 0.345098039215686, blue: 0.596078431372549, alpha: 1.0),
            CGColor.init(red: 0.972549019607843, green: 0.470588235294118, blue: 0.345098039215686, alpha: 1.0),
            CGColor.init(red: 0.988235294117647, green: 0.627450980392157, blue: 0.266666666666667, alpha: 1.0),
            
            CGColor.init(red: 0.972549019607843, green: 0.72156862745098, blue: 0.972549019607843, alpha: 1.0),
            CGColor.init(red: 0.972549019607843, green: 0.643137254901961, blue: 0.752941176470588, alpha: 1.0),
            CGColor.init(red: 0.941176470588235, green: 0.815686274509804, blue: 0.690196078431373, alpha: 1.0),
            CGColor.init(red: 0.988235294117647, green: 0.87843137254902, blue: 0.658823529411765, alpha: 1.0),
            
            
            // Greens and Browns
            CGColor.init(red: 0.313725490196078, green: 0.188235294117647, blue: 0.0, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.470588235294118, blue: 0.0, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.407843137254902, blue: 0.0, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.345098039215686, blue: 0.0, alpha: 1.0),
            
            CGColor.init(red: 0.674509803921569, green: 0.486274509803922, blue: 0.0, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.72156862745098, blue: 0.0, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.658823529411765, blue: 0.0, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.658823529411765, blue: 0.266666666666667, alpha: 1.0),
            
            CGColor.init(red: 0.972549019607843, green: 0.72156862745098, blue: 0.0, alpha: 1.0),
            CGColor.init(red: 0.72156862745098, green: 0.972549019607843, blue: 0.0941176470588235, alpha: 1.0),
            CGColor.init(red: 0.345098039215686, green: 0.847058823529412, blue: 0.329411764705882, alpha: 1.0),
            CGColor.init(red: 0.345098039215686, green: 0.972549019607843, blue: 0.596078431372549, alpha: 1.0),
            
            CGColor.init(red: 0.972549019607843, green: 0.847058823529412, blue: 0.470588235294118, alpha: 1.0),
            CGColor.init(red: 0.847058823529412, green: 0.972549019607843, blue: 0.470588235294118, alpha: 1.0),
            CGColor.init(red: 0.72156862745098, green: 0.972549019607843, blue: 0.72156862745098, alpha: 1.0),
            CGColor.init(red: 0.72156862745098, green: 0.972549019607843, blue: 0.847058823529412, alpha: 1.0),
            
            // Blacks
            CGColor.init(red: 0.0, green: 0.250980392156863, blue: 0.345098039215686, alpha: 1.0),
            CGColor.init(red: 0.470588235294118, green: 0.470588235294118, blue: 0.470588235294118, alpha: 1.0),
            CGColor.init(red: 0.972549019607843, green: 0.847058823529412, blue: 0.972549019607843, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
            
            CGColor.init(red: 0.0, green: 0.533333333333333, blue: 0.533333333333333, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
            
            
            CGColor.init(red: 0.0, green: 0.909803921568627, blue: 0.847058823529412, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
            
            CGColor.init(red: 0.0, green: 0.988235294117647, blue: 0.988235294117647, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
            CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        ]
        
        selectableColors?.palettes = [Palette()]
        selectableColors?.boxSelectorDelegate = self
        selectableColors?.redraw()
        
        selectablePalettes?.palettes = [Palette(), Palette(), Palette(), Palette(), Palette(), Palette(), Palette(), Palette()]
        selectablePalettes?.boxSelectorDelegate = self
        selectablePalettes?.redraw()
        
        generalSelectableColors?.palettes = [nesColors]
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
                let availableColors = generalSelectableColors.paletteSelected?.colors.count,
                availableColors > colorFromPalette else {
                NSLog("Failed: selectedBoxSelectablePalette")
                return
            }
            
            guard let colorFromGeneralSelected = generalSelectableColors.paletteSelected?.colors[colorFromPalette],
                let paletteForSelectablePalettes = selectablePalettes.paletteSelected,
                let paletteForColorsSelector = selectableColors.paletteSelected else {
                NSLog("Failed: selectedBoxSelectablePalette")
                return
            }
            
            paletteForSelectablePalettes.colors[selectableColors.currentBoxSelected] = colorFromGeneralSelected
            _ = selectablePalettes.update(paletteNumber: selectablePalettes.currentPaletteSelected,
                                          withPalette: paletteForSelectablePalettes)
            
            paletteForColorsSelector.colors[selectableColors.currentBoxSelected] = colorFromGeneralSelected
            _ = selectableColors.update(paletteNumber: 0,
                                        withPalette: paletteForColorsSelector)
            
            selectablePalettes.redraw()
        }
    }
}

