//
//  TileView.swift
//  TileEditor
//
//  Created by iury bessa on 10/28/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation
import QuartzCore
import Cocoa

protocol TileEditorProtocol {
    func pixelDataChanged(pixelData: [Int:Int])
}

struct TileViewerMapper {
    let x: UInt
    let y: UInt
    let width: UInt
    let height: UInt
}

class TileEditor: TileDrawer {
    var delegate: TileEditorProtocol? = nil
    var colorPalette: Array<CGColor> = [NSColor.white.cgColor,
                                   NSColor.lightGray.cgColor,
                                   NSColor.gray.cgColor,
                                   NSColor.black.cgColor]
    var zoomSize: ZoomSize = .x4
    var colorFromPalette: Int = 3
    var cursorLocation: (x: Int, y: Int) = (x: 0, y: 0)
    var startingPosition = 0
    // Should be an 8x8, 16x16, 32x32, etc. data set
    var tiles: [Int]? = nil
    
    var tilesToDraw: [Int] = []
    var numberOfPixelsPerTile: Int = 0
    // These are the number of pixels to display from left to right and top to down
    var numberOfPixelsPerView: Int = 0
    
    // Since the TileViewEditor is a square, we don't need to do anything different for computing x/y starting positions
    var startingPositions: Array<CGFloat> {
        var ret = Array<CGFloat>()
        let widthPerPixel = CGFloat(frame.width/CGFloat(zoomSize.rawValue))*8
        var startLocationOfPixel: CGFloat = widthPerPixel
        for _ in 0..<zoomSize.rawValue {
            ret.append(CGFloat(startLocationOfPixel))
            startLocationOfPixel += CGFloat(widthPerPixel)
        }
        return ret
    }
    
    override func mouseDown(with event: NSEvent) {
        guard tiles != nil else {
            NSLog("Tiles is nil")
            return
        }
        let p = event.locationInWindow
        let s = convert(p, from: nil)
        if let tileLocation = findBoxSelectionLocation(point: s,
                                                       numberOfTilesVertically: Int(zoomSize.rawValue),
                                                       numberOfTilesHorizontally: Int(zoomSize.rawValue)) {
            let widthAndHeightPerPixel = frame.size.width/CGFloat(8*zoomSize.rawValue)
            let positionInTileSelected = positionInTile(point: s,
                                                        tileStartingPositionX: tileLocation.x*60,
                                                        tileStartingPositionY: tileLocation.y*60,
                                                        tileSize: 8,
                                                        pixelSize: widthAndHeightPerPixel)
            
            let firstPixelInTile = (tileLocation.x*64)+(tileLocation.y*64*Int(zoomSize.rawValue))
            let pixelLocationInTile = positionInTileSelected.x+(positionInTileSelected.y*8)
            let pixelLocationInData = firstPixelInTile+pixelLocationInTile
            self.tilesToDraw[pixelLocationInData] = colorFromPalette
            
            let cursorOffset = (cursorLocation.x*64)+(cursorLocation.y*16*64)
            let tileOffset = (tileLocation.x*64)+(tileLocation.y*16*64)
            let pixelOffset = (positionInTileSelected.x)+(positionInTileSelected.y*8)
            
            let location = cursorOffset + tileOffset + pixelOffset
            self.tiles![location] = colorFromPalette
            delegate?.pixelDataChanged(pixelData: [location:colorFromPalette])
            needsDisplay = true
        }
    }
    
    func positionInTile(point: NSPoint,
                        tileStartingPositionX: Int,
                        tileStartingPositionY: Int,
                        tileSize: Int,
                        pixelSize: CGFloat) -> (x: Int, y: Int) {
        
        func pixelPositionsWithinArea(point: NSPoint, pixelSize: CGFloat, startingPosition: Int) -> Array<CGFloat> {
            var ret = Array<CGFloat>()
            var startLocationOfPixel: CGFloat = pixelSize + CGFloat(startingPosition)
            for _ in 0..<8 {
                ret.append(CGFloat(startLocationOfPixel))
                startLocationOfPixel += CGFloat(pixelSize)
            }
            return ret
        }
        
        let positionsForX = pixelPositionsWithinArea(point: point,
                                                     pixelSize: pixelSize,
                                                     startingPosition: tileStartingPositionX)
        let positionsForY = pixelPositionsWithinArea(point: point,
                                                     pixelSize: pixelSize,
                                                     startingPosition: tileStartingPositionY)
        
//        let xPosition = point.x - CGFloat(tileStartingPositionX)
        
        // To invert the coordinate system for Y we need to subtract the height of the view
        let yPosition = CGFloat(frame.size.height) - point.y
        //TODO: must move away from a linear search algorithm
        var xTileNumber: Int = 0
        var yTileNumber: Int = 0
        for x in 0..<tileSize {
            if point.x < positionsForX[x] {
                break
            } else {
                xTileNumber += 1
            }
        }
        for y in 0..<tileSize {
            if yPosition < positionsForY[y] {
                break
            } else {
                yTileNumber += 1
            }
        }

        return (x: xTileNumber, y: yTileNumber)
    }
    
