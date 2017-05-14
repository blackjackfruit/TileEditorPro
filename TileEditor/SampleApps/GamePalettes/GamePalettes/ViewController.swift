//
//  ViewController.swift
//  NESPalettes
//
//  Created by iury bessa on 4/12/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Cocoa
import TileEditor

class ViewController: NSViewController, BoxSelectorDelegate {
    
    @IBOutlet weak var colorSelector: ColorSelector?
    @IBOutlet weak var paletteSelector: PaletteSelector?
    @IBOutlet weak var generalSelectableColors: GeneralColorSelector?

    override func viewDidLoad() {
        super.viewDidLoad()
        let colors = NESPalette()
        self.colorSelector?.boxSelectorDelegate = self
        self.colorSelector?.palettes = [colors]
        self.colorSelector?.redraw()
        
        self.paletteSelector?.boxSelectorDelegate = self
        self.paletteSelector?.palettes = [colors, NESPalette(), NESPalette(), NESPalette(), NESPalette(), NESPalette(), NESPalette(), NESPalette()]
        self.paletteSelector?.redraw()
        
        self.generalSelectableColors?.boxHighlighter = false
        self.generalSelectableColors?.boxSelectorDelegate = self
        self.generalSelectableColors?.palettes = [GeneralNESColorPalette()]
        self.generalSelectableColors?.redraw()
    }
    
    
    var previouslySetSelectablePalette = 0
    func selected(boxSelector: BoxSelector, palette: (number: Int, box: Int), boxSelected: (x: Int, y: Int)) {
        
        guard
            let boxSelectorProtocol = boxSelector.boxSelectorProtocol,
            let colorSelector = self.colorSelector,
            let paletteSelector = self.paletteSelector,
            let generalSelectableColors = self.generalSelectableColors
            else {
                NSLog("Box selector delegate was not set properly")
                return
        }
        
        if boxSelector == colorSelector {
            _ = paletteSelector.select(boxNumber: palette.box)
            _ = colorSelector.select(boxNumber: palette.box)
        }
        else if boxSelector == paletteSelector {            
            let newColorPalette = paletteSelector.palettes[palette.number]
            
            if palette.number != previouslySetSelectablePalette {
                colorSelector.palettes[0] = newColorPalette
                previouslySetSelectablePalette = palette.number
            }
            
            _ = paletteSelector.select(paletteNumber: palette.number)
            
            colorSelector.redraw()
        }
            // If a different color is selected from generalSelectableColors, update the color for the selectableColors and the box selected from selectablePalettes
        else if boxSelector == generalSelectableColors {
            
            // calculate which color was selected based off of the boxSelected
            let numberOfBoxesHorizontally = boxSelectorProtocol.boxesPerRow
            let colorFromPalette = (numberOfBoxesHorizontally*boxSelected.y)+boxSelected.x
            guard
                let availableColors = generalSelectableColors.paletteSelected?.values.count,
                availableColors > colorFromPalette,
                let paletteForSelectablePalettes = paletteSelector.paletteSelected,
                let paletteForColorsSelector = colorSelector.paletteSelected,
                let palette = generalSelectableColors.paletteSelected?.palette[colorFromPalette]
                else {
                    NSLog("Failed: selectedBoxSelectablePalette")
                    return
            }
            
            paletteForSelectablePalettes.palette[colorSelector.currentBoxSelected] = palette
            _ = paletteSelector.update(paletteNumber: paletteSelector.currentPaletteSelected,
                                                withPalette: paletteForSelectablePalettes)
            
            paletteForColorsSelector.palette[colorSelector.currentBoxSelected] = palette
            _ = colorSelector.update(paletteNumber: 0,
                                              withPalette: paletteForColorsSelector)
            
            paletteSelector.redraw()
        }
    }

}

