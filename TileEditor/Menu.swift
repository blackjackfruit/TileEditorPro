//
//  Menu.swift
//  TileEditor
//
//  Created by iury bessa on 3/16/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

class FileMenuItem: NSMenuItem {
    
    var mainEditor: EditorViewController? = nil
    var pathOfFile: String? = nil
    
    func addFilePathToRecentFiles(path: String) {
        NSDocumentController.shared().noteNewRecentDocumentURL(URL(fileURLWithPath: path))
    }
    
    func loadFileWith(path: String) {
        if path.characters.count == 0 {
            NSLog("File path is not valid")
            return
        }
        do {
            if let data: Data = try FileLoader.fileForEditing(path: path) {
                let fileType = FileLoader.checkType(data: data)
                var tileData: TileData? = nil
                switch fileType {
                case .nes:
                    tileData = TileData(data: data, type: .nes)
                case .none:
                    tileData = TileData(data: data, type: .none)
                case .unknown:
                    return
                }
                
                if tileData == nil {
                    let alert = NSAlert()
                    alert.messageText = "Error"
                    alert.informativeText = "Could not load file"
                    alert.runModal()
                    return
                }
                
                mainEditor?.editorViewControllerSettings = EditorViewControllerSettings()
                mainEditor?.editorViewControllerSettings?.tileData = tileData
                mainEditor?.editorViewControllerSettings?.tileDataType = .nes
                mainEditor?.update()
                
            } else {
                // TODO: some error
            }
        } catch {
            
        }
    }
    
    func saveFileTo(path: String) {
        guard let vc = mainEditor else {
            return
        }
        if let data = vc.editorViewControllerSettings?.tileData?.modifiedData {
            _ = FileLoader.saveEditedFileTo(path: path, data: data)
        }
    }
}
