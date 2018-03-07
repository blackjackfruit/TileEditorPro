//
//  FileConverter.swift
//  TileEditor
//
//  Created by iury bessa on 11/2/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation

public enum ConsoleRomType: Int {
    case nesROM
    case nes
}

public enum ConsoleType: Int {
    case nes
    
    func numberOfPixels() -> Int {
        switch self {
        case .nes:
            return 8
        }
    }
}
public enum PaletteType: Int {
    case nes
}

class MatrixBuilder {
    private var matrices: [[Matrix]]
    private let columns: Int
    private let rows: Int
    private let matrixConfiguration: Matrix
    
    init(columns: Int, rows: Int, pixelsPerMatrixColumns: Int, pixelsPerMatrixRows: Int) {
        self.matrixConfiguration = Matrix(rows: pixelsPerMatrixRows, columns: pixelsPerMatrixColumns)
        self.matrices = Array(repeating: Array(repeating: self.matrixConfiguration, count: columns),
                              count: rows)
        self.columns = columns
        self.rows = rows
        
    }
    
    func insertMatrix(column: Int, row: Int, matrix: Matrix) throws {
        guard column < self.columns || row < self.rows else {
            return
        }
        
        self.matrices[row][column] = matrix
    }
    
    func createMatrix() -> Matrix? {
        let returnMatrix = Matrix(rows: self.matrixConfiguration.rows*rows, columns: self.matrixConfiguration.columns*columns)
        
        var xPositionForMatrix = 0
        var yPositionForMatrix = 0
        
        for matricesInRow in self.matrices {
            for matrix in matricesInRow {
                // TODO: BEGIN Thread Block
                let startingXPosition = xPositionForMatrix
                let startingYPosition = yPositionForMatrix
                var xPosition = startingXPosition*self.matrixConfiguration.columns
                var yPosition = startingYPosition*self.matrixConfiguration.rows
                do {
                    // Copy the values from matrix to returnMatrix
                    for matrixRow in matrix.values {
                        for columnValue in matrixRow {
                            try returnMatrix.setPosition(value: columnValue, row: yPosition, column: xPosition)
                            xPosition += 1
                        }
                        
                        xPosition = startingXPosition*self.matrixConfiguration.columns
                        yPosition += 1
                    }
                } catch {
                    return nil
                }
                // END Thread Block
                
                xPositionForMatrix += 1
            }
            
            xPositionForMatrix = 0
            yPositionForMatrix += 1
        }
        
        return returnMatrix
    }
    
    static func convertToMatrices(fromBitmapCanvas bitmapCanvas: BitmapCanvas, matrixConfiguration: Matrix) -> [Matrix]? {
        guard
            let bitmapMatrix = bitmapCanvas.matrix,
            bitmapMatrix.columns != 0,
            matrixConfiguration.columns != 0,
            bitmapMatrix.rows != 0,
            matrixConfiguration.rows != 0,
            bitmapMatrix.columns%matrixConfiguration.columns == 0,   // Must make sure the pixels horizontally are neither over or short
            bitmapMatrix.rows%matrixConfiguration.rows == 0          // Must make sure the pixels vertically are neither over or short
        else {
            return nil
        }
        
        let pixelCountPerMatrix = matrixConfiguration.rows*matrixConfiguration.columns
        let pixelsInCanvas = bitmapMatrix.rows*bitmapMatrix.columns
        let totalNumberOfTilesInCanvas = Int(pixelsInCanvas/pixelCountPerMatrix)
        let columns = bitmapMatrix.columns
        
        let bitmapCanvasValues = bitmapMatrix.values
        var matrices: [Matrix] = []
        var xPosition = 0
        var yPosition = 0
        for _ in 0..<totalNumberOfTilesInCanvas {
            if xPosition == columns {
                xPosition = 0
                yPosition += matrixConfiguration.rows
            }
            
            var matrixValues: [Int] = Array(repeating: 0, count: matrixConfiguration.rows*matrixConfiguration.columns)
            let originalYPosition = yPosition
            var matrixValueStatingPosition = 0
            // loop through the rows and extract the specific matrix data and save in matrixValues
            for _ in 0..<matrixConfiguration.rows {
                let rowDataForBitmapCanvas = bitmapCanvasValues[yPosition]
                let matrixRowData = rowDataForBitmapCanvas[xPosition..<xPosition+matrixConfiguration.columns]
                matrixValues.replaceSubrange(matrixValueStatingPosition..<matrixValueStatingPosition+matrixConfiguration.columns,
                                             with: matrixRowData)
                matrixValueStatingPosition += matrixConfiguration.columns
                yPosition += 1
            }
            
            if let matrix = Matrix(values: matrixValues, rows: matrixConfiguration.rows, columns: matrixConfiguration.columns) {
                matrices.append(matrix)
            } else {
                return nil
            }
            
            yPosition = originalYPosition
            xPosition += matrixConfiguration.columns
        }
        
        return matrices
    }
}