    func findTileLocation(point: NSPoint) -> TileViewerMapper {
        let positions = startingPositions
        let xPosition = CGFloat(point.x)
        let yPosition = CGFloat(frame.size.height - point.y)
        //TODO: must move away from a linear search algorithm
        var xTileNumber: UInt = 0
        var yTileNumber: UInt = 0
        let t = Int(zoomSize.rawValue)
        for x in 0..<t {
            if xPosition < positions[x] {
                break
            } else {
                xTileNumber += 1
            }
        }
        for y in 0..<t {
            if yPosition < positions[y] {
                break
            } else {
                yTileNumber += 1
            }
        }
        
        return TileViewerMapper(x: xTileNumber, y: yTileNumber, width: 0, height: 0)
    }
    
    func updateEditorWith(pixelData: [Int]?) {
//        self.tiles = pixelData
//        needsDisplay = true
    }
    func update() {
        guard let tiles = tiles else {
            NSLog("ERROR: no tile data for editor")
            return
        }
        var tTiles: [Int] = []
        var offset = startingPosition
        let numberOfBytesPerTile = 64
        let numberOfTiles = Int(zoomSize.rawValue)
        for _ in 0..<numberOfTiles {
            let t = tiles[0+offset..<offset+(numberOfBytesPerTile*numberOfTiles)]
            let ta = Array(t)
            tTiles += ta
            
            offset = offset+((numberOfBytesPerTile*16))
        }
        
        tilesToDraw = tTiles
        
        needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if let ctx = NSGraphicsContext.current()?.cgContext {
            guard tilesToDraw.count > 0 else {
                NSLog("Cannot draw view because tiles is nil")
                return
            }
            // swap coordinate so that 0,0 is top left corner
            ctx.translateBy(x: 0, y: 240)
            ctx.scaleBy(x: 1, y: -1)
            
            let widthPerPixel = frame.size.width/CGFloat(numberOfPixelsPerView)
            let heightPerPixel = frame.size.height/CGFloat(numberOfPixelsPerView)
            
            if widthPerPixel != heightPerPixel {
                NSLog("ERROR dimension (width and height) of the view are not the same.")
                return
            }
            
            var tNumberOfPixelsPerView = 0
            var xPosition = 0
            var yPosition = 0
            let numberOfBytesPerTile = 64
            var tileOffset = 0
            
            for _ in 0..<zoomSize.rawValue*zoomSize.rawValue {
                if tNumberOfPixelsPerView >= numberOfPixelsPerView {
                    yPosition += 1
                    tNumberOfPixelsPerView = 0
                    xPosition = 0
                }
                drawTile(ctx: ctx,
                         tileData: tilesToDraw,
                         pixelsPerTile: 8,
                         startingPosition: tileOffset,
                         pixelDimention: widthPerPixel,
                         x: xPosition,
                         y: yPosition)
                tNumberOfPixelsPerView += numberOfPixelsPerTile
                xPosition += 1
                tileOffset += numberOfBytesPerTile
            }
        }
    }
    
    func drawTile(ctx: CGContext,
                  tileData: [Int],
                  pixelsPerTile: Int,
                  startingPosition: Int,
                  pixelDimention: CGFloat,
                  x: Int, y: Int) {
        if tileData.count == 0{
            NSLog("Tile Editor pixel data is empty")
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
                let colorAtIndex = tileData[indexPerPixel+startingPosition]
                let color = colorPalette[colorAtIndex]
                ctx.setFillColor(color)
                ctx.addRect(pixel)
                ctx.setLineWidth(CGFloat(0.1))
                ctx.drawPath(using: .fillStroke)
                xIndex += pixelDimention
                indexPerPixel += 1
            }
            xIndex = CGFloat(x)*pixelDimention*CGFloat(pixelsPerTile)
            yIndex += pixelDimention
        }
    }
}
