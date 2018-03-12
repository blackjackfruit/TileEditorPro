//
//  ViewController.swift
//  TileViewer
//
//  Created by iury on 5/12/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Cocoa
import TileEditor

class ImportFile {
    static func file(path: String) -> Data? {
        let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        return data
    }
}

class ViewController: NSViewController, TileCollectionDelegate {

    @IBOutlet weak var tileCollection: TileCollection?
    var tileData: TileData? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if  let pathForDataFileForNes = Bundle.main.path(forResource: "DataFileForNes", ofType: nil),
            let dataFromFile = ImportFile.file(path: pathForDataFileForNes),
            let tuple = ConsoleDataFactory.generate(data: dataFromFile) {
            self.tileData = tuple
        } else {
            self.tileData = ConsoleDataFactory.generate(type: .nes)
        }
        
        guard let tileData = self.tileData else {
            return
        }
        
        tileCollection?.tileCollectionDelegate = self
        tileCollection?.configure(using: tileData)
    }
    
    func selected(tileCollection: TileCollection, tileNumbers: [[Int]]) {
        NSLog("Tiles selected \(tileNumbers)")
    }
}

