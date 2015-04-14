//
//  Turn.swift
//  MDPie
//
//  Created by Maxime DAVID on 2015-04-03.
//  Copyright (c) 2015 Maxime DAVID. All rights reserved.
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



struct TurnProperties {
    let smallRadius:CGFloat = 120
    let bigRadius:CGFloat = 280
    let expand:CGFloat = 90
    
    let percentBoxSizeHeight:CGFloat = 40
    let percentBoxSizeWidth:CGFloat = 150
    
    let displayValueTypeInSlices:DisplayValueType = .Percent
    let displayValueTypeCenter:DisplayValueType = .Label

    var nf = NSNumberFormatter()
    
    init() {
        nf.groupingSize = 3
        nf.maximumSignificantDigits = 3
        nf.minimumSignificantDigits = 3
    }
}

class Turn: UIControl {
    var slicesArray:Array<Slice> = Array<Slice>()
    var delta:CGFloat = 0
    var correctCenter:CGPoint = CGPointMake(0, 0)
    var oldPosition:CGPoint = CGPointMake(0, 0)
    
    let properties = TurnProperties()
    
    
    var datasource:TurnDataSource!
    var delegate:TurnDelegate!
    
    var hasBeenDraged:Bool = false
    
    var openedSlice:CAShapeLayer?
    
    var oldTransform:CATransform3D?
    
    var oldSelected:Int = 0
    
    var labelCenter:UILabel = UILabel()
   
    var copyTransform:CGAffineTransform!
    
    var angleSum:CGFloat = -1
  
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        correctCenter = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        copyTransform = self.transform
        
        labelCenter.frame = CGRectMake(0, 0, properties.percentBoxSizeWidth, properties.percentBoxSizeHeight)
        labelCenter.center = CGPointMake((self.frame.width/2), (self.frame.height/2))
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
        var currentValue:CGFloat
        
        
        
        

        var index = 0
        for (index=0; index < datasource.numberOfSlices(); ++index) {
            total = total + datasource.valueForSliceAtIndex(index)
        }

        
        angleSum = 0
        
