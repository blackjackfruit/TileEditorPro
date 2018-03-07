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
public enum ZoomSize: Int {
    case x1 = 1
    case x2 = 2
    case x4 = 4
    case x8 = 8
    case x16 = 16
}

public protocol TileCollectionDelegate: class {
    func selected(tileCollection: TileCollection, tileNumbers: [[Int]])
}

public protocol TileCollectionProtocol {
    var selectedTiles: Set<Int> { get }
    var zoomSize: ZoomSize { get set }
    
    func configure(using tileData: TileData)
}

public class TileCollection: NSCollectionView, TileCollectionProtocol {
    public weak var tileCollectionDelegate: TileCollectionDelegate? = nil
    // Used for knowing which tiles are currently selected or when a new tile is selected will be used to deselect
    public var selectedTiles: Set<Int> = []
    public var zoomSize: ZoomSize = .x4 {
        willSet {
            self.collectionDelegate.zoomSize = newValue
        }
        didSet {
            self.update()
        }
    }
    
    var selectedTileIDs: [[Int]] = []
    var currentlySelectedTile: Int = 0
    var collectionViewSet = false
    let collectionDelegate = CollectionDelegate()
    let collectionDataSource = CollectionDataSource()
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        let nib = NSNib(nibNamed: NSNib.Name(rawValue: "TileItem"), bundle: Bundle(for: TileCollection.self))
        self.register(nib, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TileItem"))
    }
    
    public func configure(using tileData: TileData) {
        self.collectionDataSource.tileData = tileData
        
        // Must set the delegate and datasource as nil so that the call to collectionViewLayout doesn't throw an exception
        self.dataSource = nil
        self.delegate = nil
        
        self.setupColumnsAndRowsForViewer()
        self.updateTileDimensionRelativeToResizedView()
        
        self.collectionViewSet = true
        self.collectionDelegate.tileCollection = self
        self.collectionDataSource.tileCollection = self
        
        self.dataSource = collectionDataSource
        self.delegate = collectionDelegate
        
        let indexPathForSelectedTile = IndexPath(item: self.currentlySelectedTile, section: 0)
        self.collectionDelegate.collectionView(self, didSelectItemsAt: [indexPathForSelectedTile])
        
        self.updateTileDimensionRelativeToResizedView()
    }
    
    /**
     When tile data has been modified, call this function to update the graphics for the tile views within the collection
     */
    public func updateModifiedTileIDs(tileNumbers: [Int]) {
        guard let tileData = self.collectionDataSource.tileData else {
            NSLog("Cannot update tiles (\(tileNumbers)) without tile data")
            return
        }
        
        for i in tileNumbers {
            let item = self.item(at: i) as? TileItem
            item?.tileView?.matrix = tileData.matrices[i]
            item?.tileView?.needsDisplay = true
        }
    }
    
    internal func setupColumnsAndRowsForViewer() {
        guard
            let tileData = self.collectionDataSource.tileData
        else {
            NSLog("failed to get tiles from tiledata when configuring")
            return
        }
        
        // TODO: Must account for an uneven amount of items
        let numberOfColumns = 16
        let numberOfTiles = tileData.matrices.count
        let numberOfRows = numberOfTiles/numberOfColumns
        
        self.collectionDelegate.numberOfColumns = Int(numberOfColumns)
        self.collectionDelegate.numberOfRows = numberOfRows
        
        self.collectionDelegate.tileCollectionDelegate = self.tileCollectionDelegate
    }
    
    internal func updateTileDimensionRelativeToResizedView() {
        let lineSpacing:CGFloat = 0.5
        let dimesnionForTile = (self.frame.size.width/CGFloat(self.collectionDelegate.numberOfColumns))-(lineSpacing*2)
        let dimensions = NSSize(width: dimesnionForTile, height: dimesnionForTile)
        let gridLayout = NSCollectionViewGridLayout()
        gridLayout.minimumItemSize = dimensions
        gridLayout.maximumItemSize = dimensions
        
        gridLayout.minimumLineSpacing = lineSpacing
        gridLayout.minimumInteritemSpacing = lineSpacing
        
        gridLayout.maximumNumberOfColumns = self.collectionDelegate.numberOfColumns
        gridLayout.maximumNumberOfRows = self.collectionDelegate.numberOfRows
        
        self.collectionViewLayout = gridLayout
    }
    
