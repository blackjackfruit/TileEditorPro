//
//  TileView.swift
//  TileEditor
//
//  Created by iury bessa on 10/28/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation
import QuartzCore
import Cocoa

public
protocol TileEditorDataSource: class {
    func updated(tileEditor: TileEditor, tileData: TileData, tileNumbers: [Int])
}

public
struct TileViewerMapper {
    let x: UInt
    let y: UInt
    let width: UInt
    let height: UInt
}

public enum TilesPerView {
    case x1
    case x4
    case x16
}

public enum ToolType {
    case pencil
    case straightLine
    case boxEmpty
    case boxFilled
    case circleEmpty
    case circleFilled
    case fillBucket
}

public enum TileEditorError: Error {
    case paletteValueUnavailable
    case tileIDUnavailable
    case tileDataNotConfiguredProperly
}

public class TileEditor: NSView {
    private var colorFromPalette: Int = 3
    internal var startingPositionForCursor: NSPoint = CGPoint(x: 0, y: 0)
    internal var endingPositionForCursor: NSPoint = CGPoint(x: 0, y: 0)
    // Original bitmap canvas from tile data
    internal var bitmapCanvasOriginal: GraphicEditor? = nil
    // Everytime draw is initiated for the view, then this object is the referenced object for the individual pixels of the tile data
    internal var bitmapCanvasForDrawing: BitmapCanvas? = nil
    
    // Should be an 8x8, 16x16, 32x32, etc. data set
    public var tileData: TileData?
    public weak var datasource: TileEditorDataSource?
    public var toolType: ToolType = .pencil
    public var zoomSize: ZoomSize = .x4
    public var colorPalette: PaletteProtocol?
    public var cursorLocation: (x: Int, y: Int) = (x: 0, y: 0)
    public var startingPosition = 0
    // The currently displayed tile number for that tile 
    public var tileIDs: [Int] = []
    public var lineWidthForTiles: CGFloat = 0.9
    public var lineWidthForPixels: CGFloat = 0.01
    public var pixelsPerTile: Int {
        guard let numberOfPixels = tileData?.consoleType.numberOfPixels() else {
            return 0
        }
        
        return numberOfPixels*numberOfPixels
    }
    public var dimensionForTiles: Int {
        guard let numberOfPixels = tileData?.consoleType.numberOfPixels() else {
            NSLog("Number of pixels not set for the tileData type for pixel editor")
            return 0
        }
        
        return numberOfPixels
    }
    
    // Since the TileViewEditor is a square, we don't need to do anything different for computing x/y starting positions
    var startingPositions: Array<CGFloat> {
        var ret = Array<CGFloat>()
        let widthPerPixel = CGFloat(frame.width/CGFloat(zoomSize.rawValue))*8
        var startLocationOfPixel: CGFloat = widthPerPixel
        for _ in 0..<zoomSize.rawValue {
            ret.append(CGFloat(startLocationOfPixel))
            startLocationOfPixel += CGFloat(widthPerPixel)
        }
        return ret
    }
    
    public func findTileLocation(point: NSPoint) -> TileViewerMapper {
        let positions = self.startingPositions
        let xPosition = CGFloat(point.x)
        let yPosition = CGFloat(frame.size.height - point.y)
        //TODO: must move away from a linear search algorithm
        var xTileNumber: UInt = 0
        var yTileNumber: UInt = 0
        let t = Int(zoomSize.rawValue)
        for x in 0..<t {
            if xPosition < positions[x] {
                break
            } else {
                xTileNumber += 1
            }
        }
        for y in 0..<t {
            if yPosition < positions[y] {
                break
            } else {
                yTileNumber += 1
            }
        }
        
        return TileViewerMapper(x: xTileNumber, y: yTileNumber, width: 0, height: 0)
    }
    
    public func update() throws {
        guard self.tileIDs.count > 0 else {
            NSLog("ERROR: no tile data for editor")
            throw TileEditorError.tileIDUnavailable
        }
        
        let pixelsPerTile = self.pixelsPerTile
        guard pixelsPerTile > 0 else {
            NSLog("Pixels per tile equals to 0")
            throw TileEditorError.tileDataNotConfiguredProperly
        }
        
        self.copyOriginalBitmapCanvasForDrawing()
        self.resetTilesToDraw()
    }
    
