//
//  ViewController.swift
//  TileEditor
//
//  Created by iury bessa on 10/28/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, TileEditorProtocol, PaletteSelectorProtocol, FileViewerProtocol {

    @IBOutlet weak var fileViewer: FileViewer?
    @IBOutlet var tileEditor: TileEditor?
    @IBOutlet weak var tileEditorSize: NSPopUpButtonCell?
    @IBOutlet var paletteSelection: PaletteSelector?
    @IBOutlet weak var tileViewerScrollView: NSScrollView?
    @IBOutlet weak var paletteGroups: PaletteOptions!
    @IBOutlet weak var colorSelection: PaletteOptions!
    
    var zoomSize: ZoomSize = .x4
    var tileData: TileData? = nil
    var tileDataType: TileDataType? = .nes
    var pixelsPerTile = 0
    var cursrorLocation: (x: Int, y: Int) = (0,0)
    var startingPosition = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paletteSelection?.paletteSelectinoDelegate = self
        tileViewerScrollView?.contentView.scroll(to: NSMakePoint(0,0))
        
        fileViewer?.delegate = self
        fileViewer?.zoomSize = .x4
        
        tileEditor?.delegate = self
        tileEditor?.colorFromPalette = paletteSelection!.currentPalette
        tileEditor?.numberOfPixelsPerTile = 8
        tileEditor?.numberOfPixelsPerView = 8
        
        //tileViewerScrollView?.backgroundColor = NSColor.clear
    }
    func update() {
        NSLog("Request to update views")
        guard let tileDataType = tileDataType, let tileData = tileData else {
            NSLog("Cannot call update without specifying needed parameters")
            NSLog("tileDataType and tileData are needed before updating")
            return
        }
        
        switch tileDataType {
            case TileDataType.nes:
                pixelsPerTile = 8
            case .none:
                NSLog("View controller did not set tile data type, thus we cannot draw anything")
                return
        }
        tileEditor?.tileData = tileData
        tileEditor?.numberOfPixelsPerTile = pixelsPerTile
        tileEditor?.numberOfPixelsPerView = Int(ZoomSize.x4.rawValue)*pixelsPerTile
        
        
        fileViewer?.tileData = tileData
        fileViewer?.numberOfPixelsPerTile = pixelsPerTile
        fileViewer?.numberOfPixelsPerView = 128
        
        fileViewer?.selectionLocationVisible = true
        fileViewer?.updateView(zoomSize: zoomSize)
    }
    
    @IBAction func tileEditorSizeChanged(_ sender: NSPopUpButtonCell) {
        switch sender.indexOfSelectedItem {
        case 0:
            zoomSize = .x1
        case 1:
            zoomSize = .x2
        case 2:
            zoomSize = .x4
        default:
            zoomSize = .x8
        }

        fileViewer?.updateView(zoomSize: zoomSize)
    }
    
    //MARK: TileViewEditor Protocols
    func pixelDataChanged(pixelData: [Int:Int]) {
        guard let tileViewer = fileViewer else {
            NSLog("No tile viewer set")
            return
        }
        
        let didUpdateViewer = tileViewer.updateFileViewerWith()
        NSLog("\(didUpdateViewer)")
    }
    
    //MARK: FileViewer Protocols
    internal func tilesSelected(tiles: [Int], startingPosition: Int, zoomSize: ZoomSize, x: Int, y: Int) {
        self.cursrorLocation.x = x
        self.cursrorLocation.y = y
        self.startingPosition = startingPosition
        
        tileEditor?.startingPosition = startingPosition
        tileEditor?.cursorLocation = (x, y)
        tileEditor?.numberOfPixelsPerView = Int(zoomSize.rawValue)*pixelsPerTile
        tileEditor?.zoomSize = zoomSize
        tileEditor?.update()
    }
    
    //MARK: PaletteSelection
    func paletteSelectionChanged(value: Int, paletteType: Int) {
        tileEditor?.colorFromPalette = value
    }
}

