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
    static func fileForEditing(path: String) throws -> TileDataFormatter? {
        if let dataOfFile = NSData(contentsOfFile: path) {
            let d = Data(bytes: dataOfFile.bytes, count: dataOfFile.length)
            return TileDataFormatter(data: d)
        }
        return nil
    }
    static func saveEditedFileTo(path: String, data: [[[UInt]]]) -> Bool{
        return true
    }
    
}
