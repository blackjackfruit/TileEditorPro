//
//  AppDelegate.swift
//  TileEditor
//
//  Created by iury bessa on 10/28/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Cocoa
import YKUtilities

let log = Log(moduleName: "TileEditorPro")

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var romMenuItem: ROMMenuItem? = nil
    
    let documentController = TileEditorProDocumentController.shared
    
    func applicationWillBecomeActive(_ notification: Notification) {
        
    }
    func applicationDidFinishLaunching(_ notification: Notification) {
    
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return false
    }
    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        if TileEditorDocument.isDocumentCurrentlyOpen {
            guard
                let window = NSApplication.shared.keyWindow
            else {
                return true
            }
            
            NSAlert(error: TileEditorDocumentErrors.openFile.errorObject()).beginSheetModal(for: window, completionHandler: { (modalResponse: NSApplication.ModalResponse) in
                if modalResponse.rawValue == 1000, let url = URL(string: "file://"+filename) {
                    TileEditorProDocumentController.closeDocuments()
                    TileEditorProDocumentController.shared.openDocument(withContentsOf: url, display: true, completionHandler: { (docuemt: NSDocument?, status: Bool, error: Error?) in
                        
                    })
                }
            })
            return true
        }
        return false
    }
}

