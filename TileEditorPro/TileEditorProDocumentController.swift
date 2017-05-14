//
//  TileEditorProDocumentController.swift
//  TileEditorPro
//
//  Created by iury on 5/10/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Cocoa

class TileEditorProDocumentController: NSDocumentController {

    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override func openDocument(_ sender: Any?) {
        if TileEditorDocument.isDocumentCurrentlyOpen {
            guard
                let window = NSApplication.shared().keyWindow
                else {
                    return
            }
            log.w("Cannot create another window")
            NSAlert(error: TileEditorDocumentErrors.openFile.errorObject()).beginSheetModal(for: window, completionHandler: { (modalResponse: NSModalResponse) in
                if modalResponse == 1000 {
                    TileEditorProDocumentController.closeDocuments()
                    super.openDocument(sender)
                }
            })
            return
        }
        super.openDocument(sender)
    }
    override func newDocument(_ sender: Any?) {
        if TileEditorDocument.isDocumentCurrentlyOpen {
            guard
                let window = NSApplication.shared().keyWindow
                else {
                    return
            }
            log.w("Cannot create another window")
            weak var weakSelf = self
            NSAlert(error: TileEditorDocumentErrors.openFile.errorObject()).beginSheetModal(for: window, completionHandler: { (modalResponse: NSModalResponse) in
                if modalResponse == 1000 {
                    TileEditorProDocumentController.closeDocuments()
                    if let document = try? weakSelf?.openUntitledDocumentAndDisplay(true),
                        document == nil {
                        guard
                            let window = NSApplication.shared().keyWindow
                            else {
                                return
                        }
                        NSAlert(error: TileEditorDocumentErrors.couldNotCreateNewFile.errorObject()).beginSheetModal(for: window, completionHandler: { (response: NSModalResponse) in
                        })
                    }

                }
            })
            return
        }
        super.newDocument(sender)
    }
    
    class func closeDocuments() {
        for document in TileEditorProDocumentController.shared().documents {
            document.close()
        }
    }
}
