//
//  TileDrawer.swift
//  TileEditor
//
//  Created by iury bessa on 11/5/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

class TileDrawer: NSView {
    func startingPixelPositions(width: CGFloat,
                                height: CGFloat,
                                numberOfSquaresVertically: Int,
                                numberOfSquaresHorizontally: Int)
        -> (x:Array<CGFloat>,y: Array<CGFloat>)? {
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
    func findBoxSelectionLocation(point: NSPoint,
                                  numberOfSelectableTilesVertically: Int,
                                  numberOfSelectableTilesHorizontally: Int) -> (x: Int, y: Int, width: CGFloat, height: CGFloat)? {
        guard let pixelPositions = startingPixelPositions(width: frame.size.width,
                                                          height: frame.size.height,
                                                          // the lowest number of boxes we can have horizontally is 4 (4 8x8 tiles)
            numberOfSquaresVertically: numberOfSelectableTilesVertically,
            numberOfSquaresHorizontally: numberOfSelectableTilesHorizontally) else {
                return nil
        }
        let xPosition = CGFloat(point.x)
        let yPosition = CGFloat(frame.size.height - point.y)
        //TODO: must move away from a linear search algorithm
        var xTileNumber: Int = 0
        var yTileNumber: Int = 0
        
        for x in 0..<16 {
            if xPosition < pixelPositions.x[x] {
                break
            } else {
                xTileNumber += 1
            }
        }
        for y in 0..<32 {
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
}
