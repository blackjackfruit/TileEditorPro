//
//  NESPalette.swift
//  TileEditor
//
//  Created by iury bessa on 3/26/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation

fileprivate let kColor = "Color"
fileprivate let kKey = "Key"
fileprivate let kPalette = "Palette"

public class PaletteBox: NSObject, NSCoding {
    var key: UInt8
    var color: CGColor
    
    public init(key: UInt8, color: CGColor){
        self.key = key
        self.color = color
    }
    public convenience required init?(coder aDecoder: NSCoder) {
        guard
            let color = aDecoder.decodeObject(forKey: kColor) as? [CGFloat],
            let key = aDecoder.decodeObject(forKey: kKey) as? UInt8 else {
                self.init(key: 0, color:CGColor(red: 0, green: 0, blue: 0, alpha: 1))
                return
        }
        let r = color[0]
        let g = color[1]
        let b = color[2]
        self.init(key: key, color:CGColor(red: r, green: g, blue: b, alpha: 1))
    }
    public func encode(with aCoder: NSCoder) {
        let components = self.color.components
        let color = [components?[0], components?[1],components?[2], components?[3]]
        aCoder.encode(color, forKey: kColor)
        aCoder.encode(key, forKey: kKey)
    }
}

// A NES palette consists of four colors of the available 64
public class NESPalette: NSObject, PaletteProtocol, NSCoding {
    public var size = 4 // Number of colors in a NES tile
    private var _palette: [(key: UInt8, color: CGColor)]? = nil
    public var palette: [(key: UInt8, color: CGColor)]  {
        get {
            if let p = _palette {
                return p
            }
            var ret =  [(UInt8, CGColor)]()
            
            for _ in 0..<size {
                ret.append(randomColor())
            }
            _palette = ret
            return ret
        }
        set {
            _palette = newValue
        }
    }
    
    public override init() {
        super.init()
    }
    
    public convenience init?(data: Data) {
        guard data.count == 4,
            let color0 = NESColors[data[0]],
            let color1 = NESColors[data[1]],
            let color2 = NESColors[data[2]],
            let color3 = NESColors[data[3]] else {
            return nil
        }
        self.init()
        let palette = [(data[0], color0),
                       (data[1], color1),
                       (data[2], color2),
                       (data[3], color3)]
        self.palette = palette
    }
    
   
    // Input must have data with bytes between 00-30 and 00-0f. The number of bytes must be a multiple of 4
    // return nil if the data is not a multiple of 4 or if byte value is not of the allowable bytes
    public static func generateArrayOfPalettes(input: Data) -> [NESPalette]? {
        if input.count%4 != 0 {
            return nil
        }
        var ret: [NESPalette] = []
        var index = 0
        for _ in stride(from: 0, to: input.count, by: 4) {
            guard let nesPalette = NESPalette(data: input.subdata(in: index..<index+4)) else {
                return nil
            }
            index += 4
            ret.append(nesPalette)
        }
        
        return ret
    }
    
    func randomColor() -> (UInt8, CGColor) {
        let randomNumber = Int(arc4random_uniform(UInt32(NESColors.count)))
        
        let key = Array(NESColors.keys)[randomNumber]
        guard let color = NESColors[key] else {
            return (0, CGColor(red: 0.329411764705882, green: 0.329411764705882, blue: 0.329411764705882, alpha: 1.0))
        }
        return (key, color)
    }
    
    public convenience required init?(coder aDecoder: NSCoder) {
        self.init()
        guard let paletteBoxArray = aDecoder.decodeObject(forKey: kPalette) as? [PaletteBox] else {
            NSLog("Failed to decode the array of palettes for the NES")
            return
        }
        var palettes: [(key: UInt8, color: CGColor)] = []
        paletteBoxArray.forEach { (pb: PaletteBox) in
            palettes.append((pb.key, pb.color))
        }
        self._palette = palettes
    }
    
    public func encode(with aCoder: NSCoder) {
        var paletteBoxArray: [PaletteBox] = []
        self._palette?.forEach({ (tuple: (key: UInt8, color: CGColor)) in
            paletteBoxArray.append(PaletteBox(key: tuple.key, color: tuple.color))
        })
        aCoder.encode(paletteBoxArray, forKey: kPalette)
    }
}

public class GeneralNESColorPalette: PaletteProtocol {
    public var size: Int = 64 // All colors which the NES PPU understands
    public var palette: [(key: UInt8, color: CGColor)] = GeneralNESColorPalette.nesColors()
    public init() {  }
    static func nesColors() ->  [(key: UInt8, color: CGColor)] {
        return sortedNesColors()
    }
}

