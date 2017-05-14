//
//  TileCollection.swift
//  TileEditor
//
//  Created by iury bessa on 11/20/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

//MARK: Public functions
public
enum ZoomSize: Int {
    case x1 = 1
    case x2 = 2
    case x4 = 4
    case x8 = 8
    case x16 = 16
}

public
protocol TileCollectionDelegate: class {
    func tiles(selected: [[Int]])
}

public class TileCollection: NSCollectionView {
    weak var tileData: TileData?
    // Used for knowing which tiles are currently selected or when a new tile is selected will be used to deselect
    var selectedTiles: Set<Int> = []
    var _zoomSize: ZoomSize = .x4
    var collectionViewSet = false
    let collectionDelegate = CollectionDelegate()
    let collectionDataSource = CollectionDataSource()
    
    public weak var tileCollectionDelegate: TileCollectionDelegate? = nil
    public var zoomSize: ZoomSize {
        get {
            return _zoomSize
        }
        set {
            _zoomSize = newValue
            self.collectionDelegate.zoomSize = newValue
        }
    }
    
    public func configure(tileData tiledata: TileData){
        guard
            let pixels = tiledata.pixels
        else {
            NSLog("failed to get tiles from tiledata when configuring")
            return
        }
        
        let nib = NSNib(nibNamed: "TileItem", bundle: Bundle(for: TileCollection.self))
        self.register(nib, forItemWithIdentifier: "TileItem")
        
        self.tileData = tiledata
        let numberOfColumns = 16
        let numberOfPixelsPerTile = tiledata.consoleType.numberOfPixels()*tiledata.consoleType.numberOfPixels()
        let numberOfTiles = pixels.count/numberOfPixelsPerTile
        let numberOfRows = numberOfTiles/numberOfColumns
        
        
        // Must set the delegate and datasource as nil so that the call to collectionViewLayout doesn't throw an exception
        self.dataSource = nil
        self.delegate = nil
        
        let dimesnionForTile = self.frame.size.width/CGFloat(numberOfColumns)
        let dimensions = NSSize(width: dimesnionForTile, height: dimesnionForTile)
        let gridLayout = NSCollectionViewGridLayout()
        gridLayout.minimumItemSize = dimensions
        gridLayout.maximumItemSize = dimensions
        
        gridLayout.minimumLineSpacing = 0
        gridLayout.minimumInteritemSpacing = 0.0
        gridLayout.minimumLineSpacing = 0.0
        
        gridLayout.maximumNumberOfColumns = numberOfColumns
        gridLayout.maximumNumberOfRows = numberOfRows
        
        self.collectionViewLayout = gridLayout
        collectionViewSet = true
        
        self.collectionDelegate.tileCollectionDelegate = self.tileCollectionDelegate
        self.collectionDelegate.numberOfColumns = Int(numberOfColumns)
        self.collectionDelegate.numberOfRows = numberOfRows
        self.collectionDataSource.tileData = tiledata
        
        self.collectionDelegate.tileCollection = self
        self.collectionDataSource.tileCollection = self
        
        self.dataSource = collectionDataSource
        self.delegate = collectionDelegate
    }
    /**
     When updating zoomsize or the tileData, then call this to update the collection view which will then in turn call the TileCollectionDelegate's tiles(selected: [[Int]]) function. Also calling this will reload the collection view data to display the contents
     */
    public func update() {
        let currentIndexPath = self.collectionDelegate.indexPathForSelectedTile
        self.collectionDelegate.collectionView(self, didSelectItemsAt: [currentIndexPath])
        self.reloadData()
    }
    
    /**
     When tile data has been modified, call this function to update the tiles
     */
    public func update(tileNumbers: [Int]) {
        for i in tileNumbers {
            let item = self.item(at: i) as? TileItem
            item?.tileView?.data = Array(tileData!.pixels![i*64..<i*64+64])
            item?.tileView?.needsDisplay = true
        }
    }
}

//MARK: Private functions
//MARK: Collection delegate and data source
class CollectionDelegate: NSObject, NSCollectionViewDelegate {
    weak var tileCollectionDelegate: TileCollectionDelegate?
    weak var tileCollection: TileCollection?
    
    var indexPathForSelectedTile = IndexPath(item: 0, section: 0)
    var zoomSize: ZoomSize = .x4
    var numberOfRows: Int = 0
    var numberOfColumns: Int =  0
    