    public func setColorFromPalette(value: Int) throws {
        guard let values = self.colorPalette?.palette, value < values.count  else {
            throw TileEditorError.paletteValueUnavailable
        }
        
        colorFromPalette = value
    }
}

// MARK: Drawing function
extension TileEditor {
    fileprivate func resetTilesToDraw() {
        guard
            self.tileIDs.count > 0
        else {
            NSLog("ERROR: failed to reset tiles to draw")
            return
        }
        
        self.clearBitmapCanvas()
        
        
        needsDisplay = true
    }
    
    internal func drawTileData(ctx: CGContext) {
        guard
            let canvas = self.bitmapCanvasForDrawing,
            let image = canvas.cgImage
        else {
            return
        }
        
        ctx.draw(image, in: self.bounds)
    }
    
    internal func drawPixelGrid(ctx: CGContext) {
        guard let dimensionForTile = self.tileData?.consoleType.numberOfPixels() else {
            return
        }
        
        var gridCursorX:CGFloat = 0
        var gridCursorY:CGFloat = 0
        let dimensionsForView = Int(self.zoomSize.rawValue*dimensionForTile)
        let pixelWidthAndHeight = self.frame.width/CGFloat(dimensionsForView)
        ctx.setFillColor(NSColor.clear.cgColor)
        ctx.setLineWidth(self.lineWidthForPixels)
        for _ in 0..<dimensionsForView {
            for _ in 0..<dimensionsForView {
                let box = CGRect(x: gridCursorX,
                                 y: gridCursorY,
                                 width: pixelWidthAndHeight,
                                 height: pixelWidthAndHeight)
                ctx.addRect(box)
                ctx.setStrokeColor(NSColor.black.cgColor)
                ctx.drawPath(using: .fillStroke)
                
                gridCursorX += pixelWidthAndHeight
            }
            gridCursorX = 0
            gridCursorY += pixelWidthAndHeight
        }
    }
    
    internal func drawGrid(ctx: CGContext, widthPerPixel: CGFloat) {
        var gridCursorX:CGFloat = 0
        var gridCursorY:CGFloat = 0
        let dimensionOfTile = widthPerPixel*CGFloat(self.dimensionForTiles)
        ctx.setFillColor(NSColor.clear.cgColor)
        for _ in 0..<Int(self.zoomSize.rawValue) {
            for _ in 0..<Int(self.zoomSize.rawValue) {
                let box = CGRect(x: gridCursorX,
                                 y: gridCursorY,
                                 width: dimensionOfTile,
                                 height: dimensionOfTile)
                ctx.addRect(box)
                ctx.setLineWidth(self.lineWidthForTiles)
                ctx.setStrokeColor(NSColor.black.cgColor)
                ctx.drawPath(using: .fillStroke)
                
                gridCursorX += dimensionOfTile
            }
            gridCursorX = 0
            gridCursorY += dimensionOfTile
        }
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        if let currentContext = NSGraphicsContext.current {
            let pixelsPerTile = self.pixelsPerTile
            guard pixelsPerTile > 0 else {
                NSLog("dimension is not greater than 0")
                return
            }
            
            let ctx = currentContext.cgContext
            currentContext.imageInterpolation = NSImageInterpolation.none
            ctx.setFillColor(NSColor.purple.cgColor)
            
            let widthPerPixel = frame.size.width/(CGFloat(zoomSize.rawValue*8))
            let heightPerPixel = frame.size.height/CGFloat(zoomSize.rawValue*8 )
            
            if widthPerPixel != heightPerPixel {
                NSLog("ERROR dimension (width and height) of the view are not the same.")
                return
            }
            
            ctx.setShouldAntialias(false)
            self.drawTileData(ctx: ctx)
            self.drawPixelGrid(ctx: ctx)
            self.drawGrid(ctx: ctx, widthPerPixel: widthPerPixel)
        }
    }
}

