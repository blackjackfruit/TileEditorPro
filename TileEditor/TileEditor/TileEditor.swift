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
protocol TileEditorProtocol: class {
    func pixelDataChanged(tileNumbers: [Int])
}

public
struct TileViewerMapper {
    let x: UInt
    let y: UInt
    let width: UInt
    let height: UInt
}

public
enum TilesPerView {
    case x1
    case x4
    case x16
}

public
enum ToolType {
    case pencil
    case line
    case boxEmpty
    case boxFilled
    case circleEmpty
    case circleFilled
    case fillBucket
}

public
class TileEditor: TileDrawer {
    internal let toolType: ToolType = .pencil
    public var zoomSize: ZoomSize = .x4
    public weak var delegate: TileEditorProtocol? = nil
    public var colorPalette: PaletteProtocol? = nil
    public var colorFromPalette: Int = 3
    public var cursorLocation: (x: Int, y: Int) = (x: 0, y: 0)
    public var startingPosition = 0
    // Should be an 8x8, 16x16, 32x32, etc. data set
    public var tileData: TileData? = nil
    public var visibleTiles: [Int] = []
    public internal(set) var tilesToDraw: [Int] = []
    public var numberOfPixelsPerTile: Int {
        guard let numberOfPixels = tileData?.consoleType.numberOfPixels() else {
            return 0
        }
        return numberOfPixels*numberOfPixels
    }
    public var dimensionInPixelsForView: Int {
        guard let numberOfPixels = tileData?.consoleType.numberOfPixels() else {
            NSLog("Number of pixels not set for the tileData type for pixel editor")
            return 0
        }
        return (self.numberOfPixelsPerTile/numberOfPixels)*zoomSize.rawValue
    }
    
    // Since the TileViewEditor is a square, we don't need to do anything different for computing x/y starting positions
    public var startingPositions: Array<CGFloat> {
        var ret = Array<CGFloat>()
        let widthPerPixel = CGFloat(frame.width/CGFloat(zoomSize.rawValue))*8
        var startLocationOfPixel: CGFloat = widthPerPixel
        for _ in 0..<zoomSize.rawValue {
            ret.append(CGFloat(startLocationOfPixel))
            startLocationOfPixel += CGFloat(widthPerPixel)
        }
        return ret
    }
    
