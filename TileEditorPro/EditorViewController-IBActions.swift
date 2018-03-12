//
//  EditorViewController-IBActions.swift
//  TileEditorPro
//
//  Created by iury on 9/19/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Cocoa
import TileEditor

// MARK: IBActions
extension EditorViewController {
    @IBAction func changeZoomSize(_ sender: Any) {
        if let popUpButton = sender as? NSPopUpButton {
            var zoomSize: ZoomSize = .x4
            if popUpButton.titleOfSelectedItem == "x1" {
                zoomSize = .x1
            } else if popUpButton.titleOfSelectedItem == "x2" {
                zoomSize = .x2
            }
            self.tileEditor?.zoomSize = zoomSize
            self.tileCollection?.zoomSize = zoomSize
        }
    }
    
    @IBAction func toolSelected(_ sender: NSButton) {
        self.deselectAllTools()
        if sender == self.toolPencil {
            self.toolPencil?.state = NSControl.StateValue(rawValue: 1)
            self.tileEditor?.toolType = .pencil
        } else if sender == self.toolStraightLine {
            self.toolStraightLine?.state = NSControl.StateValue(rawValue: 1)
            self.tileEditor?.toolType = .straightLine
        } else if sender == self.toolFill {
            self.toolFill?.state = NSControl.StateValue(rawValue: 1)
            self.tileEditor?.toolType = .fillBucket
        } else if sender == self.toolBoxEmpty {
            self.toolFill?.state = NSControl.StateValue(rawValue: 1)
            self.tileEditor?.toolType = .boxEmpty
        }
    }
    
    func deselectAllTools() {
        self.toolPencil?.state = NSControl.StateValue(rawValue: 0)
        self.toolStraightLine?.state = NSControl.StateValue(rawValue: 0)
        self.toolFill?.state = NSControl.StateValue(rawValue: 0)
    }
}
