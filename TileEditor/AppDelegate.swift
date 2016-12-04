//
//  AppDelegate.swift
//  TileEditor
//
//  Created by iury bessa on 10/28/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var openRecent: NSMenuItem?
    @IBOutlet weak var saveFile: NSMenuItem?
    
    var vc: ViewController? = nil
    var pathOfFile: String? = nil

    @IBAction func newFile(_ sender: AnyObject) {
        let sampleData = Data(count: 8192)
        let tileData = TileData(data: sampleData)
        tileData.type = .nes
        vc?.tileData = tileData
        vc?.tileDataType = .nes
        vc?.update()
        
        self.pathOfFile = nil
    }
    
    @IBAction func openDirectory(_ sender: AnyObject) {
        let myFileDialog: NSOpenPanel = NSOpenPanel()
        myFileDialog.runModal()
        if let path = myFileDialog.url?.path {
            self.loadFileWith(path: path)
            _ = self.recentFiles(addPath: path)
            addFilePathToRecentFiles(path: path)
            self.pathOfFile = path
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
            self.pathOfFile = pathToSaveFileAs
            addFilePathToRecentFiles(path: pathToSaveFileAs)
        } else {
            NSLog("Could not get path to save")
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        vc = NSApplication.shared().mainWindow?.contentViewController as? ViewController
        
        let sampleData = Data(count: 8192)
        let tileData = TileData(data: sampleData)
        tileData.type = .nes
        vc?.tileData = tileData
        vc?.tileDataType = .nes
        vc?.update()
        
        if openRecent?.hasSubmenu != nil {
            var recentFiles = self.recentFiles(addPath: nil)
            if recentFiles.count >= 6 {
                let arraySlice = recentFiles[0..<6]
                recentFiles = Array(arraySlice)
            }
            for filePath in recentFiles {
                addFilePathToRecentFiles(path: filePath)
            }
        }
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem == saveFile {
            if pathOfFile == nil {
                return false
            }
        }
        return true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
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
        self.pathOfFile = filePathFromTitle
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

