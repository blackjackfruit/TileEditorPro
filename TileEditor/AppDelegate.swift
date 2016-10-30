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
            if let fileDataFromPath = NSData(contentsOfFile: path) {
                vc?.loadFile(data: fileDataFromPath)
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        vc = NSApplication.shared().mainWindow?.contentViewController as? ViewController
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

