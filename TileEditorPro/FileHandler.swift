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

@available(macOS 10.11, *)
extension FileHandler {
    func importRaw(completion: @escaping ((_ data: Data?)->Void)) {
        let panel = NSOpenPanel()
        panel.begin { [weak self] (NSModaleResponse) in
            guard NSModaleResponse.rawValue == NSFileHandlingPanelOKButton,
                let fileLocation = panel.urls.first else {
                    log.d("Cannot open file")
                    completion(nil)
                    return
            }
            
            let filePath = fileLocation.absoluteURL
            
            if let dataOfFile = NSData(contentsOf: filePath) {
                let d = Data(bytes: dataOfFile.bytes, count: dataOfFile.length)
                self?.path = filePath.absoluteString.replacingOccurrences(of: "file://", with: "")
                completion(d)
            } else {
                completion(nil)
                return
            }
        }
    }
    
    func exportRaw(data: Data, completion: @escaping ((_ error: Error?) -> Void)) {
        let panel = NSSavePanel()
        panel.begin { (NSModaleResponse) in
            guard
                NSModaleResponse.rawValue == NSFileHandlingPanelOKButton,
                let fileLocation = panel.url
            else {
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
