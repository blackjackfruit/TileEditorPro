//
//  NESPalette.swift
//  TileEditor
//
//  Created by iury bessa on 3/26/17.
//  Copyright © 2017 yellokrow. All rights reserved.
//

import Foundation

protocol PaletteProtocol: class {
    var size: Int { get set }
    var palette: [(key: String, color: CGColor)] { get set }
    var values: [CGColor] { get }
}
extension PaletteProtocol {
    
    var values: [CGColor] {
        get {
            var ret: [CGColor] = []
            palette.forEach { (set: (_ : String, color: CGColor)) in
                ret.append(set.color)
            }
            return ret
        }
    }
}

class NESPalette: PaletteProtocol {
    var size = 4
    fileprivate var _palette: [(key: String, color: CGColor)]? = nil
    var palette: [(key: String, color: CGColor)]  {
        get {
            if let p = _palette {
                return p
            }
            var ret =  [(String, CGColor)]()
            
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
    
    init() {
    }
    
    func randomColor() -> (String, CGColor) {
        let randomNumber = Int(arc4random_uniform(UInt32(NESColors.count)))
        
        return NESColors[randomNumber]
    }
}

// Default colors for the available colors
// TODO: Must verify that the keys match values
var NESColors = [
    ("00", CGColor(red: 0.329411764705882, green: 0.329411764705882, blue: 0.329411764705882, alpha: 1.0)),
    ("10", CGColor(red: 0.596078431372549, green: 0.588235294117647, blue: 0.596078431372549, alpha: 1.0)),
    ("20", CGColor(red: 0.925490196078431, green: 0.933333333333333, blue: 0.925490196078431, alpha: 1.0)),
    ("30", CGColor(red: 0.925490196078431, green: 0.933333333333333, blue: 0.925490196078431, alpha: 1.0)),
    ("01", CGColor(red: 0.0, green: 0.117647058823529, blue: 0.454901960784314, alpha: 1.0)),
    ("11", CGColor(red: 0.0313725490196078, green: 0.298039215686275, blue: 0.768627450980392, alpha: 1.0)),
    ("21", CGColor(red: 0.0, green: 0.298039215686275, blue: 0.603921568627451, alpha: 1.0)),
    ("31", CGColor(red: 0.658823529411765, green: 0.8, blue: 0.925490196078431, alpha: 1.0)),
    ("02", CGColor(red: 0.0313725490196078, green: 0.0627450980392157, blue: 0.564705882352941, alpha: 1.0)),
    ("12", CGColor(red: 0.188235294117647, green: 0.196078431372549, blue: 0.925490196078431, alpha: 1.0)),
    ("22", CGColor(red: 0.470588235294118, green: 0.486274509803922, blue: 0.925490196078431, alpha: 1.0)),
    ("32", CGColor(red: 0.737254901960784, green: 0.737254901960784, blue: 0.925490196078431, alpha: 1.0)),
    ("03", CGColor(red: 0.188235294117647, green: 0.0, blue: 0.533333333333333, alpha: 1.0)),
    ("13", CGColor(red: 0.36078431372549, green: 0.117647058823529, blue: 0.894117647058824, alpha: 1.0)),
    ("23", CGColor(red: 0.690196078431373, green: 0.384313725490196, blue: 0.925490196078431, alpha: 1.0)),
    ("33", CGColor(red: 0.831372549019608, green: 0.698039215686274, blue: 0.925490196078431, alpha: 1.0)),
    ("04", CGColor(red: 0.266666666666667, green: 0.0, blue: 0.392156862745098, alpha: 1.0)),
    ("14", CGColor(red: 0.533333333333333, green: 0.0784313725490196, blue: 0.690196078431373, alpha: 1.0)),
    ("24", CGColor(red: 0.894117647058824, green: 0.329411764705882, blue: 0.925490196078431, alpha: 1.0)),
    ("34", CGColor(red: 0.925490196078431, green: 0.682352941176471, blue: 0.925490196078431, alpha: 1.0)),
    ("05", CGColor(red: 0.36078431372549, green: 0.0, blue: 0.188235294117647, alpha: 1.0)),
    ("15", CGColor(red: 0.627450980392157, green: 0.0784313725490196, blue: 0.392156862745098, alpha: 1.0)),
    ("25", CGColor(red: 0.925490196078431, green: 0.345098039215686, blue: 0.705882352941177, alpha: 1.0)),
    ("35", CGColor(red: 0.925490196078431, green: 0.682352941176471, blue: 0.831372549019608, alpha: 1.0)),
    ("06", CGColor(red: 0.329411764705882, green: 0.0156862745098039, blue: 0.0, alpha: 1.0)),
    ("16", CGColor(red: 0.596078431372549, green: 0.133333333333333, blue: 0.125490196078431, alpha: 1.0)),
    ("26", CGColor(red: 0.925490196078431, green: 0.415686274509804, blue: 0.392156862745098, alpha: 1.0)),
    ("36", CGColor(red: 0.925490196078431, green: 0.705882352941177, blue: 0.690196078431373, alpha: 1.0)),
    ("07", CGColor(red: 0.235294117647059, green: 0.0941176470588235, blue: 0.0, alpha: 1.0)),
    ("17", CGColor(red: 0.470588235294118, green: 0.235294117647059, blue: 0.0, alpha: 1.0)),
    ("27", CGColor(red: 0.831372549019608, green: 0.533333333333333, blue: 0.125490196078431, alpha: 1.0)),
    ("37", CGColor(red: 0.894117647058824, green: 0.768627450980392, blue: 0.564705882352941, alpha: 1.0)),
    ("08", CGColor(red: 0.125490196078431, green: 0.164705882352941, blue: 0.0, alpha: 1.0)),
    ("18", CGColor(red: 0.329411764705882, green: 0.352941176470588, blue: 0.0, alpha: 1.0)),
    ("28", CGColor(red: 0.627450980392157, green: 0.666666666666667, blue: 0.0, alpha: 1.0)),
    ("38", CGColor(red: 0.8, green: 0.823529411764706, blue: 0.470588235294118, alpha: 1.0)),
    ("09", CGColor(red: 0.0313725490196078, green: 0.227450980392157, blue: 0.0, alpha: 1.0)),
    ("19", CGColor(red: 0.156862745098039, green: 0.447058823529412, blue: 0.0, alpha: 1.0)),
    ("29", CGColor(red: 0.454901960784314, green: 0.768627450980392, blue: 0.0, alpha: 1.0)),
    ("39", CGColor(red: 0.705882352941177, green: 0.870588235294118, blue: 0.470588235294118, alpha: 1.0)),
    ("0a", CGColor(red: 0.0, green: 0.250980392156863, blue: 0.0, alpha: 1.0)),
    ("1a", CGColor(red: 0.0313725490196078, green: 0.486274509803922, blue: 0.0, alpha: 1.0)),
    ("2a", CGColor(red: 0.298039215686275, green: 0.815686274509804, blue: 0.125490196078431, alpha: 1.0)),
    ("3a", CGColor(red: 0.658823529411765, green: 0.886274509803922, blue: 0.564705882352941, alpha: 1.0)),
    ("0b", CGColor(red: 0.0, green: 0.235294117647059, blue: 0.0, alpha: 1.0)),
    ("1b", CGColor(red: 0.0, green: 0.462745098039216, blue: 0.156862745098039, alpha: 1.0)),
    ("2b", CGColor(red: 0.219607843137255, green: 0.8, blue: 0.423529411764706, alpha: 1.0)),
    ("3b", CGColor(red: 0.596078431372549, green: 0.886274509803922, blue: 0.705882352941177, alpha: 1.0)),
    ("0c", CGColor(red: 0.0, green: 0.196078431372549, blue: 0.235294117647059, alpha: 1.0)),
    ("1c", CGColor(red: 0.0, green: 0.4, blue: 0.470588235294118, alpha: 1.0)),
    ("2c", CGColor(red: 0.219607843137255, green: 0.705882352941177, blue: 0.8, alpha: 1.0)),
    ("3c", CGColor(red: 0.627450980392157, green: 0.83921568627451, blue: 0.894117647058824, alpha: 1.0)),
    ("0d", CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)),
    ("1d", CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)),
    ("2d", CGColor(red: 0.235294117647059, green: 0.0, blue: 0.235294117647059, alpha: 1.0)),
    ("3d", CGColor(red: 0.627450980392157, green: 0.635294117647059, blue: 0.627450980392157, alpha: 1.0)),
    ("0e", CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)),
    ("1e", CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)),
    ("2e", CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)),
    ("3e", CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)),
    ("0f", CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)),
    ("1f", CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)),
    ("2f", CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)),
    ("3f", CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0))
]
