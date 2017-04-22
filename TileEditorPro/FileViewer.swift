//
//  FileDataViewer.swift
//  TileEditor
//
//  Created by iury bessa on 10/29/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

// Number of tiles selected. If x4 equals a 4x4 number of tiles
enum ZoomSize: UInt {
    case x1 = 1
    case x2 = 2
    case x4 = 4
    case x8 = 8
    case x16 = 16
}

protocol TileCollectionProtocol {
    func tiles(selected: [[Int]], zoomSize: ZoomSize)
}

class FileViewer: TileDrawer {
    @IBOutlet weak var viewHeight: NSLayoutConstraint?
    
    var zoomSize: ZoomSize = .x4
    var widthAndHeightPerTile: CGFloat = 60
    var delegate: TileCollectionProtocol? = nil
    var dataForViewer: NSData? = nil
    var tileData: TileData? = nil
    var colorPalette: Array<CGColor> = [NSColor.white.cgColor,
                                        NSColor.lightGray.cgColor,
                                        NSColor.gray.cgColor,
                                        NSColor.black.cgColor]
    var boxSelection: CGRect? = nil
    var selectionLocation: (x: Int, y: Int) = (x: 0, y: 0)
    var selectionLocationVisible = false
    var cursor: (x: Int, y: Int) = (x: 0, y: 0)
    
    var numberOfPixelsPerTile = 0
    var numberOfPixelsPerView = 0
    
    var numberOfSelectablePixelsVertically = 32
    var numberOfSelectableTilesVertically: Int {
        let widthPerPixel: CGFloat = frame.size.width/CGFloat(numberOfSelectablePixelsVertically)
        var numberOfPixelsPerTile = 0
        switch zoomSize {
        case .x1:
            numberOfPixelsPerTile = 8
        case .x2:
            numberOfPixelsPerTile = 16
        case .x4:
            numberOfPixelsPerTile = 32
        case .x8:
            numberOfPixelsPerTile = 64
        case .x16:
            numberOfPixelsPerTile = 128
        }
        let tselectionSize = CGFloat(numberOfPixelsPerTile)*widthPerPixel
        let numberOfTiles = frame.size.width/tselectionSize
        return Int(numberOfTiles)
    }
    var numberOfPixelsHorizontally = 64
    var numberOfTilesHorizontally: Int {
        
        if let tileData = tileData {
            let numberOfPixels = tileData.type.numberOfPixels()
            if numberOfPixels <= 0 {
                return -1
            }
            let numberOfTilesHorizontally = numberOfPixelsPerView/numberOfPixels
            return Int(numberOfTilesHorizontally)
        }
        return 0
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let wh = frame.size.width/4.0
        
        boxSelection = CGRect(x: 0,
                              y: 0,
                              width: wh,
                              height: wh)
        
    }
    
    func setup() {
        let numberOfTotalTiles = tileData?.numberOfTiles()
        if numberOfTotalTiles != nil && numberOfTotalTiles! > 0 {
            let numberOfTilesAllowedHorizontally = numberOfTilesHorizontally
            let numberOfTilesAllowedVertically = CGFloat(numberOfTotalTiles!/numberOfTilesAllowedHorizontally)
            let newHeight = numberOfTilesAllowedVertically*CGFloat(tileData!.type.numberOfPixels())*(frame.size.width/CGFloat(numberOfPixelsPerView))
            NSLog("numberOfTilesAllowedVertically: \(numberOfTilesAllowedVertically)")
            var rect = self.frame
            NSLog("Old rect for viewer: \(rect)")
            self.frame = rect
            NSLog("Old rect for viewer: \(self.frame)")
            viewHeight?.constant = newHeight
        }
    }
    
    func updateView(zoomSize: ZoomSize) {
        NSLog("Update FileViewer with zoom \(zoomSize)")
        self.zoomSize = zoomSize
        let zoomSizeFloat = CGFloat(zoomSize.rawValue)
        widthAndHeightPerTile = frame.size.width/CGFloat(numberOfPixelsPerView)
        
        selectionLocation = adjustCursor(x: selectionLocation.x,
                                      y: selectionLocation.y,
                                      sizeOfSelection: UInt(zoomSizeFloat),
                                      numberOfSelectionVertically: 32,
                                      numberOfSelectionHorizontally: 16)
        
        boxSelection = CGRect(x: CGFloat(selectionLocation.x)*widthAndHeightPerTile*8,
                              y: CGFloat(selectionLocation.y)*widthAndHeightPerTile*8,
                              width: zoomSizeFloat*widthAndHeightPerTile*CGFloat(numberOfPixelsPerTile),
                              height: zoomSizeFloat*widthAndHeightPerTile*CGFloat(numberOfPixelsPerTile))
        
        needsDisplay = true
        guard let numberOfTiles = getTileNumbersFromPosition(x: selectionLocation.x,
                                                             y: selectionLocation.y,
                                                             numberOfTilesHorizontally: 16,
                                                             dimensionOfSelection: Int(zoomSize.rawValue)) else {
                                                                NSLog("ERROR: Could not get the numbers of the tiles selected")
                                                                return
        }
        guard let tileObject = getTileData(x: selectionLocation.x,
                                           y: selectionLocation.y,
                                           numberOfTiles: Int(zoomSize.rawValue)) else {
                                            NSLog("When mouse was clicked, could not parse the data")
                                            return
        }
        if let delegate = delegate {
            NSLog("Delegate for tiles selected is not nil.. let's call it now")
//            delegate.tilesSelected(tiles: tileObject.tiles,
//                                    tileNumbers: numberOfTiles,
//                                    zoomSize: zoomSize)
//        } else {
            NSLog("Delegate for tiles selected is nil")
        }
        needsDisplay = true
    }
    
