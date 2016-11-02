//
//  FileLoader.swift
//  TileEditor
//
//  Created by iury bessa on 11/1/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation

enum FileLoaderErrors: Error {
    case FileNotFound
    case DataFormatIncorrect
}

class FileLoader {
    func paletteSettings(path: NSURL) throws {
        
    }
    func projectSettings(path: NSURL) throws {
        
    }
    
    // Can be either CHR or Rom file to be opened for editing
    // If file cannot be found or data is bad, then exceptions are thrown
    // To understand how chr is organized check out https://sadistech.com/nesromtool/romdoc.html
    static func fileForEditing(path: String) throws -> [[[UInt]]]? {
        if let dataOfFile = NSData(contentsOfFile: path) {
            let fl = FileLoader()
            let d = Data(bytes: dataOfFile.bytes, count: dataOfFile.length)
            let offset = 8
            var output: [[[UInt]]] = []
            for _ in 0..<512{
                var tile:[[UInt]] = []
                for i in 0..<8*4 {
                    let channelAByte = d[i]
                    let channelBByte = d[i+offset]
                    let row = fl.returnRowOfPixelValues(channelA: channelAByte, channelB: channelBByte)
                    tile.append(row)
                }
                output.append(tile)
            }
            return output
        }
        return nil
    }
    static func saveEditedFileTo(path: String, data: [[[UInt]]]) -> Bool{
        return true
    }
    
    private func returnRowOfPixelValues(channelA: UInt8, channelB: UInt8) -> [UInt] {
        var byte: [UInt] = []
        
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
