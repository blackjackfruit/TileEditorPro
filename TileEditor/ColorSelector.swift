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
    var numberOfPalettesHorizontally: Int = 1
    
    private var currentlySelectedPalette = 0
    private var currentlySelectedTile = 0
    private var numberOfPalettes = 1
    private var numberOfColorsPerPalette: Int = 1
    
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
        
        self.numberOfPalettes = palettes.count
        widthPerTile = self.frame.size.width/CGFloat(numberOfColorsHorizontally)
        
        //TODO: Must round in case of odd number
        let numberOfPalettes = numberOfColorsHorizontally/numberOfColorsPerPalette
        if numberOfPalettes > 0 {
            numberOfPalettesHorizontally = numberOfPalettes
        } else {
            numberOfPalettesHorizontally = 1
        }
        
        let remainingColors = (self.numberOfPalettes*self.numberOfColorsPerPalette)%numberOfColorsHorizontally
        let numberOfRows = (self.numberOfPalettes*self.numberOfColorsPerPalette)/numberOfColorsHorizontally
        if remainingColors != 0 {
            self.numberOfRows = numberOfRows + 1
        } else {
            self.numberOfRows = numberOfRows
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
            
            var numberOfTimesAcross = numberOfPalettesHorizontally
            if numberOfPalettes < numberOfTimesAcross {
                numberOfTimesAcross = numberOfPalettes
            }
            
            // Every time a palette is drawn, a new starting position will be set. This starting position will also account for the case if wrapping occurs.
            var startingPosition: (CGFloat, CGFloat) = (0.0,0.0)
            // Ever time the counter reaches the numberOfPalettesHorizontally, we will move the drawing cursor down the y-axis down the height of the color box
            var numberOfPalettesHorizontallyCounter: CGFloat = 0
            var counter: Int = 0
            for palette in palettes {
                startingPosition = draw(palette: palette,
                                        ctx: ctx,
                                        dimension: (widthPerTile, heightPerTile),
                                        startingPosition: startingPosition)
                counter = counter + 1
                
                // We have reached the end of the line of the allowed number of palettes horizontally
                if counter == numberOfPalettesHorizontally {
                    counter = 0
                    numberOfPalettesHorizontallyCounter = numberOfPalettesHorizontallyCounter + 1
                }
                startingPosition = (widthPerTile*CGFloat(counter*numberOfColorsPerPalette), heightPerTile*numberOfPalettesHorizontallyCounter)
            }
        }
    }
    
    // Once drawing the color boxes reaches the end of the view, then the cursor will wrap around back to position x = 0 and move down the height of the color box
    func draw(palette: Palette,
              ctx: CGContext,
              dimension: (width: CGFloat, height: CGFloat),
              startingPosition: (x: CGFloat, y: CGFloat)) -> (x: CGFloat, y: CGFloat) {
        ctx.setLineWidth(CGFloat(1))
        var position = startingPosition
        var startingXPosition = startingPosition.x
        var startingYPosition = startingPosition.y
        for color in palette.colors {
            if self.frame.size.width < dimension.width + startingXPosition {
                startingXPosition = 0
                startingYPosition = startingYPosition+dimension.height
            }
            
            ctx.addRect(CGRect(x: startingXPosition,
                               y: startingYPosition,
                               width: dimension.width,
                               height: dimension.height))
            ctx.setFillColor(color)
            ctx.drawPath(using: .fillStroke)
            startingXPosition = startingXPosition + dimension.width
        }
        return (0,0)
    }
}
