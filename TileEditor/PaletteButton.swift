//
//  PaletteButton.swift
//  TileEditor
//
//  Created by iury bessa on 10/29/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

class PaletteButton: NSButton {
    
    override var wantsUpdateLayer: Bool {
        return true
    }
    
    
    func resetState() {
        title = ""
        state = 0
    }
}
