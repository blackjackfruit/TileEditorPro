//
//  FileConverter.swift
//  TileEditor
//
//  Created by iury bessa on 11/2/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation

enum TileDataType {
    case none
    case nes
}

class TileData {
    fileprivate var tilesInternal: [Int]? = nil
    fileprivate var currentTileDataType: TileDataType = .none
    fileprivate var dataInternal: Data? = nil
    
    var type: TileDataType {
        get {
            return currentTileDataType
        }
        set {
            if currentTileDataType != newValue {
                currentTileDataType = newValue
            }
        }
    }
    var originalData: Data? = nil
    var processedData: Data? {
        return nesTiles()
    }
    var tiles: [Int]? = nil
    
    init(data: Data) {
        NSLog("Creating new TileData object")
        self.originalData = data
        self.tiles = nesTiles()
        NSLog("Finished creating TileData object")
    }
    
    
    
    func numberOfTiles() -> Int {
        guard let data = originalData else {
            return 0
        }
        var num = 0
        if data.count == 0 {
            return 0
        }
        switch type {
        case .nes:
            num = data.count/16
            break
        case .none:
            break
        }
        return num
    }
    
    func nesTiles() -> [Int]? {
        guard let data = originalData else {
            return nil
        }
        NSLog("Start processing NES file")
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
        NSLog("Finished processing NES file")
        NSLog("Number of tiles: \(output.count)")
        return output
    }
    func nesTiles() -> Data? {
        guard let tiles = tiles else {
            NSLog("Tiles is nil")
            return nil
        }
        //TODO: check if data is the right size to save
        
        let capacity = tiles.count/4
        let v = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
        let stride = 8
        var startingIndexOfTile = 0
        var endingIndexOfTile = stride
        
        var fileOffset = 0
        var tileNumber = 0
        var numberOfRowsOfTileProcessed = 0
        repeat {
            let rowOfBytes = tiles[startingIndexOfTile..<endingIndexOfTile]
            var byte1: UInt8 = 0
            var byte2: UInt8 = 0
            
            for x in rowOfBytes {
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
            
        }while(endingIndexOfTile < tiles.count)
        
        return Data(bytes: UnsafeRawPointer(v), count: 8192)
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
