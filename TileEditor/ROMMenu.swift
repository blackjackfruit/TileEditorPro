//
//  Menu.swift
//  TileEditor
//
//  Created by iury bessa on 3/16/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

class ROMMenu: NSMenu, NSMenuDelegate {
    
    @IBOutlet weak var importData: NSMenuItem? = nil
    @IBOutlet weak var exportData: NSMenuItem? = nil
    @IBOutlet weak var importPalette: NSMenuItem? = nil
    @IBOutlet weak var exportPalette: NSMenuItem? = nil
    
    weak var editorViewController: EditorViewController? = nil
    var pathOfFile: String? = nil
    
    var dataProcessor = DataProcessor()
    var paletteProcessor = PaletteProccessor()
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
//        self.delegate = self
    }
    
    @IBAction func importData(sender: AnyObject) {
        dataProcessor.importObject { (data: Data?, error: Error?) in
            guard let data = data else {
                
                return
            }
            
            if let console = ConsoleDataFactory.generate(data: data) {
                self.editorViewController?.tileEditor?.tileData = console.1
                self.editorViewController?.editorViewControllerSettings.tileData = console.1
                self.editorViewController?.update()
            } else {
                NSLog("")
            }
        }
    }
    
    @IBAction func exportData(sender: AnyObject) {
        guard let editorSettings = editorViewController?.editorViewControllerSettings else {
            return
        }
        
        var dataToExport: Data? = nil
        if editorSettings.isCHRData {
            dataToExport = editorSettings.tileData?.data
        } else {
            dataToExport = editorSettings.tileData?.data
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
        guard let editorSettings = editorViewController?.editorViewControllerSettings else {
            return
        }
        paletteProcessor.paletteType = .nes
        paletteProcessor.importObject { [weak self] (palettes: [PaletteProtocol]?, error: Error?) in
            guard let palettes = palettes else {
                print("Could not import palette(s): \(error)")
                return
            }
            editorSettings.palettes = palettes
            self?.editorViewController?.selectablePalettes = palettes
            self?.editorViewController?.update()
        }
    }
    
    @IBAction func exportPalette(sender: AnyObject) {
        guard let editorSettings = editorViewController?.editorViewControllerSettings, let palettes = editorSettings.palettes else {
            return
        }
        paletteProcessor.paletteType = .nes
        paletteProcessor.exportObject(object: palettes) { (error: Error?) in
            guard error == nil else {
                print("Could not export palette(s): \(error)")
                return
            }
        }
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        guard self.editorViewController != nil else {
            self.importData?.isEnabled = false
            self.exportData?.isEnabled = false
            self.importPalette?.isEnabled = false
            self.exportPalette?.isEnabled = false
            return
        }
        self.importData?.isEnabled = true
        self.exportData?.isEnabled = true
        self.importPalette?.isEnabled = true
        self.exportPalette?.isEnabled = true
    }
}
