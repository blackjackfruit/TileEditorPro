//
//  TileEditorProDocumentController.swift
//  TileEditorPro
//
//  Created by iury on 5/10/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Cocoa

/**
 Controls the document action for opening, closing, and new documents.
 If a file is currently being edited, and the user decides to open/create another document, then a prompt will ask the user if the current should be released.
 */
class TileEditorProDocumentController: NSDocumentController {
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override func openDocument(_ sender: Any?) {
        if TileEditorDocument.isDocumentCurrentlyOpen {
            guard let window = NSApplication.shared.keyWindow else {
                return
            }
            
            log.w("Cannot create another window")
            NSAlert(error: TileEditorDocumentErrors.openFile.errorObject()).beginSheetModal(for: window, completionHandler: { (modalResponse: NSApplication.ModalResponse) in
                if modalResponse.rawValue == 1000 {
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
            guard let window = NSApplication.shared.keyWindow else {
                    return
            }
            
            log.w("Cannot create another window")
            weak var weakSelf = self
            NSAlert(error: TileEditorDocumentErrors.openFile.errorObject()).beginSheetModal(for: window, completionHandler: { (modalResponse: NSApplication.ModalResponse) in
                if modalResponse.rawValue == 1000 {
                    TileEditorProDocumentController.closeDocuments()
                    if let document = try? weakSelf?.openUntitledDocumentAndDisplay(true),
                        document == nil {
                        guard
                            let window = NSApplication.shared.keyWindow
                            else {
                                return
                        }
                        NSAlert(error: TileEditorDocumentErrors.couldNotCreateNewFile.errorObject()).beginSheetModal(for: window, completionHandler: { (response: NSApplication.ModalResponse) in
                        })
                    }

                }
            })
            
            return
        }
        super.newDocument(sender)
    }
    
    class func closeDocuments() {
        for document in TileEditorProDocumentController.shared.documents {
            document.close()
        }
    }
}
