//
//  Slice.swift
//  MDPie
//
//  Created by maxday on 2015-04-03.
//  Copyright (c) 2015 MD. All rights reserved.
//

import Foundation
import UIKit


struct Slice {
    var bezierPath:UIBezierPath
    var shapeLayer:CAShapeLayer
    var angle:CGFloat
    var label:String
    
    init(myBezierPath:UIBezierPath, myShapeLayer:CAShapeLayer, myAngle:CGFloat, myLabel:String) {
        self.bezierPath = myBezierPath
        self.shapeLayer = myShapeLayer
        self.angle = myAngle
        self.label = myLabel
    }
}

class Data {
    var value:CGFloat
    var color:UIColor = UIColor.grayColor()
    var label:String = ""
    
    init(myValue:CGFloat, myColor:String, myLabel:String) {
        value = myValue
        color = UIColorFromRGB(myColor)
        label = myLabel
    }
    
    init(myValue:CGFloat, myColor:UIColor, myLabel:String) {
        value = myValue
        color = myColor
        label = myLabel
    }
    
    func UIColorFromRGB(colorCode: String, alpha: Float = 1.0) -> UIColor {
        var scanner = NSScanner(string:colorCode)
        var color:UInt32 = 0;
        scanner.scanHexInt(&color)
        
        let mask = 0x000000FF
        let r = CGFloat(Float(Int(color >> 16) & mask)/255.0)
        let g = CGFloat(Float(Int(color >> 8) & mask)/255.0)
        let b = CGFloat(Float(Int(color) & mask)/255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: CGFloat(alpha))
    }
}
