//
//  PaletteOptions.swift
//  TileEditor
//
//  Created by iury bessa on 11/5/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

// MARK: BoxSelector
public class BoxSelector: NSView {
    public weak var boxSelectorProtocol: BoxSelectorProtocol? = nil
    public weak var boxSelectorDelegate: BoxSelectorDelegate? = nil
    
    var palette: (number: Int, box: Int) = (0,0)
    var boxSelected: (x: Int, y: Int) = (0,0)
    public override func draw(_ dirtyRect: NSRect) {
        guard
            let boxSelectorDelegate = self.boxSelectorDelegate
        else {
            NSLog("BoxSelectorDelegate not set")
            return
        }
        guard
            let boxSelectorProtocol = self.boxSelectorProtocol
        else {
                NSLog("BoxSelectorProtocol not set")
                return
        }
        
        if let ctx = NSGraphicsContext.current()?.cgContext {
            // swap coordinate so that 0,0 is top left corner
            ctx.translateBy(x: 0, y: frame.size.height)
            ctx.scaleBy(x: 1, y: -1)
            ctx.setLineWidth(CGFloat(0.01))
            
            var numberOfTimesAcross = boxSelectorProtocol.palettesPerRow
            let numberOfPalettes = boxSelectorProtocol.palettes.count
            let numberOfBoxesPerPalette = boxSelectorProtocol.palettes.first?.size ?? 4
            let dimensionForBox = boxSelectorProtocol.boxDimension
            
            if numberOfPalettes < numberOfTimesAcross {
                numberOfTimesAcross = numberOfPalettes
            }
            
            // Every time a palette is drawn, a new starting position will be set. This starting position will also account for the case if wrapping occurs.
            var startingPosition: (CGFloat, CGFloat) = (0.0,0.0)
            // Ever time the counter reaches the numberOfPalettesHorizontally, we will move the drawing cursor down the y-axis down the height of the color box
            var numberOfPalettesHorizontallyCounter: CGFloat = 0
            var counter: Int = 0
            for palette in boxSelectorProtocol.palettes {
                startingPosition = draw(paletteProtocol: palette,
                                        ctx: ctx,
                                        dimension: boxSelectorProtocol.boxDimension,
                                        startingPosition: startingPosition)
                counter = counter + 1
                
                // We have reached the end of the line of the allowed number of palettes horizontally
                if counter == boxSelectorProtocol.palettesPerRow {
                    counter = 0
                    numberOfPalettesHorizontallyCounter = numberOfPalettesHorizontallyCounter + 1
                }
                startingPosition = (dimensionForBox.width*CGFloat(counter*numberOfBoxesPerPalette),
                                    dimensionForBox.height*numberOfPalettesHorizontallyCounter)
            }
            
            if boxSelectorProtocol.boxHighlighter {
                drawCursor(ctx: ctx, position: boxSelected, width: dimensionForBox.width, height: dimensionForBox.height)
            }
            
            
            let selectedPalette = paletteSelected(boxSelected: self.boxSelected,
                                                  palettesPerRow: boxSelectorProtocol.palettesPerRow,
                                                  minimumBoxesPerRow: boxSelectorProtocol.boxesPerRow,
                                                  paletteSize: numberOfBoxesPerPalette)
            
            if boxSelectorProtocol.paletteHighlighter {
                drawPaletteHighlighter(ctx: ctx,
                                       palette: selectedPalette.number,
                                       boxesHorizontally: boxSelectorProtocol.boxesPerRow,
                                       paletteSize: numberOfBoxesPerPalette,
                                       width: dimensionForBox.width,
                                       height: dimensionForBox.height)
            }
            
            boxSelectorDelegate.selected(boxSelector: self, palette: selectedPalette, boxSelected: boxSelected)
        }
        
    }
    override public func mouseDown(with event: NSEvent) {
        guard
            let boxSelectorDelegate = self.boxSelectorDelegate
            else {
                NSLog("BoxSelectorDelegate not set")
                return
        }
        guard
            let boxSelectorProtocol = self.boxSelectorProtocol
            else {
                NSLog("BoxSelectorProtocol not set")
                return
        }
        guard
            let paletteCurrentlySelected = boxSelectorProtocol.paletteSelected else {
            NSLog("palette selected not set for box selector protocol")
            return
        }
        let numberOfBoxesPerPalette = paletteCurrentlySelected.size
        let p = event.locationInWindow
        let rawMouseCursor = convert(p, from: nil)
        let mouseCursor = CGPoint(x: rawMouseCursor.x, y: self.frame.size.height-rawMouseCursor.y)
        
        let boxCoordinatePosition = boxPosition(cursorPosition: mouseCursor,
                                                dimension: self.frame.size,
                                                numberOfHorizontalBoxes: boxSelectorProtocol.boxesPerRow,
                                                rows: boxSelectorProtocol.numberOfRows)
        self.boxSelected = boxCoordinatePosition
        let selectedPalette = paletteSelected(boxSelected: self.boxSelected,
                                              palettesPerRow: boxSelectorProtocol.palettesPerRow,
                                              minimumBoxesPerRow: boxSelectorProtocol.boxesPerRow,
                                              paletteSize: numberOfBoxesPerPalette)
        self.palette = selectedPalette
        
        needsDisplay = true
        
    }
    private func boxPosition(cursorPosition: CGPoint, dimension: CGSize, numberOfHorizontalBoxes: Int, rows: Int) -> (Int, Int) {
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
    
    private func paletteSelected(boxSelected: (x: Int,y: Int),
                                 palettesPerRow: Int,
                                 minimumBoxesPerRow: Int,
                                 paletteSize: Int) -> (number: Int, box: Int) {
        let numberOfPalettsAcross = palettesPerRow
        
        var currentPaletteSelected = 0
        var currentBoxSelected = 0
        if palettesPerRow == 1 {
            currentBoxSelected = (boxSelected.y*minimumBoxesPerRow)+boxSelected.x
        } else {
            let numberOfPalettesBeforeRow = (boxSelected.y*numberOfPalettsAcross)
            currentPaletteSelected = (boxSelected.x/paletteSize)+numberOfPalettesBeforeRow
            
            // Get the box selected of the palette
            // This equation will get the number of palettes across and subtract from which palette that is currently selected.
            // This value is the number of palettes left of the currently selected palette.
            let palettesToTheLeftOfSelectedPalette = (currentPaletteSelected-(boxSelected.y*numberOfPalettsAcross))

            // Then subtract palettesToTheLeftOfSelectedPalette*palette size to exclude the palette boxes left of the selected palette so to subtract from the boxSelected.x which is the selected box
            currentBoxSelected = boxSelected.x - palettesToTheLeftOfSelectedPalette*paletteSize
        }
        
        return (currentPaletteSelected, currentBoxSelected)
    }
    
    private func drawCursor(ctx: CGContext, position: (x: Int, y: Int), width: CGFloat, height: CGFloat) {
        ctx.setStrokeColor(NSColor.red.cgColor)
        ctx.setLineWidth(CGFloat(2.0))
        ctx.addRect(CGRect(x: width*CGFloat(position.x),
                           y: height*CGFloat(position.y),
                           width: width,
                           height: height))
        ctx.drawPath(using: .stroke)
    }
    private func drawPaletteHighlighter(ctx: CGContext,
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
    private func draw(paletteProtocol: PaletteProtocol,
              ctx: CGContext,
              dimension: (width: CGFloat, height: CGFloat),
              startingPosition: (x: CGFloat, y: CGFloat)) -> (x: CGFloat, y: CGFloat) {
        ctx.setStrokeColor(NSColor.black.cgColor)
        ctx.setLineWidth(CGFloat(1))
        
        var startingXPosition = startingPosition.x
        var startingYPosition = startingPosition.y
        for palette in paletteProtocol.palette {
            
            if self.frame.size.width < dimension.width + startingXPosition {
                startingXPosition = 0
                startingYPosition = startingYPosition+dimension.height
            }
            
            ctx.addRect(CGRect(x: startingXPosition,
                               y: startingYPosition,
                               width: dimension.width,
                               height: dimension.height))
            ctx.setFillColor(palette.color)
            ctx.drawPath(using: .fillStroke)
            startingXPosition = startingXPosition + dimension.width
        }
        return (0,0)
    }
}

// MARK: Available Selectors
public class ColorSelector: BoxSelector, BoxSelectorProtocol {
    public var palettes: [PaletteProtocol] = []
    public var boxHighlighter: Bool = true
    public var paletteHighlighter: Bool = false
    public var palettesPerRow: Int = 1
    public var boxesPerRow = 4
    
    public var currentPaletteSelected = 0
    public var currentBoxSelected: Int = 0
    public var numberOfRows: Int = 1
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.boxSelectorProtocol = self
    }
    public func reset() {
        self.currentBoxSelected = 0
        self.currentPaletteSelected = 0
        self.boxSelected = (0,0)
    }
}

public class PaletteSelector: BoxSelector, BoxSelectorProtocol {
    public var palettes: [PaletteProtocol] = []
    public var boxHighlighter: Bool = false
    public var paletteHighlighter: Bool = true
    public var palettesPerRow: Int = 4
    public var boxesPerRow = 16
    
