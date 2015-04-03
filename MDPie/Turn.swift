//
//  Turn.swift
//  MDPie
//
//  Created by got2bex on 2015-04-03.
//  Copyright (c) 2015 MD. All rights reserved.
//

import UIKit
import QuartzCore


protocol TurnDataSource {
    
    func colorForSliceAtIndex(index:Int) -> UIColor
    func valueForSliceAtIndex(index:Int) -> CGFloat
    func labelForSliceAtIndex(index:Int) -> String
    
    func numberOfSlices() -> Int

}

@objc protocol TurnDelegate {
    
    optional func willOpenSliceAtIndex(index:Int)
    optional func willCloseSliceAtIndex(index:Int)
    
    optional func didOpenSliceAtIndex(index:Int)
    optional func didCloseSliceAtIndex(index:Int)
    
}

class Turn: UIControl {
    
    var slicesArray:Array<Slice> = Array<Slice>()
    var delta:CGFloat = 0
    var correctCenter:CGPoint = CGPointMake(0, 0)
    var oldPosition:CGPoint = CGPointMake(0, 0)
    
    var datasource:TurnDataSource!
    var delegate:TurnDelegate!
    
    let smallRadius:CGFloat = 120
    let bigRadius:CGFloat = 280
    let expand:CGFloat = 50
    
    let centerX:CGFloat = 350
    let centerY:CGFloat = 350
    
    let percentBoxSizeHeight:CGFloat = 40
    let percentBoxSizeWidth:CGFloat = 150
    
    var hasBeenDraged:Bool = false
    
    var openedSlice:CAShapeLayer?
    
    var oldTransform:CATransform3D?
    
    var oldSelected:Int = 0
    
    var labelCenter:UILabel = UILabel()
   
    var copyTransform:CGAffineTransform!
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        correctCenter = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        copyTransform = self.transform
        
