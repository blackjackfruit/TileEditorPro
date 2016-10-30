//
//  PaletteSelector.swift
//  TileEditor
//
//  Created by iury bessa on 10/29/16.
//  Copyright © 2016 yellokrow. All rights reserved.
//

import Foundation
import Cocoa

protocol PaletteSelectorProtocol {
    func paletteSelectionChanged(value: UInt, paletteType: UInt)
}

class PaletteSelector: NSView {
    var paletteSelectinoDelegate: PaletteSelectorProtocol? = nil
    
    var currentPalette: UInt = 0
    var currentPaletteValue: UInt = 0
    @IBOutlet var button_one: NSButton! = nil
    @IBOutlet var button_two: NSButton! = nil
    @IBOutlet var button_three: NSButton! = nil
    @IBOutlet var button_four: NSButton! = nil
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func awakeFromNib() {
        button_one?.layer?.backgroundColor = NSColor.white.cgColor
        button_two?.layer?.backgroundColor = NSColor.lightGray.cgColor
        button_three?.layer?.backgroundColor = NSColor.gray.cgColor
        button_four?.layer?.backgroundColor = NSColor.black.cgColor
        setStateActive(button: button_one)
    }
    
    // TODO: Must move away IBAction for palette selction and use mouse events
    @IBAction func button_one(selector: AnyObject) {
        NSLog("1")
        setStateActive(button: button_one)
        resetState(button: button_two)
        resetState(button: button_three)
        resetState(button: button_four)
        currentPaletteValue = 0
        paletteSelectinoDelegate?.paletteSelectionChanged(value: currentPaletteValue, paletteType: 0)
    }
    @IBAction func button_two(selector: AnyObject) {
        NSLog("2")
        resetState(button: button_one)
        setStateActive(button: button_two)
        resetState(button: button_three)
        resetState(button: button_four)
        currentPaletteValue = 1
        paletteSelectinoDelegate?.paletteSelectionChanged(value: currentPaletteValue, paletteType: 0)
    }
    @IBAction func button_three(selector: AnyObject) {
        NSLog("3")
        resetState(button: button_one)
        resetState(button: button_two)
        setStateActive(button: button_three)
        resetState(button: button_four)
        currentPaletteValue = 2
        paletteSelectinoDelegate?.paletteSelectionChanged(value: currentPaletteValue, paletteType: 0)
    }
    @IBAction func button_four(selector: AnyObject) {
        NSLog("4")
        resetState(button: button_one)
        resetState(button: button_two)
        resetState(button: button_three)
        setStateActive(button: button_four)
        currentPaletteValue = 3
        paletteSelectinoDelegate?.paletteSelectionChanged(value: currentPaletteValue, paletteType: 0)
    }
    func setStateActive(button: NSButton) {
//        let style = NSMutableParagraphStyle()
//        style.alignment = .center
//        button.attributedTitle = NSAttributedString(string: "Selected", attributes: [ NSForegroundColorAttributeName : NSColor.red, NSParagraphStyleAttributeName : style ])
        button.title = "✅"
    }
    
    func resetState(button: NSButton) {
        button.title = ""
    }
}