    /**
     When updating zoomsize or the tileData, then call this to update the collection view which will then in turn call the TileCollectionDelegate's tiles(selected: [[Int]]) function.
     */
    internal func update() {
        let indexPathForSelectedTile = IndexPath(item: self.currentlySelectedTile, section: 0)
        
        self.collectionDelegate.collectionView(self, didSelectItemsAt: [indexPathForSelectedTile])
        self.reloadData()
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
    var previouslySelectedTiles: Set<Int> = []
    
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
        self.tileCollection?.selectedTiles = setOfTileSelected
        return ret
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard
            let indexPath = indexPaths.first,
            let tileCollectionDelegate = self.tileCollectionDelegate
        else {
            NSLog("WARN: didSelectItemsAt index path was zero")
            return
        }
        
        for st in self.previouslySelectedTiles {
            let item = collectionView.item(at: st) as? TileItem
            item?.setHighlight(value: false)
        }
        
        let dimension = self.zoomSize.rawValue
        let adjustedPosition = self.adjustCursorPosition(cursorPoint: indexPath, dimension: dimension)
        self.indexPathForSelectedTile = adjustedPosition
        
        let tileIDs: [[Int]] = self.setSelectableTiles(collectionView: collectionView, from: adjustedPosition, dimension: dimension)
        self.previouslySelectedTiles = Set(tileIDs.flatMap { (array: [Int]) -> [Int] in
            return array
        })
        
        if let firstTileSelected = tileIDs.first?.first {
            self.tileCollection?.currentlySelectedTile = firstTileSelected
        }
        tileCollection?.selectedTileIDs = tileIDs
        tileCollectionDelegate.selected(tileCollection: tileCollection!, tileNumbers: tileIDs)
    }
}

class CollectionDataSource: NSObject, NSCollectionViewDataSource {
    weak var tileData: TileData?
    weak var tileCollection: TileCollection?
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let tileCount = tileData?.totalNumberTiles() else {
            return 0
        }
        guard tileCount > 0 else {
            return 0
        }
        return tileCount
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TileItem"), for: indexPath)
        guard
            let tileItem = item as? TileItem,
            let tileData = self.tileData?.matrices[indexPath.item]
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
        
        tileItem.matrix = tileData
        tileItem.update()
        return tileItem
    }
}

// MARK: TileView (NSView)
class TileView: NSView {
    var dimensionOfTile: Int = 8
    var matrix: Matrix = Matrix()
    var number: Int = 0
    var isSelected = false
    
    override func draw(_ dirtyRect: NSRect) {
        let ctx = NSGraphicsContext.current?.cgContext
        var f = self.frame
        f.origin.x = 0
        f.origin.y = 0
        
        if let cgimage = self.convertTileDataToCGImage(matrix: self.matrix, dimension: self.dimensionOfTile) {
            ctx?.interpolationQuality = CGInterpolationQuality.none
            ctx?.draw(cgimage, in: f)
        }
        
        if self.isSelected {
            ctx?.setFillColor(red: 1.0, green: 0, blue: 0, alpha: 0.5)
            ctx?.addRect(f)
            ctx?.drawPath(using: .fill)
        }
    }
    
    func convertTileDataToCGImage(matrix: Matrix,
                                  dimension: Int) -> CGImage? {
        // Default colors
        let grayScalePalette = Data(bytes: [0x30,0x10,0x00,0x0F])
        
        do {
            if let defaultNESPalette = NESPalette(data: grayScalePalette) {
                let canvas = try BitmapCanvas(matrix: matrix,
                                              paletteProtocol: defaultNESPalette)
                let image = canvas.cgImage
                return image
            }
            return nil
        } catch {
            return nil
        }
    }
}

