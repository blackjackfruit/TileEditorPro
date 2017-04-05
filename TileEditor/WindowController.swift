//
//  WindowController.swift
//  TileEditor
//
//  Created by iury bessa on 3/20/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Cocoa

class MainTileEditorWindow: NSWindowController {
    
    weak var editorViewController: EditorViewController?
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        shouldCascadeWindows = true
    }
}