// ToolType Drawing
extension TileEditor {
    func clearBitmapCanvas() {
        guard
            let colorPalette = self.colorPalette,
            let tileData = self.tileData,
            let tileDataVisible = NESTileDataCollection(matrices: tileData.matrices)
        else {
            NSLog("ColorPalette: \(String(describing: self.colorPalette))")
            NSLog("TileData: \(String(describing: self.tileData))")
            return
        }
        
        var xPosition = 0
        var yPosition = 0
        let matricesToDisplay: MatrixBuilder = MatrixBuilder(columns: self.zoomSize.rawValue,
                                                             rows: self.zoomSize.rawValue,
                                                             pixelsPerMatrixColumns: 8,
                                                             pixelsPerMatrixRows: 8)
        
        do {
            var counter = 0
            try self.tileIDs.forEach { (id: Int) in
                let matrix = tileData.matrices[id]
                
                try matricesToDisplay.insertMatrix(column: xPosition, row: yPosition, matrix: matrix)
                
                if xPosition == self.zoomSize.rawValue - 1 {
                    xPosition = 0
                    yPosition += 1
                } else {
                    xPosition += 1
                }
                counter += 1
            }
        } catch {
            // TODO: Must handle
        }
        
        guard let matrix = matricesToDisplay.createMatrix() else {
            // TODO: Must handle
            return
        }
        
        self.bitmapCanvasOriginal = try? BitmapCanvas(matrix: matrix, paletteProtocol: colorPalette)
        self.bitmapCanvasForDrawing = try? BitmapCanvas(matrix: matrix, paletteProtocol: colorPalette)
    }
    
    func copyOriginalBitmapCanvasForDrawing() {
        guard
            let matrix = self.bitmapCanvasOriginal?.matrix,
            let palette = self.colorPalette
        else {
            return
        }
        
        let bitmapCanvas = try? BitmapCanvas(matrix: matrix, paletteProtocol: palette)
        self.bitmapCanvasForDrawing = bitmapCanvas
    }
    
    public override func mouseDown(with event: NSEvent) {
        self.copyOriginalBitmapCanvasForDrawing()
        
        let p = event.locationInWindow
        var point = convert(p, from: nil)
        point.y = self.frame.height - point.y
        
        self.startingPositionForCursor = point
        
        // When someone just clicks on a pixel regardless of tool type update that pixel
        self.createPointUsingPencil(pointInView: point)
    }
    
    public override func mouseDragged(with event: NSEvent) {
        let p = event.locationInWindow
        var point = convert(p, from: nil)
        
        point.y = self.frame.height - point.y
        self.endingPositionForCursor = point
        
        switch self.toolType {
        case .pencil:
            self.createPointUsingPencil(pointInView: point)
        case .straightLine:
            self.createStraightLine(startingPointInView: self.startingPositionForCursor,
                                    endingPointInView: self.endingPositionForCursor)
        case .boxEmpty:
            fallthrough
        case .boxFilled:
            self.copyOriginalBitmapCanvasForDrawing()
            bitmapCanvasForDrawing?.addBox(colorIDValue: 3,
                                           startingPosition: self.startingPositionForCursor,
                                           endingPosition: self.endingPositionForCursor)
        case .circleEmpty:
            fallthrough
        case .circleFilled:
            print("None")
        default:
            NSLog("Failed")
        }
        
        needsDisplay = true
    }
    
    public override func mouseUp(with event: NSEvent) {
        guard
            let bitmapCanvas = self.bitmapCanvasForDrawing,
            let bitmapMatrix = bitmapCanvas.matrix,
            let colorPalette = self.colorPalette,
            let firstMatrixColumnCount = self.tileData?.matrices.first?.columns,
            let firstMatrixRowCount = self.tileData?.matrices.first?.rows
        else {
            return
        }
        
        // TODO: Must compare matrices to check which tiles were updated
        let matrices: [Matrix]? = MatrixBuilder.createMatrices(fromBitmapCanvas: bitmapCanvas,
                                                               matrixConfiguration: Matrix(rows: firstMatrixRowCount, columns: firstMatrixColumnCount))
        // convert the bitmap canvas matrix into [Matrix]
        if let matrices = matrices, let tileData = NESTileDataCollection(matrices: matrices) {
            self.bitmapCanvasOriginal = try? BitmapCanvas(matrix: bitmapMatrix, paletteProtocol: colorPalette)
            self.bitmapCanvasForDrawing = try? BitmapCanvas(matrix: bitmapMatrix, paletteProtocol: colorPalette)
            self.datasource?.updated(tileEditor: self, tileData: tileData, tileNumbers: self.tileIDs)
            needsDisplay = true
        }
    }
}