    public
    func findTileLocation(point: NSPoint) -> TileViewerMapper {
        let positions = startingPositions
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
    
    public
    func update() {
        guard let tileData = tileData, let pixels = tileData.pixels,
            self.visibleTiles.count > 0 else {
            NSLog("ERROR: no tile data for editor")
            return
        }
        var tTiles: [Int] = []
        for i in 0..<visibleTiles.count {
            let offset = visibleTiles[i]*Int(numberOfPixelsPerTile)
            let singleTile = pixels[0+offset..<offset+(numberOfPixelsPerTile)]
            let singleTileArrayAsPixels = Array(singleTile)
            tTiles += singleTileArrayAsPixels
        }
        
        tilesToDraw = tTiles
        needsDisplay = true
    }
    
    public
    override func draw(_ dirtyRect: NSRect) {
        if let ctx = NSGraphicsContext.current()?.cgContext {
            guard tilesToDraw.count > 0 else {
                NSLog("Cannot draw view because tiles is nil")
                return
            }
            guard let numberOfPixels = tileData?.consoleType.numberOfPixels() else {
                NSLog("Number of pixels not set for the tileData type for pixel editor")
                return
            }
            ctx.setFillColor(CGColor.black)
            // swap coordinate so that 0,0 is top left corner
            ctx.translateBy(x: 0, y: self.frame.size.height)
            ctx.scaleBy(x: 1, y: -1)
            
            let widthPerPixel = frame.size.width/(CGFloat(zoomSize.rawValue*8))
            let heightPerPixel = frame.size.height/CGFloat(zoomSize.rawValue*8 )
            
            if widthPerPixel != heightPerPixel {
                NSLog("ERROR dimension (width and height) of the view are not the same.")
                return
            }
            
            var tNumberOfPixelsPerView = 0
            var xPosition = 0
            var yPosition = 0
            let numberOfBytesPerTile = 64
            var tileOffset = 0
            
            let numberOfPixelsPerViewHorizontally = self.dimensionInPixelsForView
            // Draw tiles
            for _ in 0..<zoomSize.rawValue*zoomSize.rawValue {
                if tNumberOfPixelsPerView >= numberOfPixelsPerViewHorizontally {
                    yPosition += 1
                    tNumberOfPixelsPerView = 0
                    xPosition = 0
                }
                drawTile(ctx: ctx,
                         tileData: tilesToDraw,
                         pixelsPerTile: numberOfPixels,
                         startingPosition: tileOffset,
                         pixelDimention: widthPerPixel,
                         x: xPosition,
                         y: yPosition)
                tNumberOfPixelsPerView += numberOfPixelsPerTile/numberOfPixels
                xPosition += 1
                tileOffset += numberOfBytesPerTile
            }
            
            // Draw grid
            var gridCursorX:CGFloat = 0
            var gridCursorY:CGFloat = 0
            let dimensionOfTile = widthPerPixel*CGFloat(numberOfPixels)
            for _ in 0..<Int(zoomSize.rawValue) {
                for _ in 0..<Int(zoomSize.rawValue) {
                    ctx.setFillColor(NSColor.clear.cgColor)
                    let box = CGRect(x: gridCursorX,
                                     y: gridCursorY,
                                     width: dimensionOfTile,
                                     height: dimensionOfTile)
                    ctx.addRect(box)
                    ctx.setLineWidth(0.5)
                    ctx.setStrokeColor(NSColor.black.cgColor)
                    ctx.drawPath(using: .fillStroke)
                    
                    gridCursorX += dimensionOfTile
                }
                gridCursorX = 0
                gridCursorY += dimensionOfTile
            }
        }
    }
    
    func drawTile(ctx: CGContext,
                  tileData: [Int],
                  pixelsPerTile: Int,
                  startingPosition: Int,
                  pixelDimention: CGFloat,
                  x: Int, y: Int) {
        guard let colorPalette = self.colorPalette else {
            NSLog("Color Palette not set for pixel editor")
            return
        }
            
        guard tileData.count > 0 else {
            NSLog("Pixel Editor data is empty")
            return
        }
        
        var xIndex:CGFloat = CGFloat(x)*pixelDimention*CGFloat(pixelsPerTile)
        var yIndex:CGFloat = CGFloat(y)*pixelDimention*CGFloat(pixelsPerTile)
        var indexPerPixel: Int = 0
        for _ in 0..<pixelsPerTile {
            for _ in 0..<pixelsPerTile {
                let pixel = CGRect(x: xIndex,
                                   y: yIndex,
                                   width: pixelDimention,
                                   height: pixelDimention)
                let colorAtIndex = tileData[indexPerPixel+startingPosition]
                let color: (_ : UInt8, color: CGColor) = colorPalette.palette[colorAtIndex]
                ctx.setFillColor(color.color)
                ctx.addRect(pixel)
                ctx.setLineWidth(CGFloat(0.2))
                ctx.drawPath(using: .fillStroke)
                xIndex += pixelDimention
                indexPerPixel += 1
            }
            xIndex = CGFloat(x)*pixelDimention*CGFloat(pixelsPerTile)
            yIndex += pixelDimention
        }
    }
}

// ToolType Drawing
extension TileEditor {
    public
    override func mouseDown(with event: NSEvent) {
        guard let tileData = self.tileData, tileData.pixels != nil else {
            NSLog("tileData is nil")
            return
        }
        let p = event.locationInWindow
        let point = convert(p, from: nil)
        
        if self.toolType == .pencil {
            self.clickedViewUsingPencil(position: point)
        } else {
            NSLog("Other drawing options not available")
        }
    }
    
    public
    override func mouseDragged(with event: NSEvent) {
        guard let tileData = tileData, tileData.pixels != nil else {
            NSLog("tileData is nil")
            return
        }
        let p = event.locationInWindow
        let point = convert(p, from: nil)
        
        if self.toolType == .pencil {
            self.clickedViewUsingPencil(position: point)
        } else {
            NSLog("Other drawing options not available")
        }
    }
    
