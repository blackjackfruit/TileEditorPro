//
//  Factory.swift
//  TileEditor
//
//  Created by iury bessa on 3/30/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation

protocol Factory {
    associatedtype T
    associatedtype P
    static func generate(data: Data) -> (T, P)?
    static func generate(type: T) -> P?
}

class ConsoleDataFactory: Factory {
    static func generate(data: Data) -> (ConsoleType, TileData)? {
        guard let type = checkType(data: data) else{
            return nil
        }
        let cdf = ConsoleDataFactory()
        var tiles:[Int]?
        switch type {
        case .nes:
            tiles = cdf.nesTileArray(data: data)
        case.nesROM:
            tiles = cdf.nesTileArray(data: data)
        }
        if let tiles = tiles, tiles.count > 0 {
            let tileData = TileData(tiles: tiles, type: type)
            return (type, tileData)
        }
        
        return nil
    }
    static func generate(type: ConsoleType) -> TileData? {
        let cdf = ConsoleDataFactory()
        switch type {
        case .nes, .nesROM:
            let emptyCHRData = Data(count: 8192)
            let tileArray = cdf.nesTileArray(data: emptyCHRData)
            if tileArray.count > 0 {
                return TileData(tiles: tileArray, type: .nes)
            }
        }
        return nil
    }
    static func checkType(data: Data) -> ConsoleType? {
        let numberOfBytes = data.count
        if numberOfBytes >= 3 {
            let subdata = data.subdata(in: 0..<3)
            let dataFormat = "NES".data(using: String.Encoding.utf8)
            
            if subdata == dataFormat {
                return .nesROM
            }
        }
        // The number of bytes within a CHR
        if numberOfBytes == 8192 {
            return .nes
        }
        return nil
    }
    
    func nesTileArray(data: Data) -> [Int] {
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
    internal func nesTiles(fromArray: [Int]) -> [Int]? {
        let ret = Array(fromArray[64..<fromArray.count])
        NSLog("Start processing NES file")
        NSLog("Finished processing NES file")
        return ret
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

class PaletteFactory: Factory {
    
    static func convert(array: [String], type: PaletteType) -> Data? {
        switch type {
        case .nes:
            let stringOfHexValues = array.flatMap({ $0 }).joined()
            // This is the number of bytes to save per 8 palettes. The bytesToSave should be 32
            let bytesToSave = stringOfHexValues.characters.count/2
            if bytesToSave == 32,
                let hexValues = stringOfHexValues.toHex()  {
                return Data(bytes: hexValues)
            }
        }
        return nil
    }
    
    static func generate(data: Data) -> (PaletteType, PaletteProtocol)? {
        let paletteFactory = PaletteFactory()
        if let paletteType = paletteFactory.paletteType(data: data) {
            var paletteGenerated: PaletteProtocol? = nil
            switch paletteType {
            case .nes:
                paletteGenerated = paletteFactory.nesPalette(data: data)
            }
            guard let palette = paletteGenerated else {
                return nil
            }
            return (paletteType, palette)
        }
        
        return nil
    }
    
    static func generate(type: PaletteType) -> PaletteProtocol? {
        switch type {
        case .nes:
            return NESPalette()
        }
    }
    func nesPalette(data: Data) -> PaletteProtocol {
        
        
        
        return NESPalette()
    }
    func paletteType(data: Data) -> PaletteType? {
        // Check if Data is of type NES ( 32 bytes long )
        if data.count == 32 {
            return .nes
        }
        return nil
    }
}
