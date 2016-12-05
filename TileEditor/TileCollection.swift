//
//  TileCollection.swift
//  TileEditor
//
//  Created by iury bessa on 11/20/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

enum ZoomSize: UInt {
    case x1 = 1
    case x2 = 2
    case x4 = 4
    case x8 = 8
    case x16 = 16
}

protocol TileCollectionProtocol {
    func tiles(selected: [[Int]], zoomSize: ZoomSize)
}

class TileView: NSView {
    var dimensionOfTile: Int = 8
    var data: [Int] = []
    var number: Int = 0
    var isSelected = false
    
    override func draw(_ dirtyRect: NSRect) {
        let ctx = NSGraphicsContext.current()?.cgContext
        var f = self.frame
        f.origin.x = 0
        f.origin.y = 0
        
        if let cgimage = convertTileDataToCGImage(data: data, dimension: dimensionOfTile) {
            ctx?.interpolationQuality = CGInterpolationQuality.none
            ctx?.draw(cgimage, in: f)
        }
        if isSelected {
            ctx?.setFillColor(red: 1.0, green: 0, blue: 0, alpha: 0.5)
            ctx?.addRect(f)
            ctx?.drawPath(using: .fill)
        }
    }
    
    func convertTileDataToCGImage(data: [Int],
                                  dimension: Int) -> CGImage? {
        if data.count == 0 {
            return nil
        }
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: dimension*dimension*4)
        var bufferIndex = 0
        let colors: [UInt8] = [255, 170, 85, 0]
        var index = 0
        
        for _ in 0..<dimension {
            for _ in 0..<dimension {
                buffer[bufferIndex] = UInt8(colors[data[index]])
                buffer[bufferIndex+1] = UInt8(colors[data[index]])
                buffer[bufferIndex+2] = UInt8(colors[data[index]])
                buffer[bufferIndex+3] = UInt8(255)
                bufferIndex += 4
                index += 1
            }
        }
        
        let callback: CGDataProviderReleaseDataCallback = {_,_,_ in
            
        }
        let rawPtr = UnsafeRawPointer(buffer)
        
        let provider = CGDataProvider(dataInfo: nil,
                                      data: rawPtr,
                                      size: dimension*dimension*4,
                                      releaseData: callback)
        let info = CGBitmapInfo.byteOrder16Big
        let cgImage = CGImage(width: dimension,
                              height: dimension,
                              bitsPerComponent: 8,
                              bitsPerPixel: 32,
                              bytesPerRow: dimension*4,
                              space: CGColorSpaceCreateDeviceRGB(),
                              bitmapInfo: info,
                              provider: provider!,
                              decode: nil,
                              shouldInterpolate: true,
                              intent: CGColorRenderingIntent.defaultIntent)
        
        return cgImage
    }
}

class TileItem: NSCollectionViewItem {
    
    @IBOutlet weak var tileView: TileView?
    var tileData: [Int]?
    var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.yellow.cgColor
        tileData = nil
        index = 0
    }
    override func viewWillAppear() {
        super.viewWillAppear()
        guard let tileData = self.tileData else {
            return
        }
        tileView?.isSelected = self.isSelected
        tileView?.number = index
        tileView?.data = tileData
        tileView?.needsDisplay = true
    }
    
    override func prepareForReuse() {
        index = 0
        tileData = nil
    }

    func setHighlight(value: Bool) {
        if value {
            self.view.layer?.borderWidth = 0.5
            self.view.layer?.borderColor = NSColor.red.cgColor
        } else {
            self.view.layer?.borderWidth = 0.0
        }
        tileView?.isSelected = value
        tileView?.needsDisplay = true
    }
}

class TileCollection: NSObject {
    var tileCollectionDelegate: TileCollectionProtocol? = nil
    private var numberOfColumns: Int = 0
    private var numberOfRows: Int = 0
    
    var tileData: TileData? = nil
    var dimensionOfSelectableTiles = 4
    
    // Currently selected tiles
    var selectedTiles: [Int] = []
    
    @IBOutlet weak var tileCollectionViewer: NSCollectionView?
    
    func configure(numberOfTilesHorizontally h: Int, numberOfTilesVertically: Int) {
        var numberOfTilesHorizontally = h
        guard let viewer = tileCollectionViewer else {
            NSLog("ERROR: tileCollectionViewer not set")
            return
        }
        if numberOfTilesHorizontally < 1 {
            NSLog("ERROR: Cannot specify tiles vertically to be less than or equal to 0. Using default 16")
            numberOfTilesHorizontally = 16
        } else {
            self.numberOfColumns = numberOfTilesHorizontally
        }
        
        self.numberOfRows = numberOfTilesVertically
        
        let dimensionPerTile = viewer.frame.size.width/CGFloat(numberOfTilesHorizontally)
        let dimension = NSSize(width: dimensionPerTile, height: dimensionPerTile)
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = dimension
        flowLayout.sectionInset = EdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        viewer.collectionViewLayout = nil
        viewer.collectionViewLayout = flowLayout
        
        let nib = NSNib.init(nibNamed: "TileItem", bundle: Bundle.main)
        tileCollectionViewer?.register(nib, forItemWithIdentifier: "TileItem")
        viewer.reloadData()
    }
    
