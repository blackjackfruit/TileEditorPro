//
//  PaletteFactory.swift
//  TileEditor
//
//  Created by iury bessa on 4/11/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation

public
class PaletteFactory: Factory {
    public static func convert(array: [UInt8], type: PaletteType) -> Data? {
        switch type {
        case .nes:
            // This is the number of bytes to save per 8 palettes. The bytesToSave should be 32
            if array.count == 32 {
                return Data(bytes: array)
            }
        }
        return nil
    }
    
    public static func generate(data: Data) -> (PaletteType, [PaletteProtocol])? {
        let paletteFactory = PaletteFactory()
        if let paletteType = paletteFactory.paletteType(data: data) {
            var paletteGenerated: [PaletteProtocol]? = nil
            switch paletteType {
            case .nes:
                paletteGenerated = NESPalette.generateArrayOfPalettes(input: data)
            }
            guard let palette = paletteGenerated else {
                return nil
            }
            return (paletteType, palette)
        }
        
        return nil
    }
    
    public static func generate(type: PaletteType) -> [PaletteProtocol]? {
        switch type {
        case .nes:
            return [NESPalette(),NESPalette(),NESPalette(),NESPalette(),NESPalette(),NESPalette(),NESPalette(),NESPalette()]
        }
    }
    func paletteType(data: Data) -> PaletteType? {
        // Check if Data is of type NES ( 32 bytes long )
        if data.count == 32 {
            return .nes
        }
        return nil
    }
}
