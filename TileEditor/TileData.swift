//
//  FileConverter.swift
//  TileEditor
//
//  Created by iury bessa on 11/2/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation

enum TileDataType: Int {
    case unknown
    case none
    case nes
    
    func numberOfPixels() -> Int {
        switch self {
        case .nes, .none:
            return 8
        case .unknown:
            return -1
        }
    }
}

class TileData {
    fileprivate var tilesInternal: [Int]? = nil
    fileprivate var currentTileDataType: TileDataType = .none
    fileprivate var dataInternal: Data? = nil
    
    private (set) var type: TileDataType
    var originalData: Data? = nil
    var modifiedData: Data? {
        switch type {
        case .nes:
            return nesTileFormat()
        default:
            return unknownTileFormat()
        }
    }
    var formatHeader: Data? = nil
    var tiles: [Int]? = nil
    
    init?(data: Data, type: TileDataType) {
        NSLog("Creating new TileData object")
        self.originalData = data
        self.type = type
        
        switch type {
        case .none:
            self.tiles = self.rawTiles(data: data)
        case .nes:
            formatHeader = data.subdata(in: 0..<16)
            let tArray = tileArray(data: data)
            self.tiles = self.nesTiles(fromArray: tArray)
        case .unknown:
            NSLog("Could not create TileData object")
            return nil
        }
        
        if self.tiles != nil {
            NSLog("Finished creating '\(type)' type for TileData object")
        } else {
            return nil
        }
        
    }
    func numberOfTiles() -> Int {
        guard let tiles = tiles else {
            return 0
        }
        var num = 0
        if tiles.count == 0 {
            return 0
        }
        switch type {
        case .nes:
            num = tiles.count/64
            break
        case .none:
            num = tiles.count/64
            break
        default: break
        }
        return num
    }
    internal func tileArray(data: Data) ->[Int] {
        let offset = 8
        var output: [Int] = []
        var r = 0
        let numberOfBytesInFile = data.count
        while (r < numberOfBytesInFile) {
            for i in 0..<8 {
                let channelAByte = data[r+i]
                let channelBByte = data[r+i+offset]
                let row = self.returnRowOfPixelValues(channelA: channelAByte, channelB: channelBByte)
                output += row
            }
            r += 16
        }
        return output
    }
    internal func rawTiles(data: Data) -> [Int]? {
        guard let data = originalData else {
            return nil
        }
        let output = tileArray(data: data)
        return output
    }
    internal func nesTiles(fromArray: [Int]) -> [Int]? {
        let ret = Array(fromArray[64..<fromArray.count])
        NSLog("Start processing NES file")
        NSLog("Finished processing NES file")
        return ret
    }
    internal func unknownTileFormat() -> Data? {
        return formatTileDataAsNES(usingHeader: nil)
    }
    // adds nes header to tile array before returning data
    internal func nesTileFormat() -> Data? {
        
        return formatTileDataAsNES(usingHeader: formatHeader)
    }
    
    internal func formatTileDataAsNES(usingHeader: Data?) -> Data? {
        guard let tiles = tiles else {
            NSLog("Tiles is nil")
            return nil
        }
        //TODO: check if data is the right size to save
        let dataSize = tiles.count/4
        let headerSize = usingHeader?.count
        
        let v = UnsafeMutablePointer<UInt8>.allocate(capacity: dataSize)
        let stride = 8
        var startingIndexOfTile = 0
        var endingIndexOfTile = stride
        
        var fileOffset = 0
        var tileNumber = 0
        var numberOfRowsOfTileProcessed = 0
        
        func rowToBytes(row: ArraySlice<Int>) -> (byte1: UInt8, byte2: UInt8) {
            var byte1: UInt8 = 0
            var byte2: UInt8 = 0
            
            for x in row {
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
            return (byte1, byte2)
        }
        
        repeat {
            let rowOfBytes = tiles[startingIndexOfTile..<endingIndexOfTile]
            
            let (byte1, byte2) = rowToBytes(row: rowOfBytes)
            
            v[fileOffset] = byte1
            v[fileOffset+8] = byte2
            
            if numberOfRowsOfTileProcessed == 7 {
                numberOfRowsOfTileProcessed = 0
                tileNumber += 1
                fileOffset = tileNumber * 16
            } else {
                numberOfRowsOfTileProcessed += 1
                fileOffset += 1
            }
            
            startingIndexOfTile += stride
            endingIndexOfTile += stride
            
        }while(endingIndexOfTile <= tiles.count)
        
        let tileData = Data(bytes: UnsafeRawPointer(v), count: dataSize)
        if usingHeader != nil {
            return usingHeader! + tileData
        }
        return tileData
    }
    
    private func returnRowOfPixelValues(channelA: UInt8, channelB: UInt8) -> [Int] {
        var byte: [Int] = []
        
        // Run through the bits individually
        var countDown: UInt8 = 7
        repeat {
            let channelABit = (channelA >> countDown) & 0b00000001
            let channelBBit = (channelB >> countDown) & 0b00000001
            
            if channelABit == 0 && channelBBit == 0 {
                byte.append(0)
            }
            else if channelABit == 0 && channelBBit == 1 {
                byte.append(1)
            }
            else if channelABit == 1 && channelBBit == 0 {
                byte.append(2)
            }
            else {
                byte.append(3)
            }
            
            if countDown == 0 {
                break
            }
            countDown -= 1
        } while (countDown >= 0)
        return byte
    }
}
