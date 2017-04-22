//
//  TileEditorSettings.swift
//  TileEditor
//
//  Created by iury bessa on 3/23/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation
import TileEditor

public
protocol EditorViewControllerSettingsProtocol {
    var version: Int { get set }
    var zoomSize: ZoomSize { get set }
    var tileData: TileData? { get set }
    var consoleType: ConsoleType? { get }
    var isRomData: Bool { get set }
    var isCHRData: Bool { get set }
    var palettes: [PaletteProtocol]? { get set }
}

public
class EditorViewControllerSettings: NSObject, NSCoding, EditorViewControllerSettingsProtocol {
    public var version: Int = 0
    public var zoomSize: ZoomSize = .x4
    public var tileData: TileData? = nil
    public var consoleType: ConsoleType? {
        return tileData?.consoleType
    }
    public var isRomData = false
    public var isCHRData = false
    public var palettes: [PaletteProtocol]? = nil
    public var selectedPalette: Int = 0
    
    public
    override init() {
        
    }
    
    public
    static func emptyConsoleObject(consoleType: ConsoleType) -> EditorViewControllerSettings {
        let ret = EditorViewControllerSettings()
        switch consoleType {
        case .nes:
            ret.tileData = ConsoleDataFactory.generate(type: .nes)
            ret.isRomData = false
            ret.isCHRData = true
            ret.palettes = PaletteFactory.generate(type: .nes)
        }
        
        return ret
    }
    
    public
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        let version = aDecoder.decodeInteger(forKey: "Version")
        let decodedZoomSize = aDecoder.decodeInteger(forKey: "ZoomSize")
        
        guard let dataInput = aDecoder.decodeObject(forKey: "TileData") as? Data,
              let zoomsize = ZoomSize(rawValue: decodedZoomSize),
              let tileData = ConsoleDataFactory.generate(data: dataInput),
              let palettes = aDecoder.decodeObject(forKey: "Palettes") as? [PaletteProtocol] else {
            return
        }
        
        self.version = version
        self.zoomSize = zoomsize
        self.tileData = tileData.1
        self.palettes = palettes
    }
    
    public
    func encode(with aCoder: NSCoder) {
        let zoomSize = Int(self.zoomSize.rawValue)
        
        guard let tileData = self.tileData,
              let data = tileData.data
               else {
            return
        }
        
        aCoder.encode(version, forKey: "Version")
        aCoder.encode(zoomSize, forKey: "ZoomSize")
        aCoder.encode(data, forKey: "TileData")
        aCoder.encode(palettes, forKey: "Palettes")
        aCoder.encode(0, forKey: "SelectedPalette")
    }
}
