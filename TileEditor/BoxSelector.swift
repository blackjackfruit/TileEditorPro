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

protocol BoxSelectorDelegate {
    func selected(boxSelector: BoxSelector, palette: (number: Int, box: Int), boxSelected: (x: Int, y: Int))
}

class BoxSelector: NSView {
    
    // This will auto-adjust the height of the individual tiles within a frame
    var useFullView = true
    // A palette consists of a number of colors. Palette of different sizes will not work
    var palettes: [Palette] = []
    // The number of palettes should be displayed horizontally. The Tile width will be adjusted accordingly
    var numberOfColorsHorizontally = 1
    var numberOfPalettesHorizontally: Int = 1
    
    var palette: (number: Int, box: Int) = (0,0)
    
    private var numberOfPalettes = 1
    private var numberOfColorsPerPalette: Int = 1
    
    private var widthPerBox: CGFloat = 0
    private var heightPerBox: CGFloat = 0
    private var numberOfRows = 1
    
    var _boxSelected: (x: Int, y: Int) = (0,0)
    var boxSelected: (x: Int, y: Int) {
        get {
            return _boxSelected
        }set {
            let selectedPalette = paletteSelected(boxSelected: newValue,
                                                  boxesHorizontally: numberOfColorsHorizontally,
                                                  paletteSize: numberOfColorsPerPalette)
            palette = selectedPalette
            _boxSelected = newValue
        }
    }
    var selectedBox: Int {
        get {
            return palette.box
        }
        set {
            palette.box = newValue
        }
    }
    
    var boxSelectionSize = 1
    
    // If highlightPalette is true, then there will be a bordered around the selectable palette
    var paletteHighlighter = false
    var boxHighlighter = false
    
    var delegate: BoxSelectorDelegate?
    
    var currentPaletteSelected: Palette {
        get {
            return palettes[palette.number]
        }
        set {
            palettes[palette.number] = newValue
        }
    }
    