//MARK: TileItem (NSCollectionViewItem)
class TileItem: NSCollectionViewItem {
    @IBOutlet weak var tileView: TileView?
    var matrix: Matrix?
    var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.yellow.cgColor
        self.matrix = nil
        self.index = 0
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        guard let matrix = self.matrix else {
            print("Tile data is nil for TileItem")
            return
        }
        tileView?.isSelected = self.isSelected
        tileView?.number = index
        tileView?.matrix = matrix
    }
    
    override func prepareForReuse() {
        self.index = 0
        self.tileView?.isSelected = false
        self.tileView?.number = 0
        self.matrix = nil
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

protocol GraphicEditor {
    var matrix: Matrix? { get }
    init(matrix: Matrix, paletteProtocol: PaletteProtocol) throws
    
    func update(paletteProtocol: PaletteProtocol) throws
    
    func setColorID(value: Int, x: Int, y: Int) throws
    func addBox(colorIDValue: Int, startingPosition: NSPoint, endingPosition: NSPoint)
    func addLine(colorIDValue: Int, startingPosition: NSPoint, endingPosition: NSPoint)
}

class BitmapCanvas {
    private let dimensionForMatrix: NSSize
    private var colorIndexToColorID: [Int:Int] = [:]
    private var internalColoredMatrix: Matrix
    private var internalColorIDMatrix: Matrix
    private var imageRep: NSBitmapImageRep? {
        return NSBitmapImageRep(bitmapDataPlanes: nil,
                                      pixelsWide:internalColorIDMatrix.columns,
                                      pixelsHigh:internalColorIDMatrix.rows,
                                      bitsPerSample:8,
                                      samplesPerPixel:4,
                                      hasAlpha:true,
                                      isPlanar:false,
                                      colorSpaceName: NSColorSpaceName.calibratedRGB,
                                      bytesPerRow:internalColorIDMatrix.columns*4,
                                      bitsPerPixel:32)
    }
    
    var palette: PaletteProtocol
    var cgImage: CGImage? {
        guard
            let bitmapImageRep = self.imageRep
        else {
            return nil
        }
        
        let numberOfPlaces: CGFloat = 1000000
        // TODO: must remove force unwraps and merge the for loop into this loop
        var colors: [NSColor] = []
        palette.palette.forEach { (tuple: (key: Int, value: CGColor)) in
            let colorComponents = tuple.value.components!
            let red = round(colorComponents[0]*numberOfPlaces)/numberOfPlaces
            let green = round(colorComponents[1]*numberOfPlaces)/numberOfPlaces
            let blue = round(colorComponents[2]*numberOfPlaces)/numberOfPlaces
            let color = NSColor(calibratedRed: red,
                                green: green,
                                blue: blue,
                                alpha: 1.0)
            colors.append(color)
        }
        
        for row in 0..<internalColorIDMatrix.rows {
            for column in 0..<internalColorIDMatrix.columns {
                let color = colors[internalColorIDMatrix.entry(row: row, column: column)]
                bitmapImageRep.setColor(color, atX: column, y: row)
            }
        }
        
        return bitmapImageRep.cgImage
    }
    
    required init(matrix: Matrix, paletteProtocol: PaletteProtocol) throws {
        self.dimensionForMatrix = NSSize(width: matrix.columns, height: matrix.rows)
        self.internalColoredMatrix = Matrix(rows: matrix.rows, columns: matrix.columns)
        self.internalColorIDMatrix = matrix
        self.palette = paletteProtocol
        
        try self.update(paletteProtocol: paletteProtocol)
    }
    
    func updateMatrix() {
        
    }
}

// NOTE: no return value are needed because when unit testing, just check the value of the matrix for differences
extension BitmapCanvas: GraphicEditor {
    var matrix: Matrix? {
        return internalColorIDMatrix
    }
    
    func update(paletteProtocol: PaletteProtocol) throws {
        var colorIndexToColorID: [Int: Int] = [:]
        var counter = 0
        for (colorCode, _) in paletteProtocol.palette {
            colorIndexToColorID[counter] = colorCode
            counter += 1
        }
        
        for row in 0..<internalColoredMatrix.rows {
            for column in 0..<internalColoredMatrix.columns {
                let colorID = internalColorIDMatrix.entry(row: row, column: column)
                let colorCode = colorIndexToColorID[colorID]!
                
                try? self.internalColoredMatrix.setPosition(value: colorCode,
                                                           row: row,
                                                           column: column)
            }
        }
        
        self.colorIndexToColorID = colorIndexToColorID
        self.palette = paletteProtocol
    }
    
    func setColorID(value: Int, x: Int, y: Int) throws {
        do {
            try internalColorIDMatrix.setPosition(value: value, row: y, column: x)
        } catch {
            // TODO: Must handle
        }
    }
    
    func addBox(colorIDValue: Int, startingPosition: NSPoint, endingPosition: NSPoint) {
        let heightDifferenceBetweenCursorPositions = endingPosition.y - startingPosition.y
        let widthDifferenceBetweenCursorPositions = endingPosition.x - startingPosition.x
    }
    
    func addLine(colorIDValue: Int, startingPosition: NSPoint, endingPosition: NSPoint) {
        if colorIDValue >= self.palette.values.count {
            return
        }
    }
}

extension BitmapCanvas {
    fileprivate func pixelColorFromPaletteValue(_ value: Int) -> UnsafeMutablePointer<Int>? {
        if value >= self.palette.values.count {
            return nil
        }
        
        let color = self.palette.values[value]
        let ciColor = CIColor(cgColor: color)
        let pixelColor = UnsafeMutablePointer<Int>.allocate(capacity: 4)
        pixelColor[0] = Int(ciColor.red * 255.0)
        pixelColor[1] = Int(ciColor.green * 255.0)
        pixelColor[2] = Int(ciColor.blue * 255.0)
        pixelColor[3] = 255
        
        return pixelColor
    }
    
    fileprivate func paletteValueFromPixelColor(_ color: Int) -> Int {
        return 0
    }
}
