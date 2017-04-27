//
//  TileDrawer.swift
//  TileEditor
//
//  Created by iury bessa on 11/5/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

public
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
}
