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
    
    var pixelData: [[Int]]? = nil
    var zoomSize: ZoomSize = .x4
    var tileDataFormatter: TileDataFormatter? = nil
    var tileDataType: TileDataType? = .NES
    
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
        guard let tileDataType = tileDataType else {
            NSLog("Cannot call update without specifying needed parameters")
            return
        }
        var pixelsPerTile = 0
        switch tileDataType {
        case TileDataType.NES:
            pixelsPerTile = 8
        }
        
        
        tileEditor?.numberOfPixelsPerTile = pixelsPerTile
        tileEditor?.numberOfPixelsPerView = Int(ZoomSize.x4.rawValue)
        
        fileViewer?.tiles = pixelData
        fileViewer?.numberOfPixelsPerTile = pixelsPerTile
        fileViewer?.numberOfPixelsPerView = 128
        fileViewer?.updateView(zoomSize: zoomSize)
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    override func mouseEntered(with event: NSEvent) {
        
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
        
        tileEditor?.numberOfPixelsPerView = Int(zoomSize.rawValue)
        tileEditor?.needsDisplay = true
        
        // By changing the NxN TileViewer, this will update the selection of tiles, which will call dataSelectedAtLocation(x:y:)
        fileViewer?.updateView(zoomSize: zoomSize)
    }
    //MARK: TileViewEditor Protocols
    func pixelDataChanged(pixelData: [[Int]]) {
        guard let tileViewer = fileViewer else {
            NSLog("No tile viewer set")
            return
        }
        guard let tileEditor = tileEditor else {
            NSLog("No tile editor set")
            return
        }
        guard let tiles = tileEditor.tiles else {
            NSLog("Tile data changed, but no tile array was set")
            return
        }
        
        let didUpdateViewer = tileViewer.updateFileViewerWith(tiles: tiles,
                                                              tileNumbers: [0])
 
        NSLog("\(didUpdateViewer)")
    }
    
    //MARK: FileViewer Protocols
    internal func tilesSelected(tiles: [[Int]],
                                tileNumbers: [[Int]],
                                zoomSize: ZoomSize) {
        
        tileEditor?.numberOfPixelsPerView = Int(zoomSize.rawValue)
        tileEditor?.updateEditorWith(pixelData: tiles)
        
    }
    func dataSelectedAtLocation(x: Int, y: Int) {
        guard let tileViewer = fileViewer else {
            NSLog("Tile viewer not set")
            return
        }
        let viewerPixelData = tileViewer.tiles
        var newPixelData: [[Int]] = []
        let tempNumberOfPixels = Int(zoomSize.rawValue)
        for ty in 0..<tempNumberOfPixels {
            var xArray: [Int] = []
            for tx in 0..<tempNumberOfPixels {
                //xArray.append(viewerPixelData[Int(y)+ty][Int(x)+tx])
            }
            newPixelData.append(xArray)
        }
        tileEditor?.updateEditorWith(pixelData: newPixelData)
    }
    
    //MARK: PaletteSelection
    func paletteSelectionChanged(value: Int, paletteType: Int) {
        tileEditor?.colorFromPalette = value
    }
}

