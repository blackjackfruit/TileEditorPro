//
//  ROMMenuItem.swift
//  TileEditor
//
//  Created by iury bessa on 4/8/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import AppKit
import Foundation

class ROMMenuItem: NSMenuItem {
    @IBOutlet weak var romMenu: ROMMenu? = nil
    
    
    override var hasSubmenu: Bool {
        guard
            let romMenu = self.romMenu
        else {
            return false
        }
        if TileEditorDocument.isDocumentCurrentlyOpen == false {
            romMenu.exportPalette?.isEnabled = false
            romMenu.importPalette?.isEnabled = false
            romMenu.exportData?.isEnabled = false
            romMenu.importData?.isEnabled = false
        } else {
            romMenu.exportPalette?.isEnabled = true
            romMenu.importPalette?.isEnabled = true
            romMenu.exportData?.isEnabled = true
            romMenu.importData?.isEnabled = true
        }
        
        return super.hasSubmenu
    }
}