    func update(tileNumbers: [Int]) {
        for i in tileNumbers {
            let item = tileCollectionViewer?.item(at: i) as? TileItem
            item?.tileView?.data = Array(tileData!.tiles![i*64..<i*64+64])
            item?.tileView?.needsDisplay = true
        }
    }
    
    func getItemStarting(at position: Int) -> [Int]? {
        guard let allTiles = tileData, let tData = allTiles.tiles else {
            NSLog("ERROR: No tile data")
            return nil
        }
        let startingLocation = position*allTiles.type.numberOfPixels()*allTiles.type.numberOfPixels()
        let sizeOfTile = allTiles.type.numberOfPixels()*allTiles.type.numberOfPixels()
        if startingLocation+sizeOfTile > allTiles.numberOfTiles()*sizeOfTile {
            NSLog("ERROR: Attempted to get item at index out of bounds")
            return nil
        }
        
        let ret = tData[startingLocation..<startingLocation+sizeOfTile]
        return Array(ret)
    }
    func tileSelection(from tileNumber: IndexPath, dimension: Int) -> IndexPath {
        let index = tileNumber[1]
        
        let row = index/numberOfColumns
        let column = index-(row*numberOfColumns)
        
        var newCursorLocation: (x: Int, y: Int) = (x: 0, y: 0)
        
        let sizeOfSelectionPlusLocationOfX = dimension+column
        if sizeOfSelectionPlusLocationOfX > numberOfColumns {
            let tx: Int = column
            let p = Int(sizeOfSelectionPlusLocationOfX-1)
            let r = p-tx
            let deltaX = tx-r
            newCursorLocation.x = Int(deltaX)
        } else {
            newCursorLocation.x = column
        }
        
        let sizeOfSelectionPlusLocationOfY = dimension+row
        if sizeOfSelectionPlusLocationOfY > numberOfRows {
            let ty: Int = row
            let p = Int(sizeOfSelectionPlusLocationOfY-1)
            let r = p-ty
            let deltaY = ty-r
            newCursorLocation.y = Int(deltaY)
        } else {
            newCursorLocation.y = row
        }
        
        var i = IndexPath()
        i.append(tileNumber[0])
        i.append((newCursorLocation.y*numberOfColumns)+(newCursorLocation.x))
        
        return i
    }
    
    func getSelectableArea(from index: IndexPath, dimension: Int) -> Set<Int> {
        
        let startingTileNumber = index[1]
        
        var ret = Set<Int>()
        var index = 0
        for _ in 0..<dimension {
            for _ in 0..<dimension {
                let tile = index+startingTileNumber
                ret.insert(tile)
                index += 1
            }
            index += numberOfColumns - dimension
        }
        return ret
    }
    
    func setHighlightedArea(startingIndex index: IndexPath, dimension: Int) -> Bool{
        guard let tcv = tileCollectionViewer else {
            return false
        }
        
        let set: Set = [index]
        self.collectionView(tcv, didSelectItemsAt: set)
        tcv.selectItems(at: set, scrollPosition: NSCollectionViewScrollPosition.top)
        return true
    }
}

extension TileCollection: NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let tileCount = tileData?.numberOfTiles() else {
            return 0
        }
        guard tileCount > 0 else {
            return 0
        }
        return tileCount
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "TileItem", for: indexPath as IndexPath) as! TileItem
        item.prepareForReuse()
        guard let tileData = getItemStarting(at: indexPath.item) else {
            return item
        }
        item.isSelected = self.selectedTiles.contains(indexPath.item)
        item.setHighlight(value: item.isSelected)
        item.index = indexPath.item
        item.tileData = tileData
        
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {
            return
        }
        let dimension = 4
        let adjustedPosition = tileSelection(from: indexPath, dimension: dimension)
        self.selectedTiles = getSelectableArea(from: adjustedPosition, dimension: dimension).sorted()
        
        var ret: [[Int]] = []
        var r = 0
        for _ in 0..<dimension {
            var row:[Int] = []
            for i in 0..<dimension  {
                let v = self.selectedTiles[i+r]
                let item = collectionView.item(at: v) as? TileItem
                item?.setHighlight(value: true)
                row.append(v)
            }
            r += dimension
            ret.append(row)
        }
        
        tileCollectionDelegate?.tiles(selected: ret, zoomSize: .x4)
    }
    func collectionView(_ collectionView: NSCollectionView,
                        didDeselectItemsAt indexPaths: Set<IndexPath>) {
        for st in selectedTiles {
            let item = collectionView.item(at: st) as? TileItem
            item?.setHighlight(value: false)
        }
    }
}
