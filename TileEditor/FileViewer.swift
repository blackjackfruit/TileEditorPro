//
//  FileDataViewer.swift
//  TileEditor
//
//  Created by iury bessa on 10/29/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

enum SelectionSize: UInt {
    case p8x8 = 8
    case p16x16 = 16
    case p32x32 = 32
}

protocol FileViewerProtocol {
    func dataSelectedAtLocation(x: UInt, y: UInt)
}

class FileViewer: NSView {
    var selectionSize: SelectionSize = .p8x8
    var widthAndHeightPerTile: CGFloat = 60
    var delegate: FileViewerProtocol? = nil
    var dataForViewer: NSData? = nil
    var pixelData: [[UInt]] = [[]]
    var colorPalette: Array<CGColor> = [NSColor.white.cgColor,
                                        NSColor.lightGray.cgColor,
                                        NSColor.gray.cgColor,
                                        NSColor.black.cgColor]
    var boxSelection: CGRect? = nil
    var cursorLocation: (x: UInt, y: UInt) = (x: 0, y: 0)
    
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
    
    func updateView(selectionSize: SelectionSize) {
        self.selectionSize = selectionSize
        var wh: CGFloat = 0
        switch selectionSize {
        case .p8x8:
            wh = frame.size.width/4.0
            break
        case .p16x16:
            wh = frame.size.width/2.0
            break
        case .p32x32:
            wh = frame.size.width/1.0
            break
        default:
            wh = frame.size.width/4.0
            break
        }
        
        if let bs = boxSelection {
            boxSelection = CGRect(x: CGFloat(bs.origin.x)*widthAndHeightPerTile,
                                  y: CGFloat(bs.origin.y)*widthAndHeightPerTile,
                                  width: wh,
                                  height: wh)
            delegate?.dataSelectedAtLocation(x: cursorLocation.x, y: cursorLocation.y)
            needsDisplay = true
        }
        
    }
    
    func findBoxSelectionLocation(point: NSPoint) -> (x: UInt, y: UInt, width: CGFloat, height: CGFloat)? {
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
        var xTileNumber: UInt = 0
        var yTileNumber: UInt = 0
        
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
        cursorLocation = (xTileNumber, yTileNumber)
        
        return (x: xTileNumber,
                y: yTileNumber,
                width: (frame.size.width/32.0)*CGFloat(8),
                height: (frame.size.width/32.0)*CGFloat(8))
    }
    override func mouseDown(with event: NSEvent) {
        let p = event.locationInWindow
        let s = convert(p, from: nil)
        
        if let boxLocation = findBoxSelectionLocation(point: s) {
            var multiplySize: CGFloat = 0
            switch selectionSize {
            case .p8x8:
                multiplySize = 1
                break
            case .p16x16:
                multiplySize = 2
                break
            case .p32x32:
                multiplySize = 4
                break
            }
            
            boxSelection = CGRect(x: CGFloat(boxLocation.x)*widthAndHeightPerTile,
                                  y: CGFloat(boxLocation.y)*widthAndHeightPerTile,
                                  width: boxLocation.width*CGFloat(multiplySize),
                                  height: boxLocation.height*CGFloat(multiplySize))
            
            delegate?.dataSelectedAtLocation(x: boxLocation.x*8,
                                             y: boxLocation.y*8)
            needsDisplay = true
        }
        
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if let ctx = NSGraphicsContext.current()?.cgContext {
            // swap coordinate so that 0,0 is top left corner
            ctx.translateBy(x: 0, y: 480)
            ctx.scaleBy(x: 1, y: -1)

            if pixelData.count > 0 && pixelData[0].count > 0 {
                // These are the number of pixels to display from left to right and top to down
                let width = CGFloat(frame.size.width/32)
                let height = CGFloat(frame.size.height/64)
                
                var xIndex:CGFloat = 0
                var yIndex:CGFloat = 0
                
                for y in 0..<64 {
                    for x in 0..<32 {
                        let pixelDataItem = pixelData[y][x]
                        let pixel = CGRect(x: xIndex,
                                           y: yIndex,
                                           width: width,
                                           height: height)
                        let color = colorPalette[Int(pixelDataItem)]
                        ctx.setFillColor(color)
                        ctx.addRect(pixel)
                        ctx.drawPath(using: .fillStroke)
                        xIndex += width
                    }
                    xIndex = 0
                    yIndex += height
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
}
