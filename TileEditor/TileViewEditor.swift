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

protocol TileViewEditor {
    func pixelDataChanged(pixelData: [[UInt]])
}

public class TileViewEditor: NSView {
    var nsBitmapImage: NSBitmapImageRep?
    var frameRect: NSRect? = nil
    var colorPalette: Array<CGColor> = [NSColor.white.cgColor,
                                   NSColor.lightGray.cgColor,
                                   NSColor.gray.cgColor,
                                   NSColor.black.cgColor]
    
    // Should be an 8x8, 16x16, 32x32, etc. data set
    var pixelData: [[UInt]] = [[0,1,2,3,0,0,0,0],
                               [0,0,0,0,0,0,0,0],
                               [0,0,3,0,0,3,0,0],
                               [0,0,0,0,0,0,0,0],
                               [0,3,0,0,0,0,3,0],
                               [0,0,3,3,3,3,0,0],
                               [0,0,0,0,0,0,0,0],
                               [0,0,0,0,0,0,0,0]]
    
//    var pixelData: [[UInt]] = [[0,0,0,0,0,0,0,0,3,1,2,3,0,0,0,1],
//                               [0,0,0,0,0,0,0,0,3,1,2,3,0,0,1,0],
//                               [0,0,3,0,0,3,0,0,3,1,2,3,0,1,0,0],
//                               [0,0,0,0,0,0,0,0,3,1,2,3,1,0,0,0],
//                               [0,3,0,0,0,0,3,0,3,1,2,3,0,0,0,0],
//                               [0,0,3,3,3,3,0,0,3,1,2,3,0,0,0,0],
//                               [0,0,0,0,0,0,0,0,3,1,2,3,0,0,0,0],
//                               [0,0,0,0,0,0,0,0,3,1,2,3,0,0,0,0],
//                               [0,0,0,0,0,0,0,0,3,1,2,3,0,0,0,0],
//                               [0,0,0,0,0,0,0,0,3,1,2,3,0,0,0,0],
//                               [0,0,3,0,0,3,0,0,3,1,2,3,0,0,0,0],
//                               [0,0,0,0,0,0,0,0,3,1,2,3,0,0,0,0],
//                               [0,3,0,0,0,0,3,0,3,1,2,3,1,0,0,0],
//                               [0,0,3,3,3,3,0,0,3,1,2,3,0,1,0,0],
//                               [0,0,0,0,0,0,0,0,3,1,2,3,0,0,1,0],
//                               [0,0,0,0,0,0,0,0,3,1,2,3,0,0,0,1]]
    
    override init(frame frameRect: NSRect) {
        self.frameRect = frameRect
        super.init(frame: frameRect)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        frameRect = self.frame
        nsBitmapImage = NSBitmapImageRep(bitmapDataPlanes: nil,
                                         pixelsWide: Int(self.frame.size.width),
                                         pixelsHigh: Int(self.frame.size.height),
                                         bitsPerSample: 8,
                                         samplesPerPixel: 3,
                                         hasAlpha: false,
                                         isPlanar: false,
                                         colorSpaceName: "NSCalibratedRGBColorSpace",
                                         bytesPerRow: 0,
                                         bitsPerPixel: 0)
        
    }
    func paint() {
        
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        if let ctx = NSGraphicsContext.current()?.cgContext {
            // swap coordinate so that 0,0 is top left corner
            ctx.translateBy(x: 0, y: 240)
            ctx.scaleBy(x: 1, y: -1)
            
            // These are the number of pixels to display from left to right and top to down
            let numberOfPixelsToDisplay = CGFloat(pixelData[0].count)
            let width = Int(frame.size.width/numberOfPixelsToDisplay)
            let height = Int(frame.size.height/numberOfPixelsToDisplay)
            
            var xIndex = 0
            var yIndex = 0
            
            for rowData in pixelData {
                for columnData in rowData {
                    let pixel = CGRect(x: xIndex, y: yIndex, width: width, height: height)
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
