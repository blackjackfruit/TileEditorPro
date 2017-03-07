//
//  Palette.swift
//  TileEditor
//
//  Created by iury bessa on 3/6/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

/**
 A palette is a group of colors available for a tile
 */
class Palette {
    public var count: Int {
        get {
            return colors.count
        }
    }
    public var colors: [CGColor]
    init() {
        colors = [NSColor.white.cgColor,
                  NSColor.lightGray.cgColor,
                  NSColor.darkGray.cgColor,
                  NSColor.black.cgColor]
    }
    func update(location: Int, color: CGColor) {
        colors[location] = color
    }
}
