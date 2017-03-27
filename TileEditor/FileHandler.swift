//
//  FileHandler.swift
//  TileEditor
//
//  Created by iury bessa on 3/26/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

protocol FileHandler: class {
    var path: String? { get set }
    
    // fileImport will mutate the path var
    func importRaw(completion: @escaping ((_ data: Data?)->Void))
    func exportRaw(data: Data, completion: @escaping ((_ error: Error?) -> Void))
}
extension FileHandler {
    func importRaw(completion: @escaping ((_ data: Data?)->Void)) {
        let panel = NSOpenPanel()
        panel.begin { [weak self] (result: Int) in
            guard result == NSFileHandlingPanelOKButton,
                let fileLocation = panel.urls.first else {
                    NSLog("Cannot open file")
                    completion(nil)
                    return
            }
            let filePath = fileLocation.absoluteString.replacingOccurrences(of: "file://", with: "")
            self?.path = filePath
            if let dataOfFile = NSData(contentsOfFile: filePath) {
                let d = Data(bytes: dataOfFile.bytes, count: dataOfFile.length)
                completion(d)
            } else {
                completion(nil)
            }
        }
    }
    
    func exportRaw(data: Data, completion: @escaping ((_ error: Error?) -> Void)) {
        let panel = NSSavePanel()
        panel.begin { (result: Int) in
            guard result == NSFileHandlingPanelOKButton, let fileLocation = panel.url else {
                return
            }
            do {
                try data.write(to: fileLocation)
                completion(nil)
            } catch {
                completion(NSError())
            }
        }
    }
}
