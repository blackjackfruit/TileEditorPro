//
//  String+Hex.swift
//  TileEditor
//
//  Created by iury bessa on 3/31/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation

extension String {
    // String must be in the hex format, ie 00, 01, FA, Fa, fA, etc.
    func toHex() -> [UInt8]? {
        // Must make sure that there the string is poperly format ( 2, 4, 8, 16, 32, etc. string per bytes)
        if self.characters.count%2 != 0 {
            return nil
        }
        
        let numberOfBytes = self.characters.count/2
        var ret = [UInt8](repeating: 0, count: numberOfBytes)
        var index = 0
        for i in stride(from: 0, to: self.characters.count, by: 2) {
            let range = self.index(self.startIndex, offsetBy: i)..<self.index(self.startIndex, offsetBy: i+2)
            let value = UInt8(self[range], radix: 16) ?? 0
            ret[index] = value
            index += 1
        }
        return ret
    }
}
