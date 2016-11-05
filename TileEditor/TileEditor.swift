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
    func pixelDataChanged(pixelData: [[Int]])
}

struct TileViewerMapper {
    let x: UInt
    let y: UInt
    let width: UInt
    let height: UInt
}

class TileEditor: NSView {
    var delegate: TileEditorProtocol? = nil
    var colorPalette: Array<CGColor> = [NSColor.white.cgColor,
                                   NSColor.lightGray.cgColor,
                                   NSColor.gray.cgColor,
                                   NSColor.black.cgColor]
    var colorFromPalette: Int = 3
    // Should be an 8x8, 16x16, 32x32, etc. data set
    var tiles: [[Int]]? = nil
    var numberOfPixelsPerTile: Int = 0
    // These are the number of pixels to display from left to right and top to down
    var numberOfPixelsPerView: Int = 0
    
    // Since the TileViewEditor is a square, we don't need to do anything different for computing x/y starting positions
    var startingPixelPositions: Array<CGFloat> {
        var ret = Array<CGFloat>()
        let widthPerPixel = CGFloat(frame.width/CGFloat(8))
        var startLocationOfPixel: CGFloat = widthPerPixel
        for _ in 0..<8 {
            ret.append(CGFloat(startLocationOfPixel))
            startLocationOfPixel += CGFloat(widthPerPixel)
        }
        return ret
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override func mouseDown(with event: NSEvent) {
        guard let tiles = tiles else {
            NSLog("Tiles is nil")
            return
        }
        let p = event.locationInWindow
        let s = convert(p, from: nil)
        let tileToUpdate = findTileLocation(point: s)
        //tiles?[Int(tileToUpdate.y)][Int(tileToUpdate.x)] = colorFromPalette
        delegate?.pixelDataChanged(pixelData: tiles)
        needsDisplay = true
    }
    func findTileLocation(point: NSPoint) -> TileViewerMapper {
        let positions = startingPixelPositions
        let xPosition = CGFloat(point.x)
        let yPosition = CGFloat(frame.size.height - point.y)
        let numberOfPixels = 8
        //TODO: must move away from a linear search algorithm
        var xTileNumber: UInt = 0
        var yTileNumber: UInt = 0
        for x in 0..<numberOfPixels {
            if xPosition < positions[x] {
                break
            } else {
                xTileNumber += 1
            }
        }
        for y in 0..<numberOfPixels {
            if yPosition < positions[y] {
                break
            } else {
                yTileNumber += 1
            }
        }
        
        return TileViewerMapper(x: xTileNumber, y: yTileNumber, width: 0, height: 0)
    }
    
    func updateEditorWith(pixelData: [[Int]]?) {
        self.tiles = pixelData
        needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if let ctx = NSGraphicsContext.current()?.cgContext {
            guard let tiles = tiles else {
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
            for t in tiles {
                if tNumberOfPixelsPerView >= numberOfPixelsPerView {
                    yPosition += 1
                    tNumberOfPixelsPerView = 0
                    xPosition = 0
                }
                drawTile(ctx: ctx,
                         tileData: t,
                         pixelsPerTile: 8,
                         pixelDimention: widthPerPixel,
                         x: xPosition, y: yPosition)
                tNumberOfPixelsPerView += numberOfPixelsPerTile
                xPosition += 1
            }
        }
    }
    
    func drawTile(ctx: CGContext,
                  tileData: [Int],
                  pixelsPerTile: Int,
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
