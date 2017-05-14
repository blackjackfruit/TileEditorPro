//
//  ConsoleDataFactory.swift
//  TileEditor
//
//  Created by iury bessa on 4/11/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation

public
class ConsoleDataFactory: Factory {
    
    public
    static func generate(data: Data) -> (ConsoleType, TileData)? {
        guard let dataTypeHeaderAndData = checkType(data: data) else{
            return nil
        }
        let consoleRomType = dataTypeHeaderAndData.consoleType
        let consoleType: ConsoleType
        let cdf = ConsoleDataFactory()
        var tiles:[Int]?
        switch consoleRomType {
        case .nes, .nesROM:
            tiles = cdf.nesTileArray(data: dataTypeHeaderAndData.data)
            consoleType = .nes
        }
        if let tiles = tiles, tiles.count > 0 {
            let tileData = TileData(pixels: tiles, type: consoleType)
            tileData.header = dataTypeHeaderAndData.header
            return (consoleType, tileData)
        }
        
        return nil
    }
    
    public
    static func generate(type: ConsoleType) -> TileData? {
        let cdf = ConsoleDataFactory()
        switch type {
        case .nes:
            let emptyCHRData = Data(count: 8192)
            let pixelArray = cdf.nesTileArray(data: emptyCHRData)
            if pixelArray.count > 0 {
                return TileData(pixels: pixelArray, type: .nes)
            }
        }
        return nil
    }
    
    public
    static func checkType(data: Data) -> (consoleType: ConsoleRomType, header: Data?, data: Data)? {
        var type: ConsoleRomType = .nes
        var ret: (header: Data?, data: Data)? = nil
        if let obj = isNesROMData(data: data) {
            type = .nesROM
            ret = obj
        } else if let obj = isNesData(data: data) {
            type = .nes
            ret = obj
        }
        
        if let ret = ret {
            return (type, ret.header, ret.data)
        }
        
        return nil
    }
    
    public
    static func isNesROMData(data: Data) -> (header: Data?, data: Data)? {
        if data.count < 16 {
            return nil
        }
        let subdata = data.subdata(in: 0..<3)
        let dataFormat = "NES".data(using: String.Encoding.utf8)
        
        if subdata != dataFormat {
            return nil
        }
        
        let romData = data.subdata(in: 16..<data.count)
        
        return (header: data.subdata(in: 0..<16), data: romData)
    }
    static func isNesData(data: Data) -> (header: Data?, data: Data)? {
        // The number of bytes within a data segment for a nes CHR is in multiples of 4096
        if data.count%4096 == 0 {
            return (nil, data)
        }
        return nil
    }
    
    public
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
    
    func nesTiles(fromArray: [Int]) -> [Int]? {
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
