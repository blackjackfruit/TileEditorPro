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
    
    var pixelData: [[Int]] = dummyData8x8
    var numberOfPixels: ZoomSize = .x1
    var tileDataFormatter: TileDataFormatter? = nil
    var tileDataType: TileDataType? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paletteSelection?.paletteSelectinoDelegate = self
        tileEditor?.delegate = self
        tileEditor?.subSetOfpixelData = pixelData
        tileEditor?.colorFromPalette = paletteSelection!.currentPalette
        tileEditor?.numberOfPixelsPerTile = 8
        tileEditor?.numberOfPixelsPerView = 8
        
        
        tileViewerScrollView?.contentView.scroll(to: NSMakePoint(0,0))
        fileViewer?.pixelData = pixelData
        fileViewer?.zoomSize = .x1
        fileViewer?.delegate = self
        
        if tileDataType != nil {
            self.update()
        }
        
        fileViewer?.updateView(zoomSize: numberOfPixels)
        
        tileViewerScrollView?.backgroundColor = NSColor.clear
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
        tileEditor?.subSetOfpixelData = pixelData
        tileEditor?.numberOfPixelsPerTile = pixelsPerTile
        tileEditor?.numberOfPixelsPerView = 32
        tileEditor?.needsDisplay = true
        
        fileViewer?.pixelData = pixelData
        fileViewer?.numberOfPixelsPerTile = pixelsPerTile
        fileViewer?.numberOfPixelsPerView = 128
        fileViewer?.needsDisplay = true
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
            numberOfPixels = .x1
        case 1:
            numberOfPixels = .x2
        case 2:
            numberOfPixels = .x4
        default:
            numberOfPixels = .x8
        }
        
        tileEditor?.numberOfPixelsPerView = Int(numberOfPixels.rawValue)
        tileEditor?.needsDisplay = true
        
        // By changing the NxN TileViewer, this will update the selection of tiles, which will call dataSelectedAtLocation(x:y:)
        fileViewer?.updateView(zoomSize: numberOfPixels)
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
        
        let didUpdateViewer = tileViewer.updateFileViewerWith(editedPixelData: tileEditor.subSetOfpixelData,
                                                              xPixelLocation: Int(tileViewer.cursorLocation.x)*8,
                                                              yPixelLocation: Int(tileViewer.cursorLocation.y)*8)
 
        NSLog("\(didUpdateViewer)")
    }
    
    //MARK: FileViewer Protocols
    internal func dataSelectedAtLocation(x: Int, y: Int) {
        guard let tileViewer = fileViewer else {
            NSLog("Tile viewer not set")
            return
        }
        let viewerPixelData = tileViewer.pixelData
        var newPixelData: [[Int]] = []
        let tempNumberOfPixels = Int(numberOfPixels.rawValue)
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