// MARK: ToolType
extension TileEditor {
    fileprivate func ratio() -> CGFloat {
        guard let pixels = self.tileData?.consoleType.numberOfPixels(), pixels > 0 else {
            return 0
        }
        return self.frame.width/CGFloat(self.zoomSize.rawValue*pixels)
    }
    
    fileprivate func createPointUsingPencil(pointInView: NSPoint) {
        if let bitmapCanvas = self.bitmapCanvasForDrawing {
            let xPosition = Int(pointInView.x/ratio())
            let yPosition = Int(pointInView.y/ratio())
            
            do {
                try bitmapCanvas.setColorID(value: self.colorFromPalette,
                                            x: xPosition,
                                            y: yPosition)
            } catch {
                // TODO: Must handle
            }
        }
    }
    
    fileprivate func createStraightLine(startingPointInView: NSPoint,
                                        endingPointInView: NSPoint) {
        self.copyOriginalBitmapCanvasForDrawing()
        self.bitmapCanvasForDrawing?.addLine(colorIDValue: self.colorFromPalette,
                                   startingPosition: startingPointInView,
                                   endingPosition: endingPointInView)
    }
    
    fileprivate func useFillBucket(pointInView: NSPoint) {
        
    }
}

extension TileEditor {
    func startingPixelPositions(width: CGFloat,
                                height: CGFloat,
                                numberOfSquaresVertically: Int,
                                numberOfSquaresHorizontally: Int)
        -> (x:Array<CGFloat>,y: Array<CGFloat>)? {
            let sizePerPixelVertical = CGFloat(height/CGFloat(numberOfSquaresVertically))
            
            var x = Array<CGFloat>()
            var y = Array<CGFloat>()
            
            // since pixels are a square, this value serves for both width and height
            let sizePerPixel = sizePerPixelVertical
            
            var startLocationOfPixelForHorizontal: CGFloat = sizePerPixel
            for _ in 0..<numberOfSquaresHorizontally {
                x.append(CGFloat(startLocationOfPixelForHorizontal))
                startLocationOfPixelForHorizontal += CGFloat(sizePerPixel)
            }
            if width == height {
                // If the view is a square, then no need to calculate the vertical
                return (x: x, y: x)
            }
            var startLocationOfPixelForVertical: CGFloat = sizePerPixel
            for _ in 0..<numberOfSquaresVertically {
                y.append(CGFloat(startLocationOfPixelForVertical))
                startLocationOfPixelForVertical += CGFloat(sizePerPixel)
            }
            return (x: x, y: y)
    }
    
    fileprivate func cursorSelectedTile(point: NSPoint,
                            numberOfSelectableTilesVertically: Int,
                            numberOfSelectableTilesHorizontally: Int) -> (x: Int, y: Int, width: CGFloat, height: CGFloat)? {
        guard let pixelPositions = startingPixelPositions(width: frame.size.width,
                                                          height: frame.size.height,
                                                          // the lowest number of boxes we can have horizontally is 4 (4 8x8 tiles)
            numberOfSquaresVertically: numberOfSelectableTilesVertically,
            numberOfSquaresHorizontally: numberOfSelectableTilesHorizontally) else {
                return nil
        }
        
        var xTileNumber: Int = 0
        var yTileNumber: Int = 0
        
        for x in 0..<zoomSize.rawValue {
            if point.x < pixelPositions.x[x] {
                break
            } else {
                xTileNumber += 1
            }
        }
        
        for y in 0..<zoomSize.rawValue {
            if point.y < pixelPositions.y[y] {
                break
            } else {
                yTileNumber += 1
            }
        }
        
        return (x: xTileNumber,
                y: yTileNumber,
                width: (frame.size.width/32.0)*CGFloat(8),
                height: (frame.size.width/32.0)*CGFloat(8))
    }
    
    fileprivate func adjustedTileSelected(x: Int, y: Int) -> Int? {
        guard self.tileIDs.count > 0 else {
            return nil
        }
        
        let offsetPerRow = self.zoomSize.rawValue
        let adjustedtileSelected = (y*offsetPerRow)+x
        if let numberOfTiles = self.tileData?.totalNumberTiles(), self.tileIDs.count < adjustedtileSelected || numberOfTiles < adjustedtileSelected {
            NSLog("Adjusted value for tile cannot be calculated. Will update Tile 0")
            return 0
        }
        return self.tileIDs[adjustedtileSelected]
    }
}