    public var currentPaletteSelected = 0
    public var currentBoxSelected: Int = 0
    public var numberOfRows: Int = 2
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.boxSelectorProtocol = self
    }
    
    public func reset() {
        self.currentBoxSelected = 0
        self.currentPaletteSelected = 0
        self.boxSelected = (0,0)
    }
}

public class GeneralColorSelector: BoxSelector, BoxSelectorProtocol {
    public var palettes: [PaletteProtocol] = []
    public var boxHighlighter: Bool = false
    public var paletteHighlighter: Bool = false
    public var palettesPerRow: Int = 1
    public var boxesPerRow = 4
    public var numberOfRows: Int = 16
    public var currentPaletteSelected = 0
    public var currentBoxSelected: Int = 0
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.boxSelectorProtocol = self
    }
    // There is only one palette, therefore this will set the boxSelected to the value passed to this funciton
    public func setSelectedColor(x: Int, y: Int) {
        if x > numberOfRows || y > numberOfRows || x < 0 || y < 0 {
            NSLog("Failed")
            return
        }
        self.boxSelected = (x, y)
    }
    public func randomlySelectColor() {
        let randomX = Int(arc4random_uniform(UInt32(self.boxesPerRow)))
        let randomY = Int(arc4random_uniform(UInt32(self.numberOfRows)))
        self.boxSelected = (randomX, randomY)
    }
    public func reset() {
        self.currentBoxSelected = 0
        self.currentPaletteSelected = 0
        self.boxSelected = (0,0)
    }
}
