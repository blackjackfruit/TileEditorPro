//
//  FileImportersAndExporters.swift
//  TileEditor
//
//  Created by iury bessa on 3/26/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation
import TileEditor

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

enum PaletteProccessorType {
    case Nes
}
class PaletteProccessor: ImporterExporter, FileHandler {
    var path: String? = nil
    var type: PaletteProccessorType? = nil
    var paletteType: PaletteType? = nil
    
    func importObject(completion: @escaping  ((_ object: [PaletteProtocol]?, _ error: Error?)->Void)) {
        guard let paletteType = paletteType else {
            log.e("Palette Type is nil")
            completion(nil, NSError(domain: "", code: 0, userInfo:nil))
            return
        }
        _ = self.importRaw(completion: { (data: Data?) in
            guard let data = data else {
                return
            }
            let palette = PaletteFactory.generate(data: data)
            if let generatedPaletteType = palette?.0,
                let paletteProtocol = palette?.1,
                generatedPaletteType == paletteType {
                completion(paletteProtocol, nil)
                return
            }
            
            completion(nil, NSError(domain: "", code: 0, userInfo: nil))
        })
    }
    func exportObject(object: [PaletteProtocol], completion: @escaping  ((_ error: Error?) -> Void)) {
        guard let paletteType = paletteType else {
            log.e("Palette Type is nil")
            completion(NSError(domain: "", code: 0, userInfo: nil))
            return
        }
        var keys: [UInt8] = []
        object.forEach({ (palette: PaletteProtocol) in
            palette.palette.forEach({ (tuple: (key: UInt8, color: CGColor)) in
                keys.append( tuple.key )
            })
        })
        if let paletteData = PaletteFactory.convert(array: keys, type: paletteType) {
            self.exportRaw(data: paletteData, completion: { (error: Error?) in
                completion(error)
            })
        } else {
            log.e("Could not convert Palette to Data")
        }
    }
}
