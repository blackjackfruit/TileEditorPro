//
//  Factory.swift
//  TileEditor
//
//  Created by iury bessa on 3/30/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation

public
protocol PaletteProtocol: class {
    var size: Int { get }
    var palette: [(key: UInt8, color: CGColor)] { get set }
    var values: [CGColor] { get }
}
public
extension PaletteProtocol {
    var values: [CGColor] {
        get {
            var ret: [CGColor] = []
            palette.forEach { (set: (_ : UInt8, color: CGColor)) in
                ret.append(set.color)
            }
            return ret
        }
    }
}

public
protocol Factory {
    associatedtype T
    associatedtype P
    static func generate(data: Data) -> (T, P)?
    static func generate(type: T) -> P?
}
