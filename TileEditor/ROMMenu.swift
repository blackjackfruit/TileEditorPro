//
//  Menu.swift
//  TileEditor
//
//  Created by iury bessa on 3/16/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

class ROMMenu: NSMenu {
    
    @IBOutlet weak var importData: NSMenuItem? = nil
    @IBOutlet weak var exportData: NSMenuItem? = nil
    @IBOutlet weak var importPalette: NSMenuItem? = nil
    @IBOutlet weak var exportPalette: NSMenuItem? = nil
    
    var editorViewController: EditorViewController? = nil
    var pathOfFile: String? = nil
    
    var dataProcessor = DataProcessor()
    var paletteProcessor = PaletteProccessor()
    
    @IBAction func importData(sender: AnyObject) {
        dataProcessor.importObject { (data: Data?, error: Error?) in
            guard let data = data else {
                
                return
            }
            let tileData = TileData(data: data, type: .none)
            self.editorViewController?.editorViewControllerSettings?.tileData = tileData
            self.editorViewController?.update()
        }
    }
    
    @IBAction func exportData(sender: AnyObject) {
        guard let editorSettings = editorViewController?.editorViewControllerSettings else {
            return
        }
        var dataToExport: Data? = nil
        if editorSettings.isCHRData {
            dataToExport = editorSettings.tileData?.modifiedData
        } else {
            dataToExport = editorSettings.tileData?.modifiedData
        }
        
        if let data = dataToExport {
            dataProcessor.exportObject(object: data, completion: { (error: Error?) in
                print("ExportDataWithError: \(error)")
            })
        } else {
            print("ExportDataWithError: no data to export")
        }
    }
    
    @IBAction func importPalette(sender: AnyObject) {
        
    }
    
    @IBAction func exportPalette(sender: AnyObject) {
        
    }
}
