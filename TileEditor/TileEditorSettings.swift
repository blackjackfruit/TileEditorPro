//
//  TileEditorSettings.swift
//  TileEditor
//
//  Created by iury bessa on 3/23/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation

protocol EditorViewControllerSettingsProtocol {
    var version: Int { get set }
    var zoomSize: ZoomSize { get set }
    var tileData: TileData? { get set }
    var tileDataType: TileDataType? { get set }
    var isRomData: Bool { get set }
    var isCHRData: Bool { get set }
    var palettes: [PaletteProtocol]? { get set }
}

class EditorViewControllerSettings: NSObject, NSCoding, EditorViewControllerSettingsProtocol {
    var version: Int = 0
    var zoomSize: ZoomSize = .x4
    var tileData: TileData? = nil
    var tileDataType: TileDataType? = nil
    var isRomData = false
    var isCHRData = false
    var palettes: [PaletteProtocol]? = nil
    var selectedPalette: Int = 0
    
    override init() {
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        let version = aDecoder.decodeInteger(forKey: "Version")
        let decodedZoomSize = aDecoder.decodeInteger(forKey: "ZoomSize")
        let type = aDecoder.decodeInteger(forKey: "TileDataType")
        
        guard let dataInput = aDecoder.decodeObject(forKey: "TileData") as? Data,
              let zoomsize = ZoomSize(rawValue: decodedZoomSize),
              let tileDataType = TileDataType(rawValue: type),
              let tileData = TileData(data: dataInput, type: tileDataType),
              let palettes = aDecoder.decodeObject(forKey: "Palettes") as? [PaletteProtocol] else {
            return
        }
        
        self.version = version
        self.zoomSize = zoomsize
        self.tileDataType = tileDataType
        self.tileData = tileData
        self.palettes = palettes
    }
    
    func encode(with aCoder: NSCoder) {
        let zoomSize = Int(self.zoomSize.rawValue)
        
        guard let tileData = self.tileData,
              let data = tileData.modifiedData
               else {
            return
        }
        let tileDataType = Int(tileData.type.rawValue)
        
        aCoder.encode(version, forKey: "Version")
        aCoder.encode(zoomSize, forKey: "ZoomSize")
        aCoder.encode(data, forKey: "TileData")
        aCoder.encode(tileDataType, forKey: "TileDataType")
        aCoder.encode(palettes, forKey: "Palettes")
        aCoder.encode(0, forKey: "SelectedPalette")
    }
}
