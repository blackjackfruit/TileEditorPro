//
//  EditorViewController-Protocols.swift
//  TileEditorPro
//
//  Created by iury on 9/19/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Cocoa
import TileEditor

//MARK: Protocols Implementations
extension EditorViewController: TileCollectionDelegate {
    func selected(tileCollection: TileCollection, tileNumbers: [[Int]]) {
        let flatArrayOfSelectedTiles = tileNumbers.flatMap { $0 }
        tileEditor?.tileIDs = flatArrayOfSelectedTiles
        do {
            try tileEditor?.update()
        } catch {
            NSLog("Could not update tile editor in TileCollectionDelegate")
        }
    }
}

extension EditorViewController: TileEditorDataSource {
    func updated(tileEditor: TileEditor, tileData: TileData, tileNumbers: [Int]) {
        guard let tileCollection = self.tileCollection else {
            log.w("WARN: No tile viewer set")
            return
        }
        
        var counter = 0
        for index in tileNumbers {
            self.editorViewControllerSettings.tileData?.matrices[index] = tileData.matrices[counter]
            counter += 1
        }
        
        tileCollection.updateModifiedTileIDs(tileNumbers: tileNumbers)
    }
}

extension EditorViewController: BoxSelectorDelegate {
    // This function will be called different times depending on which selector (selectablePalettes/generalSelectableColors) is called.
    func selected(boxSelector: BoxSelector, palette: (number: Int, box: Int), boxSelected: (x: Int, y: Int)) {
        guard
            let boxSelectorProtocol = boxSelector.boxSelectorProtocol,
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
            
            do {
                try tileEditor?.setColorFromPalette(value: palette.box)
            } catch {
                NSLog("Failed to set color palette")
            }
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
            
            do {
                try tileEditor?.update()
                selectableColorsOutlet.redraw()
            } catch {
                NSLog("could not update tileEditor")
            }
            
            
        }
        else if boxSelector == generalSelectableColorsOutlet {
            // If a different color is selected from generalSelectableColors, update the color for the selectableColors and the box selected from selectablePalettes
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
