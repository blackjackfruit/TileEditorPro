//
//  BoxSelectorProtocols.swift
//  TileEditor
//
//  Created by iury bessa on 3/6/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

public protocol BoxSelectorDelegate: class {
    /**
     @param boxSelector is the object from which the delegate was assigned
     @param palette number is the palette and box and is the number within the palette 
     */
    func selected(boxSelector: BoxSelector, palette: (number: Int, box: Int), boxSelected: (x: Int, y: Int))
}

public protocol BoxSelectorProtocol: class {
    var palettes: [PaletteProtocol] { get set }
    var boxHighlighter: Bool { get }
    var paletteHighlighter: Bool { get }
    var palettesPerRow: Int { get }
    var boxesPerRow: Int { get }
    var currentPaletteSelected: Int { get set }
    var currentBoxSelected: Int { get set }
    var paletteSelected: PaletteProtocol? { get }
    var numberOfRows: Int { get }
    
    var boxDimension: (width: CGFloat, height: CGFloat) { get }
    
    func redraw()
    func select(paletteNumber: Int) -> Bool
    func select(boxNumber: Int) -> Bool
    func update(paletteNumber: Int, withPalette palette: PaletteProtocol) -> Bool
    
    func reset()
}
public extension BoxSelectorProtocol where Self: NSView {
    // If the array of palettes is empty, then nil will be returned
    var paletteSelected: PaletteProtocol? {
        get {
            if self.palettes.isEmpty {
                return nil
            }
            return self.palettes[currentPaletteSelected]
        }
    }
    var boxDimension: (width: CGFloat, height: CGFloat) {
        get {
            let width: CGFloat = self.frame.size.width/CGFloat(self.boxesPerRow)
            var height: CGFloat = 0
            height = self.frame.size.height/CGFloat(self.numberOfRows)
            return (width,height)
        }
    }
    
    public func redraw() {
        self.needsDisplay = true
    }
    func select(paletteNumber: Int) -> Bool {
        guard paletteNumber < self.palettes.count else {
            NSLog("Could not select palette outside of selectable range")
            return false
        }
        self.currentPaletteSelected = paletteNumber
        return true
    }
    func select(boxNumber: Int) -> Bool {
        NSLog("BoxNumber: \(boxNumber)")
        guard let palette = self.paletteSelected, boxNumber < palette.size else {
            NSLog("Could not select box outside of selectable range")
            return false
        }
        self.currentBoxSelected = boxNumber
        return true
    }
    func update(paletteNumber: Int, withPalette palette: PaletteProtocol) -> Bool {
        guard paletteNumber < self.palettes.count else {
            NSLog("Could not select palette outside of selectable range")
            return false
        }
        self.palettes[paletteNumber] = palette
        return true
    }
}
