//
//  FileImportersAndExporters.swift
//  TileEditor
//
//  Created by iury bessa on 3/26/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation

protocol ImporterExporter {
    associatedtype T
    
    mutating func importObject(completion: @escaping ((_ object: T?, _ error: Error?)->Void))
    func exportObject(object: T, completion: @escaping  ((_ error: Error?) -> Void))
}

enum DataProcessorType {
    case NesRom
    case NesCHR
}
class DataProcessor: ImporterExporter, FileHandler {
    typealias T = Data
    
    var path: String? = nil
    var type: DataProcessorType? = nil
    var consoleType: ConsoleType? = nil
    
    func importObject(completion: @escaping ((_ object: Data?, _ error: Error?)->Void)) {
        self.importRaw { [weak self] (data: Data?) in
            completion(data, nil)
        }
    }
    func exportObject(object: Data, completion: @escaping ((_ error: Error?) -> Void)) {
        self.exportRaw(data: object) { (error: Error?) in
            completion(error)
        }
    }
    
    static func checkType(data: Data) -> ConsoleType {
        if data.count >= 16 {
            let subdata = data.subdata(in: 0..<3)
            let dataFormat = "NES".data(using: String.Encoding.utf8)
            
            if subdata == dataFormat {
                return .nes
            }
        }
        return .unknown
    }
}

enum PaletteProccessorType {
    case Nes
}
class PaletteProccessor: ImporterExporter, FileHandler {
    var path: String? = nil
    var type: PaletteProccessorType? = nil
    
    func importObject(completion: @escaping  ((_ object: PaletteProtocol?, _ error: Error?)->Void)) {
        
    }
    func exportObject(object: PaletteProtocol, completion: @escaping  ((_ error: Error?) -> Void)) {
        
    }
}
