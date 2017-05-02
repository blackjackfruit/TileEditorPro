//
//  AppDelegate.swift
//  TileEditor
//
//  Created by iury bessa on 10/28/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Cocoa
import Utilities

let log = Log(moduleName: "TileEditorPro")

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var romMenuItem: ROMMenuItem? = nil
    
    func applicationDidFinishLaunching(_ notification: Notification) {
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
    
    
}

