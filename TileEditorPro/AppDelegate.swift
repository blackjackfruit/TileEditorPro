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
    
    @IBOutlet weak var romMenuItem: ROMMenuItem? = nil
    
    func applicationDidFinishLaunching(_ notification: Notification) {
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        print("active")
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
    
    
}

