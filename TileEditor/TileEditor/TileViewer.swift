//
//  TileCollection.swift
//  TileEditor
//
//  Created by iury bessa on 11/20/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

public
enum ZoomSize: Int {
    case x1 = 1
    case x2 = 2
    case x4 = 4
    case x8 = 8
    case x16 = 16
}

public
protocol TileCollectionProtocol: class {
    func tiles(tileCollection: TileCollection, selected: [[Int]])
}

public
class TileView: NSView {
    var dimensionOfTile: Int = 8
    var data: [Int] = []
    var number: Int = 0
    var isSelected = false
    
    public
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
    
    public
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

public
class TileItem: NSCollectionViewItem {
    
    @IBOutlet public weak var tileView: TileView?
    public var tileData: [Int]?
    public var index: Int = 0
    
    public
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.yellow.cgColor
        tileData = nil
        index = 0
    }
    public
    override func viewWillAppear() {
        super.viewWillAppear()
        guard let tileData = self.tileData else {
            print("Tile data is nil for TileItem")
            return
        }
        tileView?.isSelected = self.isSelected
        tileView?.number = index
        tileView?.data = tileData
        tileView?.needsDisplay = true
    }
    
    public
    override func prepareForReuse() {
        index = 0
        tileData = nil
    }

    public
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

//let numberOfColumns = 16
//let numberOfRows = (tiles.count/numberOfColumns)/(pixelsPerTile*pixelsPerTile)

public
class TileCollection: NSObject {
    public weak var tileCollectionDelegate: TileCollectionProtocol? = nil
    private var numberOfColumns: Int = 0
    private var numberOfRows: Int = 0
    internal var zoomSize: ZoomSize = .x4
    
    public weak var tileData: TileData? = nil
    public var indexPathForSelectedTile = IndexPath(item: 0, section: 0)
    
    // Currently selected tiles
    public var selectedTiles: [Int] = []
    
    @IBOutlet public weak var tileCollectionViewer: NSCollectionView?
    
    public
    func update() {
        guard let viewer = tileCollectionViewer else {
            NSLog("ERROR: tileCollectionViewer not set")
            return
        }
        guard let tileData = tileData, let tiles = tileData.tiles else {
            
            return
        }
        let numberOfColumns = 16
        let pixelsPerTile = tileData.consoleType.numberOfPixels()
        self.numberOfRows = (tiles.count/32)/(pixelsPerTile*pixelsPerTile)
        self.numberOfColumns = numberOfColumns
        
        // Let's not set up the collectionViewLayout to flow layout if it's already a flow layout
        if (viewer.collectionViewLayout is NSCollectionViewFlowLayout) == false {
            let dimensionPerTile = viewer.frame.size.width/CGFloat(numberOfRows)
            let dimension = NSSize(width: dimensionPerTile, height: dimensionPerTile)
            let flowLayout = NSCollectionViewFlowLayout()
            flowLayout.itemSize = dimension
            flowLayout.sectionInset = EdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            flowLayout.minimumInteritemSpacing = 0.0
            flowLayout.minimumLineSpacing = 0.0
            viewer.collectionViewLayout = flowLayout
        }
        
        let nib = NSNib(nibNamed: "TileItem", bundle: Bundle(for: TileView.self))
        viewer.register(nib, forItemWithIdentifier: "TileItem")
        viewer.reloadData()
    }
    
    public
    func update(tileNumbers: [Int]) {
        for i in tileNumbers {
            let item = self.tileCollectionViewer?.item(at: i) as? TileItem
            item?.tileView?.data = Array(tileData!.tiles![i*64..<i*64+64])
            item?.tileView?.needsDisplay = true
        }
    }
    
    public
    func getItemStarting(at position: Int) -> [Int]? {
        guard let allTiles = tileData, let tData = allTiles.tiles else {
            NSLog("ERROR: No tile data")
            return nil
        }
        let startingLocation = position*allTiles.consoleType.numberOfPixels()*allTiles.consoleType.numberOfPixels()
        let sizeOfTile = allTiles.consoleType.numberOfPixels()*allTiles.consoleType.numberOfPixels()
        if startingLocation+sizeOfTile > allTiles.numberOfTiles()*sizeOfTile {
            NSLog("ERROR: Attempted to get item at index out of bounds")
            return nil
        }
        var endingLocation = 0
        if startingLocation+sizeOfTile > tData.count {
            endingLocation = startingLocation
        }else {
            endingLocation = startingLocation+sizeOfTile
        }
        let ret = tData[startingLocation..<endingLocation]
        return Array(ret)
    }
    public
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
    
    public
    func setSelectableTiles(collectionView: NSCollectionView, from index: IndexPath, dimension: Int) -> [[Int]] {
        
        let startingTileNumber = index[1]
        var ret: [[Int]] = []
        
        var set = Set<Int>()
        var index = 0
        for _ in 0..<dimension {
            var row:[Int] = []
            for _ in 0..<dimension {
                let tile = index+startingTileNumber
                set.insert(tile)
                
                let item = collectionView.item(at: tile) as? TileItem
                item?.setHighlight(value: true)
                row.append(tile)
                index += 1
            }
            ret.append(row)
            index += numberOfColumns - dimension
        }
        self.selectedTiles = set.sorted()
        return ret
    }
    
    public
    func setHighlightedArea(zoomSize: ZoomSize) -> Bool{
        guard let tcv = self.tileCollectionViewer else {
            NSLog("WARN: tileCollectionViewer is nil")
            return false
        }
        self.zoomSize = zoomSize
        let set: Set = [indexPathForSelectedTile]
        self.collectionView(tcv, didSelectItemsAt: set)
        tcv.selectItems(at: set, scrollPosition: NSCollectionViewScrollPosition.top)
        return true
    }
}

extension TileCollection: NSCollectionViewDelegate, NSCollectionViewDataSource {
    public
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let tileCount = tileData?.numberOfTiles() else {
            return 0
        }
        guard tileCount > 0 else {
            return 0
        }
        return tileCount
    }
    
    public
    func collectionView(_ collectionView: NSCollectionView,
                        itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let i = collectionView.makeItem(withIdentifier: "TileItem", for: indexPath as IndexPath)
        let item = i as! TileItem
        item.prepareForReuse()
        guard let tileData = getItemStarting(at: indexPath.item) else {
            NSLog("WANR: item starting at index failed. returning empty TileItem")
            return item
        }
        item.isSelected = self.selectedTiles.contains(indexPath.item)
        item.setHighlight(value: item.isSelected)
        item.index = indexPath.item
        item.tileData = tileData
        
        return item
    }
    
    public
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {
            NSLog("WARN: didSelectItemsAt index path was zero")
            return
        }
        for st in self.selectedTiles {
            let item = collectionView.item(at: st) as? TileItem
            item?.setHighlight(value: false)
        }
        
        let dimension = self.zoomSize.rawValue
        let adjustedPosition = tileSelection(from: indexPath, dimension: dimension)
        self.indexPathForSelectedTile = adjustedPosition
        let ret: [[Int]]  = setSelectableTiles(collectionView: collectionView, from: adjustedPosition, dimension: dimension)
        
        tileCollectionDelegate?.tiles(tileCollection: self, selected: ret)
    }
    
    public
    func collectionView(_ collectionView: NSCollectionView,
                        didDeselectItemsAt indexPaths: Set<IndexPath>) {
        
    }
}
