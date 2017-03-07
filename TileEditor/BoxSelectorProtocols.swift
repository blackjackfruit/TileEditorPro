//
//  BoxSelectorProtocols.swift
//  TileEditor
//
//  Created by iury bessa on 3/6/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation

protocol BoxSelectorDelegate {
    func selected(boxSelector: BoxSelector, palette: (number: Int, box: Int), boxSelected: (x: Int, y: Int))
}
