//
//  FileDataViewer.swift
//  TileEditor
//
//  Created by iury bessa on 10/29/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

enum ZoomSize: UInt {
    case x1 = 8
    case x2 = 16
    case x4 = 32
    case x8 = 64
    case x16 = 128
}

protocol FileViewerProtocol {
    func tilesSelected(tiles: [[Int]], tileNumbers: [[Int]], zoomSize: ZoomSize)
}

class FileViewer: NSView {
    var zoomSize: ZoomSize = .x4
    var widthAndHeightPerTile: CGFloat = 60
    var delegate: FileViewerProtocol? = nil
    var dataForViewer: NSData? = nil
    var tiles: [[Int]]? = nil
    var colorPalette: Array<CGColor> = [NSColor.white.cgColor,
                                        NSColor.lightGray.cgColor,
                                        NSColor.gray.cgColor,
                                        NSColor.black.cgColor]
    var boxSelection: CGRect? = nil
    var cursorLocation: (x: Int, y: Int) = (x: 0, y: 0)
    
    var numberOfPixelsPerTile = 0
    var numberOfPixelsPerView = 0
    
    var numberOfPixelsVertically = 32
    var numberOfTilesVertically: Int {
        let widthPerPixel: CGFloat = frame.size.width/CGFloat(numberOfPixelsVertically)
        let tselectionSize = CGFloat(zoomSize.rawValue)*widthPerPixel
        let numberOfTiles = frame.size.width/tselectionSize
        return Int(numberOfTiles)
    }
    var numberOfPixelsHorizontally = 64
    var numberOfTilesHorizontally: UInt {
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
    
    func startingPixelPositions(width: CGFloat,
                                height: CGFloat,
                                numberOfSquaresVertically: UInt,
                                numberOfSquaresHorizontally: UInt)
        -> (x:Array<CGFloat>,y: Array<CGFloat>)? {
        let sizePerPixelHorizontal = CGFloat(width/CGFloat(numberOfSquaresHorizontally))
        let sizePerPixelVertical = CGFloat(height/CGFloat(numberOfSquaresVertically))
        
        var x = Array<CGFloat>()
        var y = Array<CGFloat>()
        
        // since pixels are a square, this value serves for both width and height
        let sizePerPixel = sizePerPixelVertical
        
        var startLocationOfPixelForHorizontal: CGFloat = sizePerPixel
        for _ in 0..<numberOfSquaresHorizontally {
            x.append(CGFloat(startLocationOfPixelForHorizontal))
            startLocationOfPixelForHorizontal += CGFloat(sizePerPixel)
        }
        if width == height {
            // If the view is a square, then no need to calculate the vertical
            return (x: x, y: x)
        }
        var startLocationOfPixelForVertical: CGFloat = sizePerPixel
        for _ in 0..<numberOfSquaresVertically {
            y.append(CGFloat(startLocationOfPixelForVertical))
            startLocationOfPixelForVertical += CGFloat(sizePerPixel)
        }
        return (x: x, y: y)
    }
    
    func updateView(zoomSize: ZoomSize) {
        
        self.zoomSize = zoomSize
        
        var tSelectionSize = 0
        switch zoomSize {
        case .x1:
            tSelectionSize = 1
            break
        case .x2:
            tSelectionSize = 2
            break
        case .x4:
            tSelectionSize = 4
            break
        default:
            tSelectionSize = 4
        }
        
        widthAndHeightPerTile = frame.size.width/CGFloat(numberOfPixelsPerView)
        
        cursorLocation = adjustCursor(x: cursorLocation.x,
                                      y: cursorLocation.y,
                                      sizeOfSelection: UInt(tSelectionSize),
                                      numberOfSelectionVertically: 4,
                                      numberOfSelectionHorizontally: 8)
        
        boxSelection = CGRect(x: CGFloat(cursorLocation.x)*widthAndHeightPerTile,
                              y: CGFloat(cursorLocation.y)*widthAndHeightPerTile,
                              width: widthAndHeightPerTile*CGFloat(tSelectionSize*numberOfPixelsPerTile),
                              height: widthAndHeightPerTile*CGFloat(tSelectionSize*numberOfPixelsPerTile))
        
        needsDisplay = true
        
        guard let tiles = tiles else {
            NSLog("Cannot update view because tiles is nil")
            return
        }
        
        var tTiles: [[Int]] = []
        var tilesSelected: [[Int]] = []
        var indexX = 0
        var indexY = 0
        
        for _ in 0..<tSelectionSize {

            for _ in 0..<tSelectionSize {
                let index = Int(indexX+indexY)
                tTiles.append(tiles[index])
                tilesSelected.append([index])
                indexX += 1
            }
            indexX = 0
            indexY += 16
        }
        
        delegate?.tilesSelected(tiles: tTiles, tileNumbers: tilesSelected, zoomSize: zoomSize)
        needsDisplay = true
    }
    
    // to update file viewer data, pass the array of pixel data and the location to where to update
    func updateFileViewerWith(tiles: [[Int]],
                              tileNumbers: [Int]) -> Bool {
        var tilesCopy = self.tiles
       
        needsDisplay = true
        return false
    }
    
    func findBoxSelectionLocation(point: NSPoint) -> (x: Int, y: Int, width: CGFloat, height: CGFloat)? {
        guard let pixelPositions = startingPixelPositions(width: frame.size.width,
                                               height: frame.size.height,
                                               // the lowest number of boxes we can have horizontally is 4 (4 8x8 tiles)
                                               numberOfSquaresVertically: UInt(8),
                                               numberOfSquaresHorizontally: UInt(4)) else {
                                                return nil
        }
        let xPosition = CGFloat(point.x)
        let yPosition = CGFloat(frame.size.height - point.y)
        //TODO: must move away from a linear search algorithm
        var xTileNumber: Int = 0
        var yTileNumber: Int = 0
        
        for x in 0..<4 {
            if xPosition < pixelPositions.x[x] {
                break
            } else {
                xTileNumber += 1
            }
        }
        for y in 0..<8 {
            if yPosition < pixelPositions.y[y] {
                break
            } else {
                yTileNumber += 1
            }
        }
        
        return (x: xTileNumber,
                y: yTileNumber,
                width: (frame.size.width/32.0)*CGFloat(8),
                height: (frame.size.width/32.0)*CGFloat(8))
    }
    override func mouseDown(with event: NSEvent) {
        let p = event.locationInWindow
        let s = convert(p, from: nil)
        
        if let boxLocation = findBoxSelectionLocation(point: s) {
            var tSelectionSize = 0
            switch zoomSize {
            case .x1:
                tSelectionSize = 1
                break
            case .x2:
                tSelectionSize = 2
                break
            case .x4:
                tSelectionSize = 4
                break
            default:
                tSelectionSize = 4
            }
            
            cursorLocation = adjustCursor(x: boxLocation.x,
                                          y: boxLocation.y,
                                          sizeOfSelection: UInt(tSelectionSize),
                                          numberOfSelectionVertically: 4,
                                          numberOfSelectionHorizontally: 8)
            
            boxSelection = CGRect(x: CGFloat(cursorLocation.x)*widthAndHeightPerTile,
                                  y: CGFloat(cursorLocation.y)*widthAndHeightPerTile,
                                  width: widthAndHeightPerTile*CGFloat(tSelectionSize*numberOfPixelsPerTile),
                                  height: widthAndHeightPerTile*CGFloat(tSelectionSize*numberOfPixelsPerTile))
            
            needsDisplay = true
            
            guard let tiles = tiles else {
                NSLog("Cannot update view because tiles is nil")
                return
            }
            
            var tTiles: [[Int]] = []
            var tilesSelected: [[Int]] = []
            var indexX = 0
            var indexY = 0
            
            for _ in 0..<tSelectionSize {
                
                for _ in 0..<tSelectionSize {
                    let index = Int(indexX+indexY)
                    tTiles.append(tiles[index])
                    tilesSelected.append([index])
                    indexX += 1
                }
                indexX = 0
                indexY += 16
            }
            
            delegate?.tilesSelected(tiles: tTiles, tileNumbers: tilesSelected, zoomSize: zoomSize)
        }
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
        if sizeOfSelectionPlusLocationOfX > numberOfSelectionVertically {
            let tx: Int = Int(x)
            let p = Int(sizeOfSelectionPlusLocationOfX-1)
            let r = p-tx
            let deltaX = tx-r
            newCursorLocation.x = Int(deltaX)
        } else {
            newCursorLocation.x = x
        }
        let sizeOfSelectionPlusLocationOfY = sizeOfSelection+UInt(y)
        if sizeOfSelectionPlusLocationOfY > numberOfSelectionHorizontally {
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
        if let ctx = NSGraphicsContext.current()?.cgContext {
            guard let pd = tiles else {
                NSLog("ERROR: tiles variable is nil")
                return
            }
            guard numberOfPixelsPerView > 0 else {
                NSLog("ERROR: Number of pixels per view is 0, cannot draw.")
                return
            }
            NSLog("Filling file viewer with PixelData")
            // swap coordinate so that 0,0 is top left corner
            ctx.translateBy(x: 0, y: 480)
            ctx.scaleBy(x: 1, y: -1)
            
            ctx.setFillColor(NSColor.blue.cgColor)
            
            let widthPerPixel = frame.size.width/CGFloat(numberOfPixelsPerView)
            let heightPerPixel = frame.size.height/CGFloat(numberOfPixelsPerView)
            
            var tNumberOfPixelsPerView = 0
            var xPosition = 0
            var yPosition = 0
            let numberOfTiles = pd.count
            if numberOfTiles > 0 {
                for t in 0..<numberOfTiles {
                    if tNumberOfPixelsPerView >= numberOfPixelsPerView {
                        yPosition += 1
                        tNumberOfPixelsPerView = 0
                        xPosition = 0
                    }
                    drawTile(ctx: ctx,
                             tileData: pd[t],
                             pixelsPerTile: 8,
                             pixelDimention: widthPerPixel,
                             x: xPosition, y: yPosition)
                    tNumberOfPixelsPerView += numberOfPixelsPerTile
                    xPosition += 1
                }
            }
            
            if boxSelection != nil {
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
                  pixelDimention: CGFloat,
                  x: Int, y: Int) {
        
        if tileData.count == 0 {
            NSLog("ERROR: Tile data empty")
            return
        }
        
        
        var xIndex:CGFloat = CGFloat(x)*pixelDimention*CGFloat(pixelsPerTile)
        var yIndex:CGFloat = CGFloat(y)*pixelDimention*CGFloat(pixelsPerTile)
        var indexPerPixel: Int = 0
        for _ in 0..<pixelsPerTile {
            for _ in 0..<pixelsPerTile {
                let pixel = CGRect(x: xIndex,
                                   y: yIndex,
                                   width: pixelDimention,
                                   height: pixelDimention)
                let colorAtIndex = tileData[indexPerPixel]
                let color = colorPalette[colorAtIndex]
                ctx.setFillColor(color)
                ctx.addRect(pixel)
                ctx.setLineWidth(CGFloat(0.01))
                ctx.drawPath(using: .fillStroke)
                xIndex += pixelDimention
                indexPerPixel += 1
            }
            xIndex = CGFloat(x)*pixelDimention*CGFloat(pixelsPerTile)
            yIndex += pixelDimention
        }
    }
}
