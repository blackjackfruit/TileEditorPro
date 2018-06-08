//
//  FileImportersAndExporters.swift
//  TileEditor
//
//  Created by iury bessa on 3/26/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation
import YKTileEditor

protocol ImportObject {
    associatedtype T
    mutating func importObject(completion: @escaping ((_ object: T?, _ error: Error?)->Void))
}

protocol ExportObject {
    associatedtype T
    func exportObject(object: T, completion: @escaping  ((_ error: Error?) -> Void))
}