// Default colors for the available colors
// TODO: Must verify that the keys match values
fileprivate var NESColors: [UInt8: CGColor] = [
    0x00: CGColor(red: 0.329411764705882, green: 0.329411764705882, blue: 0.329411764705882, alpha: 1.0),
    0x10: CGColor(red: 0.596078431372549, green: 0.588235294117647, blue: 0.596078431372549, alpha: 1.0),
    0x20: CGColor(red: 0.925490196078431, green: 0.933333333333333, blue: 0.925490196078431, alpha: 1.0),
    0x30: CGColor(red: 0.925490196078431, green: 0.933333333333333, blue: 0.925490196078431, alpha: 1.0),
    
    0x01: CGColor(red: 0.0, green: 0.117647058823529, blue: 0.454901960784314, alpha: 1.0),
    0x11: CGColor(red: 0.0313725490196078, green: 0.298039215686275, blue: 0.768627450980392, alpha: 1.0),
    0x21: CGColor(red: 0.0, green: 0.298039215686275, blue: 0.603921568627451, alpha: 1.0),
    0x31: CGColor(red: 0.658823529411765, green: 0.8, blue: 0.925490196078431, alpha: 1.0),
    0x02: CGColor(red: 0.0313725490196078, green: 0.0627450980392157, blue: 0.564705882352941, alpha: 1.0),
    0x12: CGColor(red: 0.188235294117647, green: 0.196078431372549, blue: 0.925490196078431, alpha: 1.0),
    0x22: CGColor(red: 0.470588235294118, green: 0.486274509803922, blue: 0.925490196078431, alpha: 1.0),
    0x32: CGColor(red: 0.737254901960784, green: 0.737254901960784, blue: 0.925490196078431, alpha: 1.0),
    0x03: CGColor(red: 0.188235294117647, green: 0.0, blue: 0.533333333333333, alpha: 1.0),
    0x13: CGColor(red: 0.36078431372549, green: 0.117647058823529, blue: 0.894117647058824, alpha: 1.0),
    0x23: CGColor(red: 0.690196078431373, green: 0.384313725490196, blue: 0.925490196078431, alpha: 1.0),
    0x33: CGColor(red: 0.831372549019608, green: 0.698039215686274, blue: 0.925490196078431, alpha: 1.0),
    0x04: CGColor(red: 0.266666666666667, green: 0.0, blue: 0.392156862745098, alpha: 1.0),
    0x14: CGColor(red: 0.533333333333333, green: 0.0784313725490196, blue: 0.690196078431373, alpha: 1.0),
    0x24: CGColor(red: 0.894117647058824, green: 0.329411764705882, blue: 0.925490196078431, alpha: 1.0),
    0x34: CGColor(red: 0.925490196078431, green: 0.682352941176471, blue: 0.925490196078431, alpha: 1.0),
    0x05: CGColor(red: 0.36078431372549, green: 0.0, blue: 0.188235294117647, alpha: 1.0),
    0x15: CGColor(red: 0.627450980392157, green: 0.0784313725490196, blue: 0.392156862745098, alpha: 1.0),
    0x25: CGColor(red: 0.925490196078431, green: 0.345098039215686, blue: 0.705882352941177, alpha: 1.0),
    0x35: CGColor(red: 0.925490196078431, green: 0.682352941176471, blue: 0.831372549019608, alpha: 1.0),
    0x06: CGColor(red: 0.329411764705882, green: 0.0156862745098039, blue: 0.0, alpha: 1.0),
    0x16: CGColor(red: 0.596078431372549, green: 0.133333333333333, blue: 0.125490196078431, alpha: 1.0),
    0x26: CGColor(red: 0.925490196078431, green: 0.415686274509804, blue: 0.392156862745098, alpha: 1.0),
    0x36: CGColor(red: 0.925490196078431, green: 0.705882352941177, blue: 0.690196078431373, alpha: 1.0),
    0x07: CGColor(red: 0.235294117647059, green: 0.0941176470588235, blue: 0.0, alpha: 1.0),
    0x17: CGColor(red: 0.470588235294118, green: 0.235294117647059, blue: 0.0, alpha: 1.0),
    0x27: CGColor(red: 0.831372549019608, green: 0.533333333333333, blue: 0.125490196078431, alpha: 1.0),
    0x37: CGColor(red: 0.894117647058824, green: 0.768627450980392, blue: 0.564705882352941, alpha: 1.0),
    0x08: CGColor(red: 0.125490196078431, green: 0.164705882352941, blue: 0.0, alpha: 1.0),
    0x18: CGColor(red: 0.329411764705882, green: 0.352941176470588, blue: 0.0, alpha: 1.0),
    0x28: CGColor(red: 0.627450980392157, green: 0.666666666666667, blue: 0.0, alpha: 1.0),
    0x38: CGColor(red: 0.8, green: 0.823529411764706, blue: 0.470588235294118, alpha: 1.0),
    0x09: CGColor(red: 0.0313725490196078, green: 0.227450980392157, blue: 0.0, alpha: 1.0),
    0x19: CGColor(red: 0.156862745098039, green: 0.447058823529412, blue: 0.0, alpha: 1.0),
    0x29: CGColor(red: 0.454901960784314, green: 0.768627450980392, blue: 0.0, alpha: 1.0),
    0x39: CGColor(red: 0.705882352941177, green: 0.870588235294118, blue: 0.470588235294118, alpha: 1.0),
    0x0a: CGColor(red: 0.0, green: 0.250980392156863, blue: 0.0, alpha: 1.0),
    0x1a: CGColor(red: 0.0313725490196078, green: 0.486274509803922, blue: 0.0, alpha: 1.0),
    0x2a: CGColor(red: 0.298039215686275, green: 0.815686274509804, blue: 0.125490196078431, alpha: 1.0),
    0x3a: CGColor(red: 0.658823529411765, green: 0.886274509803922, blue: 0.564705882352941, alpha: 1.0),
    0x0b: CGColor(red: 0.0, green: 0.235294117647059, blue: 0.0, alpha: 1.0),
    0x1b: CGColor(red: 0.0, green: 0.462745098039216, blue: 0.156862745098039, alpha: 1.0),
    0x2b: CGColor(red: 0.219607843137255, green: 0.8, blue: 0.423529411764706, alpha: 1.0),
    0x3b: CGColor(red: 0.596078431372549, green: 0.886274509803922, blue: 0.705882352941177, alpha: 1.0),
    0x0c: CGColor(red: 0.0, green: 0.196078431372549, blue: 0.235294117647059, alpha: 1.0),
    0x1c: CGColor(red: 0.0, green: 0.4, blue: 0.470588235294118, alpha: 1.0),
    0x2c: CGColor(red: 0.219607843137255, green: 0.705882352941177, blue: 0.8, alpha: 1.0),
    0x3c: CGColor(red: 0.627450980392157, green: 0.83921568627451, blue: 0.894117647058824, alpha: 1.0),
    0x0d: CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
    0x1d: CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
    0x2d: CGColor(red: 0.235294117647059, green: 0.0, blue: 0.235294117647059, alpha: 1.0),
    0x3d: CGColor(red: 0.627450980392157, green: 0.635294117647059, blue: 0.627450980392157, alpha: 1.0),
    0x0e: CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
    0x1e: CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
    0x2e: CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
    0x3e: CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
    0x0f: CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
    0x1f: CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
    0x2f: CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
    0x3f: CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
]

