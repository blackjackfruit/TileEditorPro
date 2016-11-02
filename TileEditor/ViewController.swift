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
    
    var pixelData: [[UInt]] = dummyData32x64
    var numberOfPixels: SelectionSize = .p8x8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paletteSelection?.paletteSelectinoDelegate = self
        tileEditor?.delegate = self
        tileEditor?.pixelData = pixelData
        tileEditor?.colorFromPalette = paletteSelection!.currentPalette
        
        tileViewerScrollView?.contentView.scroll(to: NSMakePoint(0,0))
        fileViewer?.pixelData = pixelData
        fileViewer?.selectionSize = .p8x8
        fileViewer?.delegate = self
        fileViewer?.updateView(selectionSize: numberOfPixels)
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
            numberOfPixels = .p8x8
        case 1:
            numberOfPixels = .p16x16
        case 2:
            numberOfPixels = .p32x32
        default:
            numberOfPixels = .p8x8
        }
        // By changing the NxN TileViewer, this will update the selection of tiles, which will call dataSelectedAtLocation(x:y:)
        fileViewer?.updateView(selectionSize: numberOfPixels)
    }
    //MARK: TileViewEditor Protocols
    func pixelDataChanged(pixelData: [[UInt]]) {
        guard let tileViewer = fileViewer else {
            NSLog("No tile viewer set")
            return
        }
        guard let tileEditor = tileEditor else {
            NSLog("No tile editor set")
            return
        }
        let tempNumberOfPixels = Int(numberOfPixels.rawValue)
        let didUpdateViewer = tileViewer.updateFileViewerWith(editedPixelData: tileEditor.pixelData,
                                                              xPixelLocation: Int(tileViewer.cursorLocation.x)*8,
                                                              yPixelLocation: Int(tileViewer.cursorLocation.y)*8)
        NSLog("\(didUpdateViewer)")
    }
    
    //MARK: FileViewer Protocols
    internal func dataSelectedAtLocation(x: UInt, y: UInt) {
        guard let tileViewer = fileViewer else {
            NSLog("Tile viewer not set")
            return
        }
        let viewerPixelData = tileViewer.pixelData
        var newPixelData: [[UInt]] = []
        let tempNumberOfPixels = Int(numberOfPixels.rawValue)
        for ty in 0..<tempNumberOfPixels {
            var xArray: [UInt] = []
            for tx in 0..<tempNumberOfPixels {
                xArray.append(viewerPixelData[Int(y)+ty][Int(x)+tx])
            }
            newPixelData.append(xArray)
        }
        tileEditor?.updateEditorWith(pixelData: newPixelData)
    }
    
    //MARK: PaletteSelection
    func paletteSelectionChanged(value: UInt, paletteType: UInt) {
        tileEditor?.colorFromPalette = value
    }
}