    private
    func positionInTile(point: NSPoint,
                        tileStartingPositionX: CGFloat,
                        tileStartingPositionY: CGFloat,
                        tileSize: Int,
                        pixelSize: CGFloat) -> (x: Int, y: Int) {
        
        func pixelPositionsWithinArea(point: NSPoint, pixelSize: CGFloat, startingPosition: CGFloat) -> Array<CGFloat> {
            var ret = Array<CGFloat>()
            var startLocationOfPixel: CGFloat = pixelSize + CGFloat(startingPosition)
            for _ in 0..<8 {
                ret.append(CGFloat(startLocationOfPixel))
                startLocationOfPixel += CGFloat(pixelSize)
            }
            return ret
        }
        
        let positionsForX = pixelPositionsWithinArea(point: point,
                                                     pixelSize: pixelSize,
                                                     startingPosition: tileStartingPositionX)
        let positionsForY = pixelPositionsWithinArea(point: point,
                                                     pixelSize: pixelSize,
                                                     startingPosition: tileStartingPositionY)
        
        // To invert the coordinate system for Y we need to subtract the height of the view
        let yPosition = CGFloat(frame.size.height) - point.y
        //TODO: must move away from a linear search algorithm
        var xTileNumber: Int = 0
        var yTileNumber: Int = 0
        for x in 0..<tileSize {
            if point.x < positionsForX[x] {
                break
            } else {
                xTileNumber += 1
            }
        }
        for y in 0..<tileSize {
            if yPosition < positionsForY[y] {
                break
            } else {
                yTileNumber += 1
            }
        }
        
        return (x: xTileNumber, y: yTileNumber)
    }
    
    private
    func clickedViewUsingPencil(position point: NSPoint) {
        if let tileSelectedInView = cursorSelectedTile(point: point,
                                                       numberOfSelectableTilesVertically: Int(self.zoomSize.rawValue),
                                                       numberOfSelectableTilesHorizontally: Int(self.zoomSize.rawValue)) {
            // DO NOT allow the user to drag cursor off screen
            if tileSelectedInView.x >= zoomSize.rawValue || tileSelectedInView.y >= zoomSize.rawValue {
                return
            }
            
            let tileNumber = adjustedTileSelected(x: tileSelectedInView.x, y: tileSelectedInView.y)
            let widthAndHeightPerPixel = frame.size.width/CGFloat(8*self.zoomSize.rawValue)
            let positionInTileSelected = positionInTile(point: point,
                                                        tileStartingPositionX: widthAndHeightPerPixel*CGFloat(tileSelectedInView.x*8),
                                                        tileStartingPositionY: widthAndHeightPerPixel*CGFloat(tileSelectedInView.y*8),
                                                        tileSize: 8,
                                                        pixelSize: widthAndHeightPerPixel)
            
            let firstPixelInTile = (tileSelectedInView.x*64)+(tileSelectedInView.y*64*Int(self.zoomSize.rawValue))
            let pixelLocationInTile = positionInTileSelected.x+(positionInTileSelected.y*8)
            let pixelLocationInData = firstPixelInTile+pixelLocationInTile
            self.tilesToDraw[pixelLocationInData] = self.colorFromPalette
            
            let pixelOffset = (positionInTileSelected.x)+(positionInTileSelected.y*8)
            let location = tileNumber*64+pixelOffset
            self.tileData!.pixels![location] = self.colorFromPalette
            
            self.delegate?.pixelDataChanged(tileNumbers: [tileNumber])
            needsDisplay = true
        }
    }
    
    private
    func cursorSelectedTile(point: NSPoint,
                            numberOfSelectableTilesVertically: Int,
                            numberOfSelectableTilesHorizontally: Int) -> (x: Int, y: Int, width: CGFloat, height: CGFloat)? {
        guard let pixelPositions = startingPixelPositions(width: frame.size.width,
                                                          height: frame.size.height,
                                                          // the lowest number of boxes we can have horizontally is 4 (4 8x8 tiles)
            numberOfSquaresVertically: numberOfSelectableTilesVertically,
            numberOfSquaresHorizontally: numberOfSelectableTilesHorizontally) else {
                return nil
        }
        let xPosition = CGFloat(point.x)
        let yPosition = CGFloat(frame.size.height - point.y)
        //TODO: must move away from a linear search algorithm
        var xTileNumber: Int = 0
        var yTileNumber: Int = 0
        
        for x in 0..<zoomSize.rawValue {
            if xPosition < pixelPositions.x[x] {
                break
            } else {
                xTileNumber += 1
            }
        }
        for y in 0..<zoomSize.rawValue {
            if yPosition < pixelPositions.y[y] {
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
    
    private
    func adjustedTileSelected(x: Int, y: Int) -> Int {
        let offsetPerRow = self.zoomSize.rawValue
        let adjustedtileSelected = (y*offsetPerRow)+x
        if let numberOfTiles = tileData?.numberOfTiles(), visibleTiles.count < adjustedtileSelected || numberOfTiles < adjustedtileSelected {
            NSLog("Adjusted value for tile cannot be calculated. Will update Tile 0")
            return 0
        }
        return visibleTiles[adjustedtileSelected]
    }
}
