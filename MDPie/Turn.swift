//
//  Turn.swift
//  MDPie
//
//  Created by got2bex on 2015-04-03.
//  Copyright (c) 2015 MD. All rights reserved.
//

import UIKit
import QuartzCore

class Turn: UIControl {
    
    var slicesArray:Array<Slice> = Array<Slice>()
    var delta:CGFloat = 0
    var correctCenter:CGPoint = CGPointMake(0, 0)
    var oldPosition:CGPoint = CGPointMake(0, 0)
    
    
    var data:Array<Data> = Array<Data>()
    
    
    let smallRadius:CGFloat = 150
    let bigRadius:CGFloat = 250
    let expand:CGFloat = 50
    
    let centerX:CGFloat = 300
    let centerY:CGFloat = 300
    
    var hasBeenDraged:Bool = false
    
    var openedSlice:CAShapeLayer?
    
    var oldTransform:CATransform3D?
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        correctCenter = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        
  
        
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

  
    func build() {
        
        var total:CGFloat = 0
        var currentAngle:CGFloat = 0
        var currentEndAngle:CGFloat = 0
        var currentStartAngle:CGFloat = 0
        
        for currentValue in data  {
            total+=currentValue.value
        }
        
        for currentValue in data  {
            currentAngle = currentValue.value * 2 * CGFloat(M_PI) / total
            let slice = createSlice(currentStartAngle, end: CGFloat(currentStartAngle - currentAngle), color:currentValue.color)
            currentStartAngle -= currentAngle
            currentEndAngle = currentStartAngle - currentAngle
            self.layer.insertSublayer(slice.shapeLayer, atIndex:0)
        }
        
        
        
    

    
    }
    
    
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        
        
        if(hasBeenDraged) {
            println("return")
            return
        }
        var cpt = 0
        
        let currentPoint = touch.locationInView(self)
        for currentPath in slicesArray {
            if currentPath.bezierPath.containsPoint(currentPoint) {
                
                
                openedSlice?.transform = oldTransform!
                
                
                
                
                
                if(openedSlice == slicesArray[cpt].shapeLayer) {
                    openedSlice = nil
                    return
                }
                
                openedSlice = slicesArray[cpt].shapeLayer
                
                oldTransform = openedSlice?.transform
                
                
                var i=0
                var angleSum:CGFloat = 0
                for(i=0; i<cpt; ++i) {
                    angleSum += slicesArray[i].angle
                }
                angleSum += slicesArray[cpt].angle/2.0
                
                
                
                let transX:CGFloat = expand*cos(angleSum)
                let transY:CGFloat = expand*sin(angleSum)
                
                
                let translate = CATransform3DMakeTranslation(transX, transY, 0);
                openedSlice?.transform = translate
                
                
                
                
            }
            cpt++
        }

        
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        hasBeenDraged = false

        
        let currentPoint = touch.locationInView(self)
      
        if ignoreThisTap(currentPoint) {
            return false;
        }
        
        
        
        let deltaX = currentPoint.x - correctCenter.x;
        let deltaY = currentPoint.y - correctCenter.y;

        delta = atan2(deltaY,deltaX)
 
        
        
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        hasBeenDraged = true
        let currentPoint = touch.locationInView(self)
        

        
        
        let deltaX = currentPoint.x - correctCenter.x;
        let deltaY = currentPoint.y - correctCenter.y;
        
        let ang = atan2(deltaY,deltaX);
        let angleDifference = delta - ang
        
       
        
        self.transform = CGAffineTransformRotate(self.transform, -angleDifference);
        
        return true;
    }
    
    
    
    
    func ignoreThisTap(currentPoint:CGPoint) -> Bool {
        let dx = currentPoint.x - correctCenter.x
        let dy = currentPoint.y - correctCenter.y
        let sqroot = sqrt(dx*dx + dy*dy)
        return sqroot < smallRadius || sqroot > bigRadius + expand
    }
    
    
    func createSlice(start:CGFloat, end:CGFloat, color:UIColor) -> Slice {
        
        var mask = CAShapeLayer()
        
        mask.frame = self.frame
        let path = drawSlice(start, end: end)
        mask.path = path.CGPath
        mask.lineWidth = 1.0
        mask.strokeColor = color.CGColor
        
       
        mask.fillColor = color.CGColor
       
        
        
        
        var slice = Slice(myBezierPath: path, myShapeLayer: mask, myAngle: end-start)
        slicesArray.append(slice)
        
        return slice;
        
    }
    
    
    func drawSlice(start:CGFloat, end:CGFloat) -> UIBezierPath {
        
        var path = UIBezierPath()
        
        
        
        
        
        path.moveToPoint(CGPointMake(centerX + smallRadius *  cos(start), centerY + smallRadius * sin(start)))
        path.addArcWithCenter(CGPointMake(centerX, centerY), radius: smallRadius, startAngle: start, endAngle: end, clockwise: false)
        
        
        var path2 = UIBezierPath()
        path2.moveToPoint(CGPointMake(centerX + smallRadius *  cos(start), centerY))
        
        path2.addArcWithCenter(CGPointMake(centerX, centerY), radius: bigRadius, startAngle: start, endAngle: end, clockwise: false)
        
        path.addLineToPoint(path2.currentPoint)
        
        path.addArcWithCenter(CGPointMake(centerX, centerY), radius: bigRadius, startAngle: end, endAngle: start, clockwise: true)
        
        
        path.addLineToPoint(CGPointMake(centerX + smallRadius *  cos(start), centerY + smallRadius * sin(start)))
        
        
        
        
        
        return path;
        
        
    }

    

}