        labelCenter.frame = CGRectMake(0, 0, percentBoxSizeWidth, percentBoxSizeHeight)
        labelCenter.center = CGPointMake(centerX, centerY)
        labelCenter.textColor = UIColor.blackColor()
        labelCenter.textAlignment = NSTextAlignment.Center
        addSubview(labelCenter)
        
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

  
    func build() {
        
        if(datasource == nil) {
            println("Did you forget to set your datasource ?")
            return
        }
        
        self.transform = copyTransform
        
        labelCenter.transform = self.transform
        labelCenter.text = ""
        
        var currentShape:CAShapeLayer
        for currentShape in slicesArray {
            currentShape.shapeLayer.removeFromSuperlayer()
        }
        slicesArray.removeAll(keepCapacity: false)
        
        
        var total:CGFloat = 0
        var currentAngle:CGFloat = 0
        var currentEndAngle:CGFloat = 0
        var currentStartAngle:CGFloat = 0
        var currentColor:UIColor = UIColor.grayColor()
        var currentLabel:String
        
        
        
        
        

        var index = 0
        for (index=0; index < datasource.numberOfSlices(); ++index) {
            total = total + datasource.valueForSliceAtIndex(index)
        }

        
        var angleSum:CGFloat = 0
        
        for (index = 0; index < datasource?.numberOfSlices(); ++index) {
            
            currentAngle = datasource.valueForSliceAtIndex(index) * 2 * CGFloat(M_PI) / total
            currentColor = datasource.colorForSliceAtIndex(index)
            currentLabel = datasource.labelForSliceAtIndex(index)
            let slice = createSlice(currentStartAngle, end: CGFloat(currentStartAngle - currentAngle), color:currentColor, label:currentLabel, value:100 * datasource.valueForSliceAtIndex(index)/total)
            
            
            angleSum += slice.angle/2
            
            //label creation
            
            
            let label = UILabel(frame: CGRectMake(0, 0, percentBoxSizeWidth, percentBoxSizeHeight))
            label.center = CGPointMake(centerX+(smallRadius + (bigRadius-smallRadius)/2)*cos(angleSum), centerY+(smallRadius + (bigRadius-smallRadius)/2)*sin(angleSum))
            
            
            label.textAlignment = NSTextAlignment.Center
            
            
            
            
            label.text = slicesArray[index].label
            
            label.textColor = UIColor.blackColor()
            
            slicesArray[index].labelObj = label
            slicesArray[index].shapeLayer.addSublayer(label.layer)

            
            //end label creation
            
            
            angleSum += slice.angle/2
            
            
            
            
            
            
            
            
            self.layer.insertSublayer(slice.shapeLayer, atIndex:0)
            
            currentStartAngle -= currentAngle
            currentEndAngle = currentStartAngle - currentAngle
            

            
            let animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
            animateStrokeEnd.duration = 0.5
            animateStrokeEnd.fromValue = 0.0
            animateStrokeEnd.toValue = 1.0

            // add the animation
            slice.shapeLayer.addAnimation(animateStrokeEnd, forKey: "animate stroke end animation")
            CATransaction.commit()
            

            
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
            if currentPath.paths.bezierPath.containsPoint(currentPoint) {
                
                
                if((openedSlice?.transform) != nil)  {
                    delegate?.willCloseSliceAtIndex!(oldSelected)
                    openedSlice?.transform = oldTransform!
                    delegate?.didCloseSliceAtIndex!(oldSelected)
                }
                
                
                
                
                
                
                if(openedSlice == slicesArray[cpt].shapeLayer) {
                    openedSlice = nil
                    return
                }
                
                openedSlice = slicesArray[cpt].shapeLayer
                oldSelected = cpt
                
                oldTransform = openedSlice?.transform
                
                var nf:NSNumberFormatter = NSNumberFormatter()
                nf.groupingSize = 3
                nf.maximumSignificantDigits = 3
                nf.minimumSignificantDigits = 3
                
                labelCenter.text = nf.stringFromNumber(slicesArray[cpt].value)?.stringByAppendingString("%")
                
                var i=0
                var angleSum:CGFloat = 0
                for(i=0; i<cpt; ++i) {
                    angleSum += slicesArray[i].angle
                }
                angleSum += slicesArray[cpt].angle/2.0
                
                
                
                let transX:CGFloat = expand*cos(angleSum)
                let transY:CGFloat = expand*sin(angleSum)
                
                let translate = CATransform3DMakeTranslation(transX, transY, 0);
                
                
                delegate?.willOpenSliceAtIndex!(cpt)
                openedSlice?.transform = translate

                delegate?.didOpenSliceAtIndex!(cpt)
                

                
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
        
       
        let savedTransform = slicesArray[0].labelObj?.transform
        
        let savedTransformCenter = labelCenter.transform
    
        
        self.transform = CGAffineTransformRotate(self.transform, -angleDifference)
        
        for slice in slicesArray  {
            if(slice.labelObj != nil)  {
                slice.labelObj?.transform = CGAffineTransformRotate(savedTransform!, angleDifference)
            }
            
        }
        
        labelCenter.transform = CGAffineTransformRotate(savedTransformCenter, angleDifference)
        
        return true;
    }
    
    
    
    
    func ignoreThisTap(currentPoint:CGPoint) -> Bool {
        let dx = currentPoint.x - correctCenter.x
        let dy = currentPoint.y - correctCenter.y
        let sqroot = sqrt(dx*dx + dy*dy)
        return sqroot < smallRadius || sqroot > (bigRadius + expand + (bigRadius-smallRadius)/2)
    }
    
    func createSlice(start:CGFloat, end:CGFloat, color:UIColor, label:String, value:CGFloat) -> Slice {
        
        var mask = CAShapeLayer()
        
        mask.frame = self.frame
        let path = drawSlice(start, end: end)
        mask.path = path.animationBezierPath.CGPath
        mask.lineWidth = bigRadius-smallRadius
        mask.strokeColor = color.CGColor
        mask.fillColor = color.CGColor
        
        var slice = Slice(myPaths: path, myShapeLayer: mask, myAngle: end-start, myLabel:label, myValue:value)
        slicesArray.append(slice)
        
        
        
        
        
        
        
        return slice;
        
    }

    
    func drawSlice(start:CGFloat, end:CGFloat) -> DualPath {
        
        var path = UIBezierPath()
        var animationPath = UIBezierPath()
        var pathToDetectMiddlePoint = UIBezierPath()
        
       
        
        path.moveToPoint(CGPointMake(centerX + smallRadius *  cos(start), centerY + smallRadius * sin(start)))
        

        animationPath.moveToPoint(CGPointMake(centerX + (smallRadius + (bigRadius-smallRadius)/2) *  cos(start), centerY + (smallRadius + (bigRadius-smallRadius)/2) * sin(start)))
        

        path.addArcWithCenter(CGPointMake(centerX, centerY), radius: smallRadius, startAngle: start, endAngle: end, clockwise: false)
        
        
        pathToDetectMiddlePoint.moveToPoint(animationPath.currentPoint)
        
        
        
        animationPath.addArcWithCenter(CGPointMake(centerX, centerY), radius: (smallRadius + (bigRadius-smallRadius)/2), startAngle: start, endAngle: end, clockwise: false)
        
        pathToDetectMiddlePoint.addArcWithCenter(CGPointMake(centerX, centerY), radius: (smallRadius + (bigRadius-smallRadius)/2), startAngle: start, endAngle: end, clockwise: false)
        
        
        
        
        animationPath.addArcWithCenter(CGPointMake(centerX, centerY), radius: (smallRadius + (bigRadius-smallRadius)/2), startAngle: end, endAngle: start, clockwise: true)
        
        pathToDetectMiddlePoint.addArcWithCenter(CGPointMake(centerX, centerY), radius: (smallRadius + (bigRadius-smallRadius)/2), startAngle: end, endAngle: start/2, clockwise: true)
        
        
        
       
        
        
        var path2 = UIBezierPath()
        path2.moveToPoint(CGPointMake(centerX + smallRadius *  cos(start), centerY))
        
        path2.addArcWithCenter(CGPointMake(centerX, centerY), radius: bigRadius, startAngle: start, endAngle: end, clockwise: false)
        
        path.addLineToPoint(path2.currentPoint)
        
        path.addArcWithCenter(CGPointMake(centerX, centerY), radius: bigRadius, startAngle: end, endAngle: start, clockwise: true)
        
        
        path.addLineToPoint(CGPointMake(centerX + smallRadius *  cos(start), centerY + smallRadius * sin(start)))

        return DualPath(myBezierPath: path, myAnimationBezierPath: animationPath);
        
    }

    

}
