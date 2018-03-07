
//  TileEditorDocument.swift
//  TileEditor
//
//  Created by iury bessa on 3/20/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation
import AppKit

enum TileEditorDocumentErrors {
    case openFile
    case couldNotCreateNewFile
    
    func errorObject() -> NSError {
        let retError: NSError
        switch self {
        case .openFile:
            retError = NSError(domain: "TileEditorDocument", code: 0,
                               userInfo: [NSLocalizedDescriptionKey:"Would you like to close current project?",
                                          NSLocalizedRecoverySuggestionErrorKey:"Any work not saved will be lost",
                                          NSLocalizedRecoveryOptionsErrorKey: ["Close","Cancel"]])
        case .couldNotCreateNewFile:
            retError = NSError(domain: "TileEditorDocument", code: 0,
                               userInfo: [NSLocalizedDescriptionKey:"New document could not be created"])
        }
        
        return retError
    }
}

class TileEditorDocument: NSDocument {
    
    static var isDocumentCurrentlyOpen: Bool {
        return TileEditorProDocumentController.shared.documents.count > 0
    }
    
    // This object is set when makeWindowControllers is called
    weak var editorViewController: EditorViewController? = nil
    
    // This variable is set when opening a project from a file
    weak var editorViewControllerSettings: EditorViewControllerSettings? = nil
    
    // TODO: Must move this to a proper error class

    
    override init() {
        super.init()
    }
    
    override class func canConcurrentlyReadDocuments(ofType typeName: String) -> Bool {
        return false
    }
    
    override func makeWindowControllers() {
        // TODO: cannot create another window at this moment because a bug exists with Rom->Import referencing the new window created and not the window currently selected
        
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        guard
            let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "MainTileEditor")) as? NSWindowController,
            let createdEditorViewController = windowController.contentViewController as? EditorViewController
        else {
            log.e("WindowController not found")
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
        }
        
        self.editorViewController = createdEditorViewController
        self.editorViewController?.setup()
        
        self.setupMenuItems()
        self.addWindowController(windowController)
    }
    
    func setupMenuItems() {
        let delegate = NSApplication.shared.delegate as? AppDelegate
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
            let unarchivedData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
            guard let tileEditorSettings = unarchivedData as? EditorViewControllerSettings else {
                throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
            }
            self.editorViewControllerSettings = tileEditorSettings
        }
        catch {
            log.e("\(error)")
        }
        
    }
    
}
