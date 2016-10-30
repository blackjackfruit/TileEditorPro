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

protocol TileViewEditorProtocol {
    func pixelDataChanged(pixelData: [[UInt]])
}

struct Tile {
    let x: UInt
    let y: UInt
    let width: UInt
    let height: UInt
}

class TileViewEditor: NSView {
    var delegate: TileViewEditorProtocol? = nil
    var colorPalette: Array<CGColor> = [NSColor.white.cgColor,
                                   NSColor.lightGray.cgColor,
                                   NSColor.gray.cgColor,
                                   NSColor.black.cgColor]
    var colorFromPalette: UInt = 3
    // Should be an 8x8, 16x16, 32x32, etc. data set
    var pixelData: [[UInt]] = [[]]
    
    // Since the TileViewEditor is a square, we don't need to do anything different for computing x/y starting positions
    var startingPixelPositions: Array<CGFloat> {
        var ret = Array<CGFloat>()
        let widthPerPixel = CGFloat(frame.width/CGFloat(pixelData[0].count))
        var startLocationOfPixel: CGFloat = widthPerPixel
        for _ in 0..<pixelData[0].count {
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
        let p = event.locationInWindow
        let s = convert(p, from: nil)
        let tileToUpdate = findTileLocation(point: s)
        pixelData[Int(tileToUpdate.y)][Int(tileToUpdate.x)] = colorFromPalette
        needsDisplay = true
    }
    func findTileLocation(point: NSPoint) -> Tile {
        let positions = startingPixelPositions
        let xPosition = CGFloat(point.x)
        let yPosition = CGFloat(frame.size.height - point.y)
        let numberOfPixels = pixelData[0].count
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
        
        return Tile(x: xTileNumber, y: yTileNumber, width: 0, height: 0)
    }
    
    func updateEditorWith(pixelData: [[UInt]]) {
        self.pixelData = pixelData
        needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if let ctx = NSGraphicsContext.current()?.cgContext {
            // swap coordinate so that 0,0 is top left corner
            ctx.translateBy(x: 0, y: 240)
            ctx.scaleBy(x: 1, y: -1)
            
            // These are the number of pixels to display from left to right and top to down
            let numberOfPixelsToDisplay = CGFloat(pixelData[0].count)
            let width = CGFloat(frame.size.width/numberOfPixelsToDisplay)
            let height = CGFloat(frame.size.height/numberOfPixelsToDisplay)
            
            var xIndex:CGFloat = 0
            var yIndex:CGFloat = 0
            
            for rowData in pixelData {
                for columnData in rowData {
                    let pixel = CGRect(x: xIndex,
                                       y: yIndex,
                                       width: width,
                                       height: height)
                    let color = colorPalette[Int(columnData)]
                    ctx.setFillColor(color)
                    ctx.addRect(pixel)
                    ctx.drawPath(using: .fillStroke)
                    xIndex += width
                }
                xIndex = 0
                yIndex += height
            }
        }
    }
}
