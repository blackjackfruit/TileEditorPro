
//  TileEditorDocument.swift
//  TileEditor
//
//  Created by iury bessa on 3/20/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation
import AppKit

class TileEditorDocument: NSDocument {
    
    // This object is set when makeWindowControllers is called
    weak var editorViewController: EditorViewController? = nil
    
    // This variable is set when opening a project from a file
    weak var editorViewControllerSettings: EditorViewControllerSettings? = nil
    
    weak var windowController: NSWindowController? = nil
    
    override init() {
        super.init()
    }
    
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        self.windowController = storyboard.instantiateController(withIdentifier: "MainTileEditor") as? NSWindowController
        guard let windowController = self.windowController,
              let createdEditorViewController = windowController.contentViewController as? EditorViewController 
        else {
            NSLog("WindowController not found")
            return
        }
        
        if let editorViewControllerSettings = self.editorViewControllerSettings {
            createdEditorViewController.editorViewControllerSettings = editorViewControllerSettings
            self.editorViewControllerSettings = editorViewControllerSettings
        } else {
            let editorViewControllerSettings = EditorViewControllerSettings.emptyConsoleObject(consoleType: .nes)
            createdEditorViewController.editorViewControllerSettings = editorViewControllerSettings
            self.editorViewControllerSettings = editorViewControllerSettings
        }
        
        if let palettes = self.editorViewControllerSettings?.palettes {
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
        let romMenu = delegate?.romMenuItem?.romMenu
        
        romMenu?.editorViewController = self.editorViewController
    }
    override func data(ofType typeName: String) throws -> Data {
        guard let tileEditorSettings = self.editorViewControllerSettings else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: tileEditorSettings)
        return data
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        do {
            let unarchivedData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as NSData)
            guard let tileEditorSettings = unarchivedData as? EditorViewControllerSettings else {
                throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
            }
            self.editorViewControllerSettings = tileEditorSettings
        }
        catch {
            NSLog("\(error)")
        }
        
    }
    override func close() {
        super.close()
    }
}