    // to update file viewer data, pass the array of pixel data and the location to where to update
    func updateFileViewerWith() -> Bool {
        needsDisplay = true
        return true
    }
    
    override func mouseDown(with event: NSEvent) {
        let p = event.locationInWindow
        let s = convert(p, from: nil)
        
        if let boxLocation = findBoxSelectionLocation(point: s,
                                                      numberOfSelectableTilesVertically: 32,
                                                      numberOfSelectableTilesHorizontally: 16) {
            let n = Int(zoomSize.rawValue)
            selectionLocation = adjustCursor(x: boxLocation.x,
                                          y: boxLocation.y,
                                          sizeOfSelection: zoomSize.rawValue,
                                          numberOfSelectionVertically: 32,
                                          numberOfSelectionHorizontally: 16)
            
            boxSelection = CGRect(x: CGFloat(selectionLocation.x)*widthAndHeightPerTile*8,
                                  y: CGFloat(selectionLocation.y)*widthAndHeightPerTile*8,
                                  width: widthAndHeightPerTile*CGFloat(n*numberOfPixelsPerTile),
                                  height: widthAndHeightPerTile*CGFloat(n*numberOfPixelsPerTile))
        
            guard let numberOfTiles = getTileNumbersFromPosition(x: selectionLocation.x,
                                                                 y: selectionLocation.y,
                                                                 numberOfTilesHorizontally: 16,
                                                                 dimensionOfSelection: Int(zoomSize.rawValue)) else {
                                                                    NSLog("ERROR: Could not get the numbers of the tiles selected")
                                                                    return
            }
            
            guard let tileObject = getTileData(x: selectionLocation.x,
                                               y: selectionLocation.y,
                                               numberOfTiles: Int(zoomSize.rawValue)) else {
                NSLog("When mouse was clicked, could not parse the data")
                return
            }
            
//            delegate?.tilesSelected(tiles: tileObject.tiles,
//                                    tileNumbers: numberOfTiles,
//                                    zoomSize: zoomSize)
        }
    }
    func getTileNumbersFromPosition(x: Int,
                                    y: Int,
                                    numberOfTilesHorizontally: Int,
                                    dimensionOfSelection: Int) -> [Int]? {
        if dimensionOfSelection < 1 || dimensionOfSelection > numberOfTilesHorizontally {
            return nil
        }
        
        var numberOfTiles: [Int] = []
        var startingIndex = x+(y*numberOfTilesHorizontally)
        
        for _ in 0..<dimensionOfSelection {
            for _ in 0..<dimensionOfSelection {
                numberOfTiles.append(startingIndex)
                startingIndex+=1
            }
            startingIndex -= dimensionOfSelection
            startingIndex += numberOfTilesHorizontally
        }
        
        return numberOfTiles
    }
    func getTileData(x: Int, y: Int, numberOfTiles: Int) -> (tiles: [Int], startingPosition: Int)? {
        
        needsDisplay = true
        
        guard let tiles = tileData?.tiles else {
            NSLog("Cannot update view because tiles is nil")
            return nil
        }
        
        var tTiles: [Int] = []
        
        var offset = x * 64 + y*16*64
        let startingPosition = offset
        let numberOfBytesPerTile = 64
        for _ in 0..<numberOfTiles {
            
            let t = tiles[0+offset..<offset+(numberOfBytesPerTile*numberOfTiles)]
            let ta = Array(t)
            tTiles += ta
            
            offset = offset+((numberOfBytesPerTile*16))
        }
        
        return (tTiles, startingPosition)
    }
    
