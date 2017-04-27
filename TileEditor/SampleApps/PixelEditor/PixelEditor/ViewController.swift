//
//  ViewController.swift
//  PixelEditor
//
//  Created by iury on 4/23/17.
//  Copyright © 2017 iury. All rights reserved.
//

import Cocoa
import TileEditor

class ViewController: NSViewController, BoxSelectorDelegate, TileEditorProtocol {

    @IBOutlet weak var pixelEditor: TileEditor?
    @IBOutlet weak var colorSelector: ColorSelector?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tileData = ConsoleDataFactory.generate(type: .nes)
        let palette = PaletteFactory.generate(type: .nes)![0]
        
        colorSelector?.palettes = [palette]
        colorSelector?.boxSelectorDelegate = self
        pixelEditor?.delegate = self
        pixelEditor?.colorPalette = palette
        pixelEditor?.tileData = tileData
        pixelEditor?.visibleTiles = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
        pixelEditor?.update()
    }
    
    func pixelDataChanged(tileNumbers: [Int]) {
        NSLog("\(tileNumbers)")
    }
    
    func selected(boxSelector: BoxSelector, palette: (number: Int, box: Int), boxSelected: (x: Int, y: Int)) {
        pixelEditor?.colorFromPalette = palette.box
    }
}

