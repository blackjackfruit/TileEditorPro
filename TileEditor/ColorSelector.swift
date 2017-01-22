//
//  PaletteOptions.swift
//  TileEditor
//
//  Created by iury bessa on 11/5/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation
import Cocoa
/**
 A palette is a group of colors available for a tile
 */
class Palette {
    public var count: Int {
        get {
            return colors.count
        }
    }
    public var colors: [CGColor]
    init() {
        colors = [NSColor.white.cgColor,
                  NSColor.lightGray.cgColor,
                  NSColor.darkGray.cgColor,
                  NSColor.black.cgColor]
    }
    func update(location: Int, color: CGColor) {
        colors[location] = color
    }
}

class ColorSelector: NSView {
    
    // This will auto-adjust the height of the individual tiles within a frame
    var useFullView = true
    // A palette consists of a number of colors. Palette of different sizes will not work
    var palettes: [Palette] = []
    // The number of palettes should be displayed horizontally. The Tile width will be adjusted accordingly
    var numberOfColorsHorizontally = 1
    
    private var currentlySelectedPalette = 0
    private var currentlySelectedTile = 0
    private var numberOfPalettes = 1
    private var numberOfColorsPerPalette: Int = 1
    private var numberOfPalettesAcross: Int = 1
    private var widthPerTile: CGFloat = 0
    private var heightPerTile: CGFloat = 0
    private var numberOfRows = 1

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setup() {
        if isPaletteSetProperly() == false{
            return
        }
        
        if let numberOfColorsInPalette = palettes.first?.count {
            numberOfColorsPerPalette = numberOfColorsInPalette
        }
        numberOfPalettes = palettes.count
        
        //TODO: Must round in case of odd number
        numberOfPalettesAcross = numberOfColorsHorizontally/numberOfColorsPerPalette
        if let x: Int = numberOfPalettes/numberOfPalettesAcross, x > 0 {
            numberOfRows = x
            widthPerTile = self.frame.size.width/CGFloat(numberOfPalettesAcross*numberOfColorsPerPalette)
        } else {
            widthPerTile = self.frame.size.width/CGFloat(numberOfColorsPerPalette)
        }
        
        if useFullView {
            heightPerTile = self.frame.size.height/CGFloat(numberOfRows)
        } else {
            heightPerTile = self.frame.size.height/CGFloat(16)
            widthPerTile = self.frame.size.width/CGFloat(8)
        }
    }
    
    func isPaletteSetProperly() -> Bool {
        guard palettes.count > 0,
            let numberOfColorsPerPalette_t = palettes.first?.count,
            numberOfColorsPerPalette_t > 0 else {
                NSLog("Palettes not configured. Cannot contine to draw ColorSelector")
                return false
        }
        return true
    }
    
    func update() {
        setup()
        self.needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if isPaletteSetProperly(), let ctx = NSGraphicsContext.current()?.cgContext {
            // swap coordinate so that 0,0 is top left corner
            ctx.translateBy(x: 0, y: frame.size.height)
            ctx.scaleBy(x: 1, y: -1)
            ctx.setLineWidth(CGFloat(0.01))
            
            var numberOfTimesAcross = numberOfPalettesAcross
            if numberOfPalettes < numberOfTimesAcross {
                numberOfTimesAcross = numberOfPalettes
            }
            
            
            
            for y in 0..<numberOfRows {
                let startingYPosition = CGFloat(y)*heightPerTile
                for x in 0..<numberOfTimesAcross {
                    // startingXPosition is the current palette number, the width per tile, and the number of colors in a palette. We do this to draw the one group of palettes at a time
                    let startingXPosition = CGFloat(x*numberOfColorsPerPalette)*widthPerTile
                    drawPalette(colors: palettes[x],
                                ctx: ctx,
                                position: (startingXPosition,startingYPosition),
                                dimension: (widthPerTile, heightPerTile))
                }
            }
        }
    }
    
    // Draw a palette horizontally, even off screen if the starting position is near the end
    func drawPalette(colors paletteColors: Palette,
                     ctx: CGContext,
                     position: (x: CGFloat, y: CGFloat),
                     dimension: (width: CGFloat, height: CGFloat)) {
        var position_t = position
        ctx.setLineWidth(CGFloat(1))
        
        for color in paletteColors.colors {
            ctx.addRect(CGRect(x: position_t.x,
                               y: position_t.y,
                               width: dimension.width,
                               height: dimension.height))
            ctx.setFillColor(color)
            ctx.drawPath(using: .fillStroke)
            position_t.x = position_t.x + dimension.width
        }
    }
}
