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

    var vc: ViewController? = nil

    @IBAction func openDirectory(_ sender: AnyObject) {
        let myFileDialog: NSOpenPanel = NSOpenPanel()
        myFileDialog.runModal()
        if let path = myFileDialog.url?.path {
            NSLog("\(path)")
            do {
                if let filesData: [[[UInt]]] = try FileLoader.fileForEditing(path: path) {
                    vc?.pixelData = dummyData8x8
                } else {
                    // TODO: some error
                }
            } catch {
                
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        vc = NSApplication.shared().mainWindow?.contentViewController as? ViewController
        
        
        
        do {
            if let filesData: [[[UInt]]] = try FileLoader.fileForEditing(path: "/Users/yello/Documents/Dropbox/NES/src/git/demo.chr") {
                vc?.pixelData = dummyData8x8
            } else {
                // TODO: some error
            }
        } catch {
            
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