fileprivate let nesKeyOrder: [UInt8] = [
    0x00,
    0x10,
    0x20,
    0x30,
    0x01,
    0x11,
    0x21,
    0x31,
    0x02,
    0x12,
    0x22,
    0x32,
    0x03,
    0x13,
    0x23,
    0x33,
    0x04,
    0x14,
    0x24,
    0x34,
    0x05,
    0x15,
    0x25,
    0x35,
    0x06,
    0x16,
    0x26,
    0x36,
    0x07,
    0x17,
    0x27,
    0x37,
    0x08,
    0x18,
    0x28,
    0x38,
    0x09,
    0x19,
    0x29,
    0x39,
    0x0a,
    0x1a,
    0x2a,
    0x3a,
    0x0b,
    0x1b,
    0x2b,
    0x3b,
    0x0c,
    0x1c,
    0x2c,
    0x3c,
    0x0d,
    0x1d,
    0x2d,
    0x3d,
    0x0e,
    0x1e,
    0x2e,
    0x3e,
    0x0f,
    0x1f,
    0x2f,
    0x3f
]

fileprivate func sortedNesColors() -> [(UInt8, CGColor)] {
    var ret = [(UInt8, CGColor)]()
    nesKeyOrder.forEach { (key: UInt8) in
        // TODO: Must remove force unwrap
        ret.append((key, NESColors[key]!))
    }
    
    return ret
}