public class Matrix {
    var rows = 0, columns = 0
    var values: [[Int]] = []
    var size: Int { return self.rows * self.columns }
    func entry(row: Int, column: Int) -> Int {
        if column >= self.columns || row >= self.rows || row < 0 || column < 0{
            return 0
        }
        
        return values[row][column]
    }
    
    init() {
        
    }
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        self.values = Array(repeating: Array(repeating: 0, count: columns), count: rows)
    }
    
    /**
     - values is an array of Ints representing either colorID (color palette) or colorCode (color representation for system)
     - rows number of rows
     - columns number of columns
     */
    init?(values: [Int], rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        
        if values.count != rows*columns {
            return nil
        }
        
        var matrixArray: [[Int]] = Array(repeating: Array(repeating: 0, count: columns), count: rows)
        var index = 0
        for r in 0..<rows {
            for c in 0..<columns {
                matrixArray[r][c] = values[index]
                index += 1
            }
        }
        
        self.values = matrixArray
    }
    
    @discardableResult
    func setPosition(value: Int, row: Int, column: Int) throws -> Bool {
        if column >= self.columns || row >= self.rows || row < 0 || column < 0{
            return false
        }
        
        self.values[row][column] = value
        return true
    }
}

extension Matrix: CustomStringConvertible {
    public var description: String {
        var output = ""
        for row in 0..<self.values.count {
            for column in 0..<self.values.first!.count {
                output += "\(values[row][column]) "
            }
            output += "\n"
        }
        
        return output
    }
}

public protocol TileData: class {
    // if the data has a header such as a rom
    var header: Data? { get set }
    // Individual pixels will have an integer value representing its color palette
    var matrices: [Matrix] { get set }
    var consoleType: ConsoleType { get }
    // The pixel data will be translated to a Data type to the expected format
    // If by any chance a pixel value is out of range for console type, then nil will be returned
    var consoleFormattedPixelData: Data? { get }
    
    func totalNumberTiles() -> Int
    func pixels(tileNumber: Int) -> [[Int]]?
}

public class NESTileDataCollection: TileData {
    public var consoleType: ConsoleType = .nes
    public var header: Data? = nil
    public var matrices: [Matrix]
    public var consoleFormattedPixelData: Data? {
        return nesTileFormat()
    }
    
    public init?(matrices: [Matrix]) {
        NSLog("Creating new TileData object")
        self.matrices = matrices
    }
    
    public init?(data: Data) {
        self.matrices = []
    }
    
    public func pixels(tileNumber: Int) -> [[Int]]? {
        return nil
    }
    
    public func totalNumberTiles() -> Int {
        return self.matrices.count
    }
    
    // adds nes header to tile array before returning data if the file's data came from a ROM
    public func nesTileFormat() -> Data? {
        return formatTileDataAsNES(usingHeader: self.header)
    }
    
    public func formatTileDataAsNES(usingHeader: Data?) -> Data? {
        guard let matrices = self.matrices.first else {
            return nil
        }
        //TODO: check if data is the right size to save
        let pixelCount = self.matrices.count*matrices.size
        let dataSize = pixelCount/4
        let headerSize = usingHeader?.count
        
        let allocatedSizeForPixels = UnsafeMutablePointer<UInt8>.allocate(capacity: dataSize)
        let stride = 8
        var startingIndexOfTile = 0
        var endingIndexOfTile = stride
        
        var fileOffset = 0
        var tileNumber = 0
        var numberOfRowsOfTileProcessed = 0
        
        func translateToBytes(matrix: Matrix) -> (byte1: UInt8, byte2: UInt8) {
            var byte1: UInt8 = 0
            var byte2: UInt8 = 0
            
            for r in 0..<matrix.rows {
                for c in 0..<matrix.columns {
                    let x = matrix.entry(row: r, column: c)
                    if x == 0 {
                        byte1 = byte1 << 1
                        byte2 = byte2 << 1
                    }
                    else if x == 1 {
                        byte1 = byte1 << 1
                        byte2 = byte2 << 1
                        byte2 = byte2 | 1
                    }
                    else if x == 2 {
                        byte1 = byte1 << 1
                        byte2 = byte2 << 1
                        byte1 = byte1 | 1
                    } else {
                        byte1 = byte1 << 1
                        byte2 = byte2 << 1
                        byte1 = byte1 | 1
                        byte2 = byte2 | 1
                    }
                }
                
            }
            
            return (byte1, byte2)
        }
        
        var index = 0
        repeat {
            let (byte1, byte2) = translateToBytes(matrix: self.matrices[index])
            allocatedSizeForPixels[fileOffset] = byte1
            allocatedSizeForPixels[fileOffset+8] = byte2
            index += 1
        }while(index < self.matrices.count)
        
        let tileData = Data(bytes: UnsafeRawPointer(allocatedSizeForPixels), count: dataSize)
        if usingHeader != nil {
            return usingHeader! + tileData
        }
        return tileData
    }
}
