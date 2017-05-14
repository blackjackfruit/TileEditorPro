//
//  FileConverter.swift
//  TileEditor
//
//  Created by iury bessa on 11/2/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation

public
enum ConsoleRomType: Int {
    case nesROM
    case nes
}

public
enum ConsoleType: Int {
    case nes
    
    func numberOfPixels() -> Int {
        switch self {
        case .nes:
            return 8
        }
    }
}
public
enum PaletteType: Int {
    case nes
}

public
class TileData {
    private (set) public var consoleType: ConsoleType = .nes
    public var data: Data? {
        switch consoleType {
        case .nes:
            return nesTileFormat()
        }
    }
    public var header: Data? = nil
    public var pixels: [Int]? = nil
    
    public
    init(pixels: [Int], type: ConsoleType) {
        NSLog("Creating new TileData object")
        self.consoleType = type
        self.pixels = pixels
    }
    
    public
    func numberOfTiles() -> Int {
        guard let pixels = self.pixels else {
            return 0
        }
        var num = 0
        if pixels.count == 0 {
            return 0
        }
        switch consoleType {
        case .nes:
            num = pixels.count/64
            break
        }
        return num
    }
    
    // adds nes header to tile array before returning data if the file's data came from a ROM
    public
    func nesTileFormat() -> Data? {
        return formatTileDataAsNES(usingHeader: header)
    }
    
    public
    func formatTileDataAsNES(usingHeader: Data?) -> Data? {
        guard let pixels = self.pixels else {
            NSLog("Pixels is nil")
            return nil
        }
        //TODO: check if data is the right size to save
        let dataSize = pixels.count/4
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
            let rowOfBytes = pixels[startingIndexOfTile..<endingIndexOfTile]
            
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
            
        }while(endingIndexOfTile <= pixels.count)
        
        let tileData = Data(bytes: UnsafeRawPointer(v), count: dataSize)
        if usingHeader != nil {
            return usingHeader! + tileData
        }
        return tileData
    }
}