        for (index = 0; index < datasource?.numberOfSlices(); ++index) {
            currentValue  = datasource.valueForSliceAtIndex(index)
            currentAngle = currentValue * 2 * CGFloat(M_PI) / total
            currentColor = datasource.colorForSliceAtIndex(index)
            currentLabel = datasource.labelForSliceAtIndex(index)
            let slice = createSlice(currentStartAngle, end: CGFloat(currentStartAngle - currentAngle), color:currentColor, label:currentLabel, value:currentValue, percent:100 * currentValue/total)
            
            
            angleSum += slice.angle/2
            
            //label creation
            
            
            let label = UILabel(frame: CGRectMake(0, 0, properties.percentBoxSizeWidth, properties.percentBoxSizeHeight))
            label.center = CGPointMake((self.frame.width/2)+(properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2)*cos(angleSum), (self.frame.height/2)+(properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2)*sin(angleSum))
            
            
            label.textAlignment = NSTextAlignment.Center
            label.textColor = UIColor.blackColor()
            
            label.text = formatFromDisplayValueType(slice, displayType: properties.displayValueTypeInSlices)
            
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
    
    
    
    
    func openCloseSlice(cpt:Int)  {
        
        if((openedSlice?.transform) != nil)  {
            delegate?.willCloseSliceAtIndex!(oldSelected)
            openedSlice?.transform = oldTransform!
            delegate?.didCloseSliceAtIndex!(oldSelected)
            labelCenter.text = ""
        }
        
        
        if(openedSlice == slicesArray[cpt].shapeLayer) {
            openedSlice = nil
            println("nil")
            return
        }
        
        openedSlice = slicesArray[cpt].shapeLayer
        oldSelected = cpt
        
        oldTransform = openedSlice?.transform
        
        
        labelCenter.text = formatFromDisplayValueType(slicesArray[cpt], displayType: properties.displayValueTypeCenter)

        
        var i=0
        var angleSum:CGFloat = 0
        for(i=0; i<cpt; ++i) {
            angleSum += slicesArray[i].angle
        }
        angleSum += slicesArray[cpt].angle/2.0
        
        
        
        let transX:CGFloat = properties.expand*cos(angleSum)
        let transY:CGFloat = properties.expand*sin(angleSum)
        
        let translate = CATransform3DMakeTranslation(transX, transY, 0);
        
        
        delegate?.willOpenSliceAtIndex!(cpt)
        openedSlice?.transform = translate
        
        delegate?.didOpenSliceAtIndex!(cpt)
    }
    
    
    
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        
        
        if(hasBeenDraged) {
            println("return")
            return
        }
        
        
        let currentPoint = touch.locationInView(self)
        
        
        
        let transX:CGFloat = properties.expand*cos(angleSum)
        let transY:CGFloat = properties.expand*sin(angleSum)
        
        println("angleSum = \(angleSum) transX = \(transX) and transY = \(transY)")
        
        let currentPointTranslated = CGPointMake(currentPoint.x - transX, currentPoint.y - transY)
        
        println(currentPoint)
        println(currentPointTranslated)
       
        var cpt = 0
        for currentPath in slicesArray {
            
            if currentPath.paths.selectionBezierPath.containsPoint(currentPoint) {
                openCloseSlice(cpt)
                return
            }
            cpt++
        }

        
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        hasBeenDraged = false

        
        let currentPoint = touch.locationInView(self)
      
        if ignoreThisTap(currentPoint) {
            println("ignore")
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
        return sqroot < properties.smallRadius || sqroot > (properties.bigRadius + properties.expand + (properties.bigRadius-properties.smallRadius)/2)
    }
    
    func createSlice(start:CGFloat, end:CGFloat, color:UIColor, label:String, value:CGFloat, percent:CGFloat) -> Slice {
        
        var mask = CAShapeLayer()
        
        mask.frame = self.frame
        let path = drawSlice(start, end: end)
        mask.path = path.animationBezierPath.CGPath
        mask.lineWidth = properties.bigRadius-properties.smallRadius
        mask.strokeColor = color.CGColor
        mask.fillColor = color.CGColor
        
        var slice = Slice(myPaths: path, myShapeLayer: mask, myAngle: end-start, myLabel:label, myValue:value, myPercent:percent)
        slicesArray.append(slice)
        
        
        
        
        
        
        
        return slice;
        
    }
    
    func formatFromDisplayValueType(slice:Slice, displayType:DisplayValueType) -> String {
    
        var toRet = ""
        
        switch(displayType) {
        case .Value :
            toRet = properties.nf.stringFromNumber(slice.value)!
            break
        case .Percent :
            toRet = (properties.nf.stringFromNumber(slice.percent)?.stringByAppendingString("%"))!
            break
        case .Label :
            toRet = slice.label
            break
        default :
            toRet = slice.label
            break
        }

        return toRet;
    }

    
    func drawSlice(start:CGFloat, end:CGFloat) -> TrioPath {
        
        var path = UIBezierPath()
        var selectionPath = UIBezierPath()
        var animationPath = UIBezierPath()
        var pathToDetectMiddlePoint = UIBezierPath()
        
       
        
        path.moveToPoint(CGPointMake((self.frame.width/2) + properties.smallRadius *  cos(start), (self.frame.height/2) + properties.smallRadius * sin(start)))
        
        selectionPath.moveToPoint(CGPointMake((self.frame.width/2) + properties.smallRadius *  cos(start), (self.frame.height/2) + properties.smallRadius * sin(start)))
        

        animationPath.moveToPoint(CGPointMake((self.frame.width/2) + (properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2) *  cos(start), (self.frame.height/2) + (properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2) * sin(start)))
        

        path.addArcWithCenter(CGPointMake((self.frame.width/2), (self.frame.height/2)), radius: properties.smallRadius, startAngle: start, endAngle: end, clockwise: false)
        
        selectionPath.addArcWithCenter(CGPointMake((self.frame.width/2), (self.frame.height/2)), radius: properties.smallRadius, startAngle: start, endAngle: end, clockwise: false)
        
        
  
        
        
        
        animationPath.addArcWithCenter(CGPointMake((self.frame.width/2), (self.frame.height/2)), radius: (properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2), startAngle: start, endAngle: end, clockwise: false)
        
        
        
        
        
        animationPath.addArcWithCenter(CGPointMake((self.frame.width/2), (self.frame.height/2)), radius: (properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2), startAngle: end, endAngle: start, clockwise: true)
        
      
        
        
        var path2 = UIBezierPath()
        path2.moveToPoint(CGPointMake((self.frame.width/2) + properties.smallRadius *  cos(start), (self.frame.height/2)))
        
        
        var path2Selection = UIBezierPath()
        path2Selection.moveToPoint(CGPointMake((self.frame.width/2) + properties.smallRadius *  cos(start), (self.frame.height/2)))
        
        
        path2.addArcWithCenter(CGPointMake((self.frame.width/2), (self.frame.height/2)), radius: properties.bigRadius, startAngle: start, endAngle: end, clockwise: false)
        
        
        path2Selection.addArcWithCenter(CGPointMake((self.frame.width/2), (self.frame.height/2)), radius: properties.bigRadius+properties.expand, startAngle: start, endAngle: end, clockwise: false)
        
        
        
        path.addLineToPoint(path2.currentPoint)
        
        selectionPath.addLineToPoint(path2Selection.currentPoint)
        
        path.addArcWithCenter(CGPointMake((self.frame.width/2), (self.frame.height/2)), radius: properties.bigRadius, startAngle: end, endAngle: start, clockwise: true)
        
        
        path.addLineToPoint(CGPointMake((self.frame.width/2) + properties.smallRadius *  cos(start), (self.frame.height/2) + properties.smallRadius * sin(start)))
        
        
        
        selectionPath.addArcWithCenter(CGPointMake((self.frame.width/2), (self.frame.height/2)), radius: properties.bigRadius + properties.expand, startAngle: end, endAngle: start, clockwise: true)
        
        
        selectionPath.addLineToPoint(CGPointMake((self.frame.width/2) + properties.smallRadius *  cos(start), (self.frame.height/2) + properties.smallRadius * sin(start)))
        
        

        return TrioPath(myBezierPath: path, myAnimationBezierPath: animationPath, mySelectionBezierPath: selectionPath)
        
    }

    

}

struct TrioPath {
    var bezierPath:UIBezierPath
    var animationBezierPath:UIBezierPath
    var selectionBezierPath:UIBezierPath
    
    init(myBezierPath:UIBezierPath, myAnimationBezierPath:UIBezierPath, mySelectionBezierPath:UIBezierPath) {
        self.bezierPath = myBezierPath
        self.animationBezierPath = myAnimationBezierPath
        self.selectionBezierPath = mySelectionBezierPath
    }
}

struct Slice {
    var paths:TrioPath
    var shapeLayer:CAShapeLayer
    var angle:CGFloat
    var label:String
    var value:CGFloat
    var labelObj:UILabel?
    var percent:CGFloat
    
    init(myPaths:TrioPath, myShapeLayer:CAShapeLayer, myAngle:CGFloat, myLabel:String, myValue:CGFloat, myPercent:CGFloat) {
        self.paths = myPaths
        self.shapeLayer = myShapeLayer
        self.angle = myAngle
        self.label = myLabel
        self.value = myValue
        self.percent = myPercent
    }
}

enum DisplayValueType {
    case Percent
    case Value
    case Label
}