    func adjustCursorPosition(cursorPoint: IndexPath, dimension: Int) -> IndexPath {
        let index = cursorPoint[1]
        
        let row = index/numberOfColumns
        let column = index-(row*numberOfColumns)
        
        var newCursorLocation: (x: Int, y: Int) = (x: 0, y: 0)
        
        let sizeOfSelectionPlusLocationOfX = dimension+column
        if sizeOfSelectionPlusLocationOfX > self.numberOfColumns {
            let tx: Int = column
            let p = Int(sizeOfSelectionPlusLocationOfX-1)
            let r = p-tx
            let deltaX = tx-r
            newCursorLocation.x = Int(deltaX)
        } else {
            newCursorLocation.x = column
        }
        
        let sizeOfSelectionPlusLocationOfY = dimension+row
        if sizeOfSelectionPlusLocationOfY > self.numberOfRows {
            let ty: Int = row
            let p = Int(sizeOfSelectionPlusLocationOfY-1)
            let r = p-ty
            let deltaY = ty-r
            newCursorLocation.y = Int(deltaY)
        } else {
            newCursorLocation.y = row
        }
        
        var i = IndexPath()
        i.append(cursorPoint[0])
        i.append((newCursorLocation.y*numberOfColumns)+(newCursorLocation.x))
        
        return i
    }
    func setSelectableTiles(collectionView: NSCollectionView, from index: IndexPath, dimension: Int) -> [[Int]] {
        let startingTileNumber = index[1]
        var ret: [[Int]] = []
        
        var setOfTileSelected = Set<Int>()
        var index = 0
        for _ in 0..<dimension {
            var row:[Int] = []
            for _ in 0..<dimension {
                let tile = index+startingTileNumber
                setOfTileSelected.insert(tile)
                
                let item = collectionView.item(at: tile) as? TileItem
                item?.setHighlight(value: true)
                item?.isSelected = true
                row.append(tile)
                index += 1
            }
            ret.append(row)
            index += numberOfColumns - dimension
        }
        tileCollection?.selectedTiles = setOfTileSelected
        return ret
    }
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {
            NSLog("WARN: didSelectItemsAt index path was zero")
            return
        }
        
        if let selectedTiles = tileCollection?.selectedTiles {
            for st in selectedTiles {
                let item = collectionView.item(at: st) as? TileItem
                item?.setHighlight(value: false)
            }
        }
        
        let dimension = self.zoomSize.rawValue
        let adjustedPosition = adjustCursorPosition(cursorPoint: indexPath, dimension: dimension)
        self.indexPathForSelectedTile = adjustedPosition
        
        let ret: [[Int]] = setSelectableTiles(collectionView: collectionView, from: adjustedPosition, dimension: dimension)
        tileCollectionDelegate?.tiles(selected: ret)
    }
}
class CollectionDataSource: NSObject, NSCollectionViewDataSource {
    weak var tileData: TileData?
    weak var tileCollection: TileCollection?
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let tileCount = tileData?.numberOfTiles() else {
            return 0
        }
        guard tileCount > 0 else {
            return 0
        }
        return tileCount
    }
    
    func getTileAsArray(tileNumber position: Int) -> [Int]? {
        guard let allTiles = tileData, let tData = allTiles.pixels else {
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
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "TileItem", for: indexPath)
        guard
            let tileItem = item as? TileItem,
            let tileData = getTileAsArray(tileNumber: indexPath.item)
        else {
            return item
        }
        
        tileItem.index = indexPath.item
        
        if let tilesSelected = self.tileCollection?.selectedTiles {
            let isTileSelected = tilesSelected.contains(indexPath.item)
            tileItem.tileView?.isSelected = isTileSelected
            tileItem.isSelected = isTileSelected
        } else {
            tileItem.tileView?.isSelected = false
            tileItem.isSelected = false
        }
        tileItem.tileData = tileData
        tileItem.update()
        return tileItem
    }
}

// MARK: TileView (NSView)
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
        
        if let cgimage = convertTileDataToCGImage(data: self.data, dimension: self.dimensionOfTile) {
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

//MARK: TileItem (NSCollectionViewItem)
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
            print("Tile data is nil for TileItem")
            return
        }
        tileView?.isSelected = self.isSelected
        tileView?.number = index
        tileView?.data = tileData
    }
    
    override func prepareForReuse() {
        self.index = 0
        self.tileView?.isSelected = false
        self.tileView?.number = 0
        self.tileData = nil
        self.isSelected = false
        self.setHighlight(value: false)
    }

    func setHighlight(value: Bool) {
        self.tileView?.isSelected = value
        self.tileView?.needsDisplay = true
    }
    func update() {
        tileView?.needsDisplay = true
    }
}
