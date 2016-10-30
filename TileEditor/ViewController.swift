//
//  ViewController.swift
//  TileEditor
//
//  Created by iury bessa on 10/28/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, TileViewEditorProtocol, PaletteSelectorProtocol, FileViewerProtocol {

    
    @IBOutlet var tileViewEditor: TileViewEditor?
    @IBOutlet weak var tileEditorSize: NSPopUpButtonCell?
    @IBOutlet var paletteSelection: PaletteSelector?
    @IBOutlet weak var tileViewerScrollView: NSScrollView?
    @IBOutlet weak var tileViewer: FileViewer?
    
    var pixelData: [[UInt]] = dummyData32x64
    var numberOfPixels: SelectionSize = .p8x8
    
    func loadFile(data: NSData) {
        NSLog("\(data)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paletteSelection?.paletteSelectinoDelegate = self
        tileViewEditor?.delegate = self
        tileViewEditor?.pixelData = pixelData
        tileViewEditor?.colorFromPalette = paletteSelection!.currentPalette
        
        tileViewerScrollView?.contentView.scroll(to: NSMakePoint(0,0))
        tileViewer?.pixelData = pixelData
        tileViewer?.selectionSize = .p8x8
        tileViewer?.delegate = self
        tileViewer?.updateView(selectionSize: numberOfPixels)
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
        tileViewer?.updateView(selectionSize: numberOfPixels)
        
        tileViewEditor?.needsDisplay = true
    }
    func pixelDataChanged(pixelData: [[UInt]]) {
        
    }
    internal func dataSelectedAtLocation(x: UInt, y: UInt) {
        var newPixelData: [[UInt]] = []
        let tempNumberOfPixels = Int(numberOfPixels.rawValue)
        for ty in 0..<tempNumberOfPixels {
            var xArray: [UInt] = []
            for tx in 0..<tempNumberOfPixels {
                xArray.append(pixelData[Int(y)+ty][Int(x)+tx])
            }
            newPixelData.append(xArray)
        }
        tileViewEditor?.updateEditorWith(pixelData: newPixelData)
    }
    func paletteSelectionChanged(value: UInt, paletteType: UInt) {
        tileViewEditor?.colorFromPalette = value
    }
}

