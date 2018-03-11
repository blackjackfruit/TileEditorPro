//
//  ViewController.swift
//  PixelEditor
//
//  Created by iury on 4/23/17.
//  Copyright © 2017 iury. All rights reserved.
//

import Cocoa
import TileEditor

class ViewController: NSViewController, BoxSelectorDelegate, TileEditorDataSource {
    @IBOutlet weak var pixelEditor: TileEditor?
    @IBOutlet weak var colorSelector: ColorSelector?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tileData = ConsoleDataFactory.generate(type: .nes)
        let palette = PaletteFactory.generate(type: .nes)![0]
        
        colorSelector?.palettes = [palette]
        colorSelector?.boxSelectorDelegate = self
        pixelEditor?.datasource = self
        pixelEditor?.colorPalette = palette
        pixelEditor?.tileData = tileData
        pixelEditor?.tileIDs = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
        try? pixelEditor?.update()
    }
    
    func pixelDataChanged(tileNumbers: [Int]) {
        NSLog("\(tileNumbers)")
    }
    
    func updated(tileEditor: TileEditor, tileData: TileData, tileNumbers: [Int]) {
        
    }
    
    func selected(boxSelector: BoxSelector, palette: (number: Int, box: Int), boxSelected: (x: Int, y: Int)) {
        try? pixelEditor?.setColorFromPalette(value: palette.box)
    }
}