    func setup() {
        if isPaletteSetProperly() == false{
            return
        }
        
        if let numberOfColorsInPalette = palettes.first?.count {
            numberOfColorsPerPalette = numberOfColorsInPalette
        }
        
        self.numberOfPalettes = palettes.count
        widthPerBox = self.frame.size.width/CGFloat(numberOfColorsHorizontally)
        
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
            heightPerBox = self.frame.size.height/CGFloat(numberOfRows)
        } else {
            //TODO: must remove hardcoded value
            self.numberOfRows = 16
            heightPerBox = self.frame.size.height/CGFloat(self.numberOfRows)
            widthPerBox = self.frame.size.width/CGFloat(8)
        }
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
                                        dimension: (widthPerBox, heightPerBox),
                                        startingPosition: startingPosition)
                counter = counter + 1
                
                // We have reached the end of the line of the allowed number of palettes horizontally
                if counter == numberOfPalettesHorizontally {
                    counter = 0
                    numberOfPalettesHorizontallyCounter = numberOfPalettesHorizontallyCounter + 1
                }
                startingPosition = (widthPerBox*CGFloat(counter*numberOfColorsPerPalette), heightPerBox*numberOfPalettesHorizontallyCounter)
            }
            
            if boxHighlighter {
                drawCursor(ctx: ctx, position: boxSelected, dimension: boxSelectionSize, width: widthPerBox, height: heightPerBox)
            }
            
            
            let selectedPalette = paletteSelected(boxSelected: boxSelected,
                                                boxesHorizontally: numberOfColorsHorizontally,
                                                paletteSize: numberOfColorsPerPalette)
            
            if paletteHighlighter {
                drawPaletteHighlighter(ctx: ctx,
                                       palette: selectedPalette.number,
                                       boxesHorizontally: numberOfColorsHorizontally,
                                       paletteSize: numberOfColorsPerPalette,
                                       width: widthPerBox,
                                       height: heightPerBox)
            }
            
            palette = selectedPalette
            
            delegate?.selected(boxSelector: self, palette: selectedPalette, boxSelected: boxSelected)
            
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        let p = event.locationInWindow
        let rawMouseCursor = convert(p, from: nil)
        let mouseCursor = CGPoint(x: rawMouseCursor.x, y: self.frame.size.height-rawMouseCursor.y)
        
        let boxCoordinatePosition = boxPosition(cursorPosition: mouseCursor,
                                                dimension: self.frame.size,
                                                numberOfHorizontalBoxes: numberOfColorsHorizontally,
                                                rows: numberOfRows)
        boxSelected = boxCoordinatePosition
        let selectedPalette = paletteSelected(boxSelected: boxSelected,
                                              boxesHorizontally: numberOfColorsHorizontally,
                                              paletteSize: numberOfColorsPerPalette)
        palette = selectedPalette
        needsDisplay = true
    }
    
    // TODO: Must modify implementation to handle odd number of palettes per row.
    // Example would be a palette size 4 and 7 == boxesHorizontally
    func drawPaletteHighlighter(ctx: CGContext,
                                palette: Int,
                                boxesHorizontally: Int,
                                paletteSize: Int,
                                width: CGFloat,
                                height: CGFloat) {
        let numberOfPalettesAcross = boxesHorizontally/paletteSize
        
        let rowPosition: CGFloat = CGFloat(palette/numberOfPalettesAcross)
        let columnPosition: CGFloat = (CGFloat(palette) - rowPosition*CGFloat(numberOfPalettesAcross))*CGFloat(paletteSize)
        let paletteWidth: CGFloat  = width*CGFloat(paletteSize)
        
        ctx.setStrokeColor(NSColor.red.cgColor)
        ctx.setLineWidth(CGFloat(2.0))
        ctx.addRect(CGRect(x: columnPosition*width,
                           y: rowPosition*height,
                           width: paletteWidth,
                           height: height))
        ctx.drawPath(using: .stroke)
    }
    
    func drawCursor(ctx: CGContext, position: (x: Int, y: Int), dimension: Int, width: CGFloat, height: CGFloat) {
        ctx.setStrokeColor(NSColor.red.cgColor)
        ctx.setLineWidth(CGFloat(2.0))
        ctx.addRect(CGRect(x: width*CGFloat(position.x),
                           y: height*CGFloat(position.y),
                           width: width,
                           height: height))
        ctx.drawPath(using: .stroke)
    }
    // Once drawing the color boxes reaches the end of the view, then the cursor will wrap around back to position x = 0 and move down the height of the color box
    func draw(palette: Palette,
              ctx: CGContext,
              dimension: (width: CGFloat, height: CGFloat),
              startingPosition: (x: CGFloat, y: CGFloat)) -> (x: CGFloat, y: CGFloat) {
        ctx.setStrokeColor(NSColor.black.cgColor)
        ctx.setLineWidth(CGFloat(1))
        
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

extension BoxSelector {
    func isPaletteSetProperly() -> Bool {
        guard palettes.count > 0,
            let numberOfColorsPerPalette_t = palettes.first?.count,
            numberOfColorsPerPalette_t > 0 else {
                NSLog("Palettes not configured. Cannot contine to draw ColorSelector")
                return false
        }
        return true
    }
    
    func boxPosition(cursorPosition: CGPoint, dimension: CGSize, numberOfHorizontalBoxes: Int, rows: Int) -> (Int, Int) {
        func positionOnALine(position: CGFloat, width: CGFloat) -> Int {
            /**
             This is a three step process
             * Step 1 - Dividing the position/width this us what were the previous section that were past.
             * Step 2 - Get the remainder of diving position/width. If it is 0, then we are on the last section selected. If we are anything other than 0, then we have started moving toward a new section.
             * Step 3 - If the first section of the line is selected, then we will have started at 1 because the remainder will have been some value. Being that computer scientists start counting from 0 we then subtract one.
             */
            let previousSections = position/width
            let remainder = position.truncatingRemainder(dividingBy:width)
            return Int( previousSections + (remainder == 0 ? 0 : 1 )) - 1
        }
        
        // TODO: must find out a mathematical formula for finding the box position within a size given the number of boxes horizontally and vertically
        let widthPerBox = dimension.width/CGFloat(numberOfHorizontalBoxes)
        let heightPerBox = dimension.height/CGFloat(rows)
        
        let horizontalCounter = positionOnALine(position: cursorPosition.x, width: widthPerBox)
        let verticalCounter = positionOnALine(position: cursorPosition.y, width: heightPerBox)
        
        return (horizontalCounter, verticalCounter)
    }
    
    // TODO: Must modify implementation to handle odd number of palettes per row. 
    // Example would be a palette size 4 and 7 == boxesHorizontally
    func paletteSelected(boxSelected: (x: Int,y: Int),
                         boxesHorizontally: Int,
                         paletteSize: Int) -> (number: Int, box: Int) {
        let numberOfPalettsAcross = boxesHorizontally/paletteSize
        // Get the palette in question
        let numberOfPalettesBeforeRow = (boxSelected.y*numberOfPalettsAcross)
        let currentPaletteSelected = (boxSelected.x/paletteSize)+numberOfPalettesBeforeRow
        
        // Get the box selected of the palette
        // This equation will get the number of palettes across and subtract from which palette that is currently selected. 
        // This value is the number of palettes left of the currently selected palette.
        let palettesToTheLeftOfSelectedPalette = (currentPaletteSelected-(boxSelected.y*numberOfPalettsAcross))
        // Then subtract palettesToTheLeftOfSelectedPalette*palette size to exclude the palette boxes left of the selected palette so to subtract from the boxSelected.x which is the selected box
        let currentBoxSelected = boxSelected.x - palettesToTheLeftOfSelectedPalette*paletteSize
        
        return (currentPaletteSelected, currentBoxSelected)
    }
    
}
