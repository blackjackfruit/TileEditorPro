
//  TileEditorDocument.swift
//  TileEditor
//
//  Created by iury bessa on 3/20/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation
import AppKit

class TileEditorDocument: NSDocument {
    
    var editorViewController: EditorViewController? = nil
    var editorViewControllerSettings: EditorViewControllerSettings? = nil
    
    override init() {
        super.init()
    }
    
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let windowController = storyboard.instantiateController(withIdentifier: "MainTileEditor") as? NSWindowController,
        let createdEditorViewController = windowController.contentViewController as? EditorViewController else {
            NSLog("WindowController not found")
            return
        }
        
        if self.editorViewControllerSettings == nil {
            self.editorViewControllerSettings = createdEditorViewController.editorViewControllerSettings
        } else {
            createdEditorViewController.editorViewControllerSettings = editorViewControllerSettings
        }
        
        if let palettes = self.editorViewControllerSettings?.palettes {
            createdEditorViewController.selectableColors = palettes[0]
            createdEditorViewController.selectablePalettes = palettes
            // No need to setup the GeneralColorPalette because that is not saved in the file and the editor will load up the correct one based off of tileDataType
        }
        
        self.editorViewController = createdEditorViewController
        self.editorViewController?.update()
        
        setupMenuItems()
        
        self.addWindowController(windowController)
    }
    func setupMenuItems() {
        let delegate = NSApplication.shared().delegate as? AppDelegate
        let romMenu = delegate?.ROMMenu
        
        romMenu?.editorViewController = self.editorViewController
    }
    override func data(ofType typeName: String) throws -> Data {
        guard let tileEditorSettings = self.editorViewControllerSettings else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        return NSKeyedArchiver.archivedData(withRootObject: tileEditorSettings)
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        guard let tileEditorSettings = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as NSData) as? EditorViewControllerSettings else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        self.editorViewControllerSettings = tileEditorSettings
    }
}
