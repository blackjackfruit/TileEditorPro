//
//  TileEditorDocument.swift
//  TileEditor
//
//  Created by iury bessa on 3/20/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation
import AppKit

class TileEditorDocument: NSDocument {
    
    var tileEditorVC: EditorViewController? = nil
    var editorViewControllerSettings: EditorViewControllerSettings? = nil
    
    override init() {
        super.init()
    }
    
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let windowController = storyboard.instantiateController(withIdentifier: "MainTileEditor") as? NSWindowController,
        let editorViewController = windowController.contentViewController as? EditorViewController else {
            NSLog("")
            return
        }
        
        if self.editorViewControllerSettings == nil {
            self.editorViewControllerSettings = editorViewController.editorViewControllerSettings
        } else {
            editorViewController.editorViewControllerSettings = editorViewControllerSettings
        }
        editorViewController.editorViewControllerSettings?.tileDataType = .nes
        
        editorViewController.update()
        tileEditorVC = editorViewController
        
        self.addWindowController(windowController)
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