    // Adjust the cursor in case the user tries to access an invalid area by going out of bounds based off of the selection of boxes
    // The selection parameters is the number of selectable areas from one point of the view to the other side
    private func adjustCursor(x: Int,
                              y: Int,
                              sizeOfSelection: UInt,
                              numberOfSelectionVertically: UInt,
                              numberOfSelectionHorizontally: UInt) -> (x: Int, y: Int) {
        var newCursorLocation: (x: Int, y: Int) = (x: 0, y: 0)
        
        // these temp will just make it clearer to visualize a NxN that does not start at 0
        // if the cursor is x = 3 and y = 0 on a 4x4 this is what would happen, out of bounds
        // array is from 0...3 for both x and y starting from top left
        
        // x = 2, sizeOfSelection = 4
        // The plus signs go out of bounds of the 4x4 array
        // * * + + + +
        // * * + + + +
        // * * + + + +
        // * * + + + +
        // Must become this
        // + + + +
        // + + + +
        // + + + +
        // + + + +
        
        /**
         p = x+sizeOfSelection-1
         r = p-x
         deltaX = x-r
         */
        let sizeOfSelectionPlusLocationOfX = sizeOfSelection+UInt(x)
        if sizeOfSelectionPlusLocationOfX > numberOfSelectionHorizontally {
            let tx: Int = Int(x)
            let p = Int(sizeOfSelectionPlusLocationOfX-1)
            let r = p-tx
            let deltaX = tx-r
            newCursorLocation.x = Int(deltaX)
        } else {
            newCursorLocation.x = x
        }
        let sizeOfSelectionPlusLocationOfY = sizeOfSelection+UInt(y)
        if sizeOfSelectionPlusLocationOfY > numberOfSelectionVertically {
            let ty: Int = Int(y)
            let p = Int(sizeOfSelectionPlusLocationOfY-1)
            let r = p-ty
            let deltaY = ty-r
            newCursorLocation.y = Int(deltaY)
        } else {
            newCursorLocation.y = y
        }
        
        return newCursorLocation
    }
    override func draw(_ dirtyRect: NSRect) {
        NSLog("Request to redraw TileViewer")
        if let ctx = NSGraphicsContext.current()?.cgContext {
            guard let tiles = tileData?.tiles else {
                NSLog("ERROR: tiles variable is nil")
                return
            }
            guard numberOfPixelsPerView > 0 else {
                NSLog("ERROR: Number of pixels per view is 0, cannot draw.")
                return
            }
            NSLog("Filling file viewer with PixelData")
            // swap coordinate so that 0,0 is top left corner
            ctx.translateBy(x: 0, y: viewHeight!.constant)
            ctx.scaleBy(x: 1, y: -1)
            
            ctx.setFillColor(NSColor.blue.cgColor)
            
            let widthPerPixel = frame.size.width/CGFloat(numberOfPixelsPerView)
            let heightPerPixel = frame.size.height/CGFloat(numberOfPixelsPerView)
            
            var tNumberOfPixelsPerView = 0
            var xPosition = 0
            var yPosition = 0
            let numberOfTiles = tiles.count/64
            let numberOfBytesPerTile = 64
            
            
            
            if numberOfTiles > 0 {
                var numberOfBytesPerTileCounter = 0
                for _ in 0..<numberOfTiles {
                    if tNumberOfPixelsPerView >= numberOfPixelsPerView {
                        yPosition += 1
                        tNumberOfPixelsPerView = 0
                        xPosition = 0
                    }
                    
                    drawTile(ctx: ctx,
                             tileData: tiles,
                             pixelsPerTile: 8,
                             startingPosition: numberOfBytesPerTileCounter,
                             pixelDimention: widthPerPixel,
                             x: xPosition,
                             y: yPosition)
                    tNumberOfPixelsPerView += numberOfPixelsPerTile
                    xPosition += 1
                    numberOfBytesPerTileCounter += numberOfBytesPerTile
                }
            }
            
            if boxSelection != nil && selectionLocationVisible {
                ctx.setFillColor(NSColor.clear.cgColor)
                ctx.setStrokeColor(NSColor.red.cgColor)
                ctx.stroke(boxSelection!, width: 3.0)
                ctx.drawPath(using: .fillStroke)
            }
        }
        
    }
    func drawTile(ctx: CGContext,
                  tileData: [Int],
                  pixelsPerTile: Int,
                  startingPosition: Int,
                  pixelDimention: CGFloat,
                  x: Int,
                  y: Int) {
        
        var xIndex:CGFloat = CGFloat(x)*pixelDimention*CGFloat(pixelsPerTile)
        var yIndex:CGFloat = CGFloat(y)*pixelDimention*CGFloat(pixelsPerTile)
        var indexPerPixel: Int = 0
        for _ in 0..<pixelsPerTile {
            for _ in 0..<pixelsPerTile {
                let pixel = CGRect(x: xIndex,
                                   y: yIndex,
                                   width: pixelDimention,
                                   height: pixelDimention)
                let colorAtIndex = tileData[indexPerPixel+startingPosition]
                let color = colorPalette[colorAtIndex]
                ctx.setFillColor(color)
                ctx.addRect(pixel)
                
                ctx.drawPath(using: .fill)
                xIndex += pixelDimention
                indexPerPixel += 1
            }
            xIndex = CGFloat(x)*pixelDimention*CGFloat(pixelsPerTile)
            yIndex += pixelDimention
        }
    }
}
