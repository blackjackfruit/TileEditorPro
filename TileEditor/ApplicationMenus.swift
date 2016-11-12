//
//  ApplicationMenus.swift
//  TileEditor
//
//  Created by iury bessa on 11/11/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

class ApplicationMenus: NSApplication {
    @IBOutlet weak var openRecent: NSMenuItem?
    @IBOutlet weak var saveFile: NSMenuItem?
    
    var pathOfFile: String? = nil
    var vc: ViewController? = nil
    
    @IBAction func newFile(_ sender: AnyObject) {
        let sampleData = Data(count: 8192)
        let tileData = TileData(data: sampleData)
        tileData.type = .nes
        vc?.tileData = tileData
        vc?.tileDataType = .nes
        vc?.update()
    }
    
    @IBAction func openDirectory(_ sender: AnyObject) {
        let myFileDialog: NSOpenPanel = NSOpenPanel()
        myFileDialog.runModal()
        if let path = myFileDialog.url?.path {
            self.loadFileWith(path: path)
            _ = self.recentFiles(addPath: path)
            addFilePathToRecentFiles(path: path)
        }
    }
    
    @IBAction func saveFile(_ sender: AnyObject) {
        if let pathToSaveTo = pathOfFile {
            saveFileTo(path: pathToSaveTo)
        } else {
            NSLog("Cannot save file because path is nil")
        }
    }
    @IBAction func saveFileAs(_ sender: AnyObject) {
        let panel = NSSavePanel()
        panel.runModal()
        if let pathToSaveFileAs = panel.url?.path {
            saveFileTo(path: pathToSaveFileAs)
        } else {
            NSLog("Could not get path to save")
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func addFilePathToRecentFiles(path: String) {
        if openRecent?.hasSubmenu != nil {
            let subMenu = openRecent?.submenu
            let menuItem = NSMenuItem(title: path, action: #selector(loadRecentItemSelected(sender:)), keyEquivalent: "")
            subMenu?.addItem(menuItem)
        }
    }
    func recentFiles(addPath: String?) -> Array<String> {
        let userDefaults = UserDefaults.standard
        var list = userDefaults.object(forKey: "RecentFiles") as? Array<String>
        if list == nil {
            list = Array<String>()
        }
        
        if addPath != nil {
            list?.append(addPath!)
            userDefaults.set(list, forKey: "RecentFiles")
        }
        
        return list!
    }
    
    func loadRecentItemSelected(sender: NSMenuItem) {
        let filePathFromTitle = sender.title
        self.loadFileWith(path: filePathFromTitle)
    }
    
    func loadFileWith(path: String) {
        if path.characters.count == 0 {
            NSLog("File path is not valid")
            return
        }
        do {
            if let data: Data = try FileLoader.fileForEditing(path: path) {
                vc?.zoomSize = .x4
                
                let tileData = TileData(data: data)
                tileData.type = .nes
                vc?.tileData = tileData
                vc?.update()
            } else {
                // TODO: some error
            }
        } catch {
            
        }
    }
    func saveFileTo(path: String) {
        guard let vc = vc else {
            return
        }
        if let data = vc.tileData?.processedData {
            _ = FileLoader.saveEditedFileTo(path: path, data: data)
        }
    }

}
