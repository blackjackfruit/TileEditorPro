//
//  ImportPalette.swift
//  TileEditorPro
//
//  Created by iury on 6/5/18.
//  Copyright © 2018 yellokrow. All rights reserved.
//

import Foundation
import YKTileEditor

enum PaletteProccessorType {
    case Nes
}
class PaletteProccessor: ExportObject, ImportObject, FileHandler {
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
            
            if let palette = PaletteFactory.generate(data: data),
                let generatedPaletteType = palette.first?.type,
                generatedPaletteType == paletteType {
                completion(palette, nil)
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
        
        var keys: [Int] = []
        object.forEach({ (palette: PaletteProtocol) in
            palette.palette.forEach({ (tuple: (key: Int, color: CGColor)) in
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
