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

class Tile {
    // number of bits vertically and horizontally
    var size: UInt = 0
    
}

// Output the Data as NES, GBA, etc.
class TileDataFormatter {
    private var data: Data
    init(data: Data) {
        self.data = data
    }
    
    func output(to tileDataType: TileDataType,
                completion: (_ output: [[Int]]?, _ tileSize: UInt, _ status: Error?) -> ()) {
        let nesTiles = nesTile()
        completion(nesTiles, 8, nil)
    }
    
    func nesTile() -> [[Int]]? {
        NSLog("Start processing NES file")
        let offset = 8
        var output: [[Int]] = []
        var r = 0
        let numberOfBytesInFile = data.count
        while (r < numberOfBytesInFile) {
            var tile:[Int] = []
            for i in 0..<8 {
                let channelAByte = data[r+i]
                let channelBByte = data[r+i+offset]
                let row = self.returnRowOfPixelValues(channelA: channelAByte, channelB: channelBByte)
                tile += row
            }
            r += 16
            output.append(tile)
        }
        NSLog("Finished processing NES file")
        NSLog("Number of tiles: \(output.count)")
        return output
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
