//
//  ImportData.swift
//  TileEditorPro
//
//  Created by iury on 6/5/18.
//  Copyright © 2018 yellokrow. All rights reserved.
//

import Foundation
import YKTileEditor

enum DataProcessorType {
    case NesRom
    case NesCHR
}
class DataProcessor: ExportObject, ImportObject, FileHandler {
    typealias T = Data
    
    var path: String? = nil
    var type: DataProcessorType? = nil
    var consoleType: ConsoleType? = nil
    
    func importObject(completion: @escaping ((_ object: Data?, _ error: Error?)->Void)) {
        _ = self.importRaw { (data: Data?) in
            completion(data, nil)
        }
    }
    func exportObject(object: Data, completion: @escaping ((_ error: Error?) -> Void)) {
        self.exportRaw(data: object) { (error: Error?) in
            completion(error)
        }
    }
}
