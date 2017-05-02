//
//  LogMessages.swift
//  TileEditorPro
//
//  Created by iury on 5/1/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Cocoa

class LogMessages: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        return "boo"
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 5
    }
}
