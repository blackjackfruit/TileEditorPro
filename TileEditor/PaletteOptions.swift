//
//  PaletteOptions.swift
//  TileEditor
//
//  Created by iury bessa on 11/5/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

class PaletteSelections: NSView {
    
    override func draw(_ dirtyRect: NSRect) {
        if let ctx = NSGraphicsContext.current()?.cgContext {
            ctx.setFillColor(NSColor.gray.cgColor)
            ctx.addRect(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
            ctx.setLineWidth(CGFloat(0.01))
            ctx.drawPath(using: .fillStroke)
        }
    }
}

class PaletteColors: NSView {
    override func draw(_ dirtyRect: NSRect) {
        if let ctx = NSGraphicsContext.current()?.cgContext {
            ctx.setFillColor(NSColor.gray.cgColor)
            ctx.addRect(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
            ctx.setLineWidth(CGFloat(0.01))
            ctx.drawPath(using: .fillStroke)
        }
    }
}
