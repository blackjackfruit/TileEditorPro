//
//  YKLog.swift
//  TileEditorPro
//
//  Created by iury on 5/1/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Cocoa
import XCGLogger

fileprivate let logger = XCGLogger.default

public class Log {
    let moduleName: String
    public init(moduleName: String) {
        self.moduleName = moduleName
    }
    public func d(_ input: String) {
        logger.debug(input, userInfo: ["Module": moduleName])
    }
    public func e(_ input: String) {
        logger.error(input, userInfo: ["Module": moduleName])
    }
    public func v(_ input: String) {
        logger.verbose(input, userInfo: ["Module": moduleName])
    }
    public func w(_ input: String) {
        logger.warning(input, userInfo: ["Module": moduleName])
    }
    public func i(_ input: String) {
        logger.info(input, userInfo: ["Module": moduleName])
    }
}
