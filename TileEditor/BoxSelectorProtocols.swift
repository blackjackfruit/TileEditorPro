//
//  BoxSelectorProtocols.swift
//  TileEditor
//
//  Created by iury bessa on 3/6/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

protocol BoxSelectorDelegate: class {
    func selected(boxSelector: Selector, palette: (number: Int, box: Int), boxSelected: (x: Int, y: Int))
}

protocol BoxSelectorProtocol: class {
    var palettes: [PaletteProtocol] { get set }
    var boxHighlighter: Bool { get }
    var paletteHighlighter: Bool { get }
    var palettesPerRow: Int { get }
    var maximumBoxesPerRow: Int { get }
    var currentPaletteSelected: Int { get set }
    var currentBoxSelected: Int { get set }
    var paletteSelected: PaletteProtocol? { get }
    var numberOfRows: Int { get }
    
    var boxDimension: (width: CGFloat, height: CGFloat) { get }
    
    func redraw()
    func select(paletteNumber: Int) -> Bool
    func select(boxNumber: Int) -> Bool
    func update(paletteNumber: Int, withPalette palette: PaletteProtocol) -> Bool
}
extension BoxSelectorProtocol where Self: NSView {
    // If the array of palettes is empty, then nil will be returned
    var paletteSelected: PaletteProtocol? {
        get {
            if palettes.isEmpty {
                return nil
            }
            return palettes[currentPaletteSelected]
        }
    }
    var boxDimension: (width: CGFloat, height: CGFloat) {
        get {
            let width: CGFloat = self.frame.size.width/CGFloat(maximumBoxesPerRow)
            var height: CGFloat = 0
            height = self.frame.size.height/CGFloat(numberOfRows)
            return (width,height)
        }
    }
    
    func redraw() {
        self.needsDisplay = true
    }
    func select(paletteNumber: Int) -> Bool {
        guard paletteNumber < palettes.count else {
            NSLog("Could not select palette outside of selectable range")
            return false
        }
        currentPaletteSelected = paletteNumber
        return true
    }
    func select(boxNumber: Int) -> Bool {
        guard let palette = paletteSelected, boxNumber < palette.size else {
            NSLog("Could not select box outside of selectable range")
            return false
        }
        currentBoxSelected = boxNumber
        return true
    }
    func update(paletteNumber: Int, withPalette palette: PaletteProtocol) -> Bool {
        guard paletteNumber < self.palettes.count else {
            NSLog("Could not select palette outside of selectable range")
            return false
        }
        palettes[paletteNumber] = palette
        return true
    }
}
