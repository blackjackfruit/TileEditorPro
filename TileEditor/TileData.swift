//
//  FileConverter.swift
//  TileEditor
//
//  Created by iury bessa on 11/2/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation

enum TileDataType {
    case NES
}

// Output the Data as NES, GBA, etc.
class TileDataFormatter {
    static func nesTile(data: Data) -> [Int]? {
        NSLog("Start processing NES file")
        let offset = 8
        var output: [Int] = []
        var r = 0
        let numberOfBytesInFile = data.count
        while (r < numberOfBytesInFile) {
            for i in 0..<8 {
                let channelAByte = data[r+i]
                let channelBByte = data[r+i+offset]
                let row = TileDataFormatter.returnRowOfPixelValues(channelA: channelAByte, channelB: channelBByte)
                output += row
            }
            r += 16
        }
        NSLog("Finished processing NES file")
        NSLog("Number of tiles: \(output.count)")
        return output
    }
    static func nesTile(array: [Int]) -> Data? {
        //TODO: check if data is the right size to save
        
        let capacity = array.count/4
        let v = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
        let stride = 8
        var startingIndexOfTile = 0
        var endingIndexOfTile = stride
        
        var fileOffset = 0
        var tileNumber = 0
        var numberOfRowsOfTileProcessed = 0
        repeat {
            let rowOfBytes = array[startingIndexOfTile..<endingIndexOfTile]
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
            
        }while(endingIndexOfTile < array.count)
        
        return Data(bytes: UnsafeRawPointer(v), count: 8192)
    }
    
    private static func returnRowOfPixelValues(channelA: UInt8, channelB: UInt8) -> [Int] {
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
