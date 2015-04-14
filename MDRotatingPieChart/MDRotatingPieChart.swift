//
//  MDRotatingPieChart.swift
//  MDRotatingPieChart
//
//  Created by Maxime DAVID on 2015-04-03.
//  Copyright (c) 2015 Maxime DAVID. All rights reserved.
//

import UIKit
import QuartzCore


protocol MDRotatingPieChartDataSource {
    func colorForSliceAtIndex(index:Int) -> UIColor
    func valueForSliceAtIndex(index:Int) -> CGFloat
    func labelForSliceAtIndex(index:Int) -> String
    
    func numberOfSlices() -> Int
}

@objc protocol MDRotatingPieChartDelegate {
    optional func willOpenSliceAtIndex(index:Int)
    optional func willCloseSliceAtIndex(index:Int)
    
    optional func didOpenSliceAtIndex(index:Int)
    optional func didCloseSliceAtIndex(index:Int)
}



struct Properties {
    var smallRadius:CGFloat = 120
    var bigRadius:CGFloat = 280
    var expand:CGFloat = 50
    
    var displayValueTypeInSlices:DisplayValueType = .Percent
    var displayValueTypeCenter:DisplayValueType = .Label

    var fontTextInSlices:UIFont = UIFont(name: "Arial", size: 10)!
    var fontTextCenter:UIFont = UIFont(name: "Arial", size: 10)!
    
    var enableAnimation = true
    var animationDuration:CFTimeInterval = 0.5
    
    var nf = NSNumberFormatter()
    
    init() {
        nf.groupingSize = 3
        nf.maximumSignificantDigits = 3
        nf.minimumSignificantDigits = 3
    }
}

class MDRotatingPieChart: UIControl {
    var slicesArray:Array<Slice> = Array<Slice>()
    var delta:CGFloat = 0
    
    var properties = Properties()
    
    var datasource:MDRotatingPieChartDataSource!
    var delegate:MDRotatingPieChartDelegate!
    
    var hasBeenDraged:Bool = false

    var openedSlice:CAShapeLayer?
    
    var oldTransform:CATransform3D?
    
    var oldSelected:Int = -1
    var labelCenter:UILabel = UILabel()
   
    var originalTransform:CGAffineTransform!

    var pieChartCenter:CGPoint = CGPointZero
  
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //saves the center (since the frame will change after some rotations)
        pieChartCenter.x = frame.width/2
        pieChartCenter.y = frame.height/2
        
        //saves the transform property so that it will be easy to reset the pieChart
        originalTransform = self.transform
        
        //builds and adds the centered label
        labelCenter.frame = CGRectZero
        labelCenter.center = CGPointMake(pieChartCenter.x, pieChartCenter.y)
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
        
        self.transform = originalTransform
        
        labelCenter.transform = self.transform
        labelCenter.text = ""
        
        for currentShape in slicesArray {
            currentShape.shapeLayer.removeFromSuperlayer()
        }
        slicesArray.removeAll(keepCapacity: false)
        
        var total = computeTotal()
        
        var currentStartAngle:CGFloat = 0
        var angleSum:CGFloat = 0
        
        for (var index = 0; index < datasource?.numberOfSlices(); ++index) {
            prepareSlice(&angleSum, currentStartAngle: &currentStartAngle, total: total, index: index)
        }
    }
    
    
    func prepareSlice(inout angleSum:CGFloat, inout currentStartAngle:CGFloat, total:CGFloat, index:Int) {
    
        let currentValue  = datasource.valueForSliceAtIndex(index)
        let currentAngle = currentValue * 2 * CGFloat(M_PI) / total
        let currentColor = datasource.colorForSliceAtIndex(index)
        let currentLabel = datasource.labelForSliceAtIndex(index)
        
        //create slice
        let slice = createSlice(currentStartAngle, end: CGFloat(currentStartAngle - currentAngle), color:currentColor, label:currentLabel, value:currentValue, percent:100 * currentValue/total)
        
        //create label
        let label = createLabel(angleSum + slice.angle/2, slice: slice)
        
        //populate slicesArray
        slicesArray[index].labelObj = label
        slicesArray[index].shapeLayer.addSublayer(label.layer)
        
        angleSum += slice.angle
        
        self.layer.insertSublayer(slice.shapeLayer, atIndex:0)
        
        currentStartAngle -= currentAngle
        
        if(properties.enableAnimation) {
            addAnimation(slice)
        }
    }
    
    func getMiddlePoint(angleSum:CGFloat) -> CGPoint {
        
        let middleRadiusX = properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2
        let middleRadiusY = properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2
        
        return CGPointMake(
            cos(angleSum) * middleRadiusX + pieChartCenter.x,
            sin(angleSum) * middleRadiusY + pieChartCenter.y
        )
    }
    
    
    func createLabel(angleSum:CGFloat, slice:Slice) -> UILabel {
        let label = UILabel(frame: CGRectZero)
        
        label.center = getMiddlePoint(angleSum)
        
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.blackColor()
        label.font = properties.fontTextInSlices
        
        label.text = formatFromDisplayValueType(slice, displayType: properties.displayValueTypeInSlices)
        
        let tmpCenter = label.center
        label.sizeToFit()
        label.center = tmpCenter
        label.hidden = !frameFitInPath(label.frame, path: slice.paths.bezierPath, inside:true)
        return label;
    }
    
    
    /**
    Adds an animation to a slice
    
    :param: slice the slice to be animated
    */
    func addAnimation(slice:Slice) {
        
        let animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        animateStrokeEnd.duration = properties.animationDuration
        animateStrokeEnd.fromValue = 0.0
        animateStrokeEnd.toValue = 1.0
        
        slice.shapeLayer.addAnimation(animateStrokeEnd, forKey: "animate stroke end animation")
        CATransaction.commit()
    }
    
    /**
    Computes the total value of slices
    
    :returns: the total value
    */
    func computeTotal() -> CGFloat {
        var total:CGFloat = 0
        for (var index=0; index < datasource.numberOfSlices(); ++index) {
            total = total + datasource.valueForSliceAtIndex(index)
        }
        return total;
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
            return
        }
        
        openedSlice = slicesArray[cpt].shapeLayer
        oldSelected = cpt
        
        oldTransform = openedSlice?.transform
        
        
        labelCenter.text = formatFromDisplayValueType(slicesArray[cpt], displayType: properties.displayValueTypeCenter)
        let centerTmp = labelCenter.center
        labelCenter.sizeToFit()
        labelCenter.center = centerTmp
        
        labelCenter.hidden = false
        var index = 0;
        for (; index < datasource?.numberOfSlices(); ++index) {
            if(!frameFitInPath(labelCenter.frame, path: slicesArray[index].paths.bezierPath, inside:false)) {
                println(index)
                labelCenter.hidden = true
                break;
            }
        }
      
        
        
        
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
            return
        }
        
        
        let currentPoint = touch.locationInView(self)
        
        
        
        let transX:CGFloat = properties.expand
        let transY:CGFloat = properties.expand
        
        
        let currentPointTranslated = CGPointMake(currentPoint.x - transX, currentPoint.y - transY)
       
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
            return false;
        }
        
        
        
        let deltaX = currentPoint.x - pieChartCenter.x
        let deltaY = currentPoint.y - pieChartCenter.y

        delta = atan2(deltaY,deltaX)
 
        
        
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        hasBeenDraged = true
        let currentPoint = touch.locationInView(self)
        

        
        
        let deltaX = currentPoint.x - pieChartCenter.x
        let deltaY = currentPoint.y - pieChartCenter.y
        
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
        let dx = currentPoint.x - pieChartCenter.x
        let dy = currentPoint.y - pieChartCenter.y
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
    
    
    /**
    Formats the text
    
    :param: slice       a slice
    :param: displayType an enum representing a display value type
    
    :returns: a formated text ready to be displayed
    */
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
        
    
        
        path.moveToPoint(CGPointMake(pieChartCenter.x + properties.smallRadius *  cos(start), pieChartCenter.y + properties.smallRadius * sin(start)))
        
        
 
        
        
        selectionPath.moveToPoint(CGPointMake(pieChartCenter.x + properties.smallRadius *  cos(start), pieChartCenter.y + properties.smallRadius * sin(start)))
        

        animationPath.moveToPoint(CGPointMake(pieChartCenter.x + (properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2) *  cos(start), pieChartCenter.y + (properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2) * sin(start)))
        

        path.addArcWithCenter(CGPointMake(pieChartCenter.x, pieChartCenter.y), radius: properties.smallRadius, startAngle: start, endAngle: end, clockwise: false)
        
        selectionPath.addArcWithCenter(CGPointMake(pieChartCenter.x, pieChartCenter.y), radius: properties.smallRadius, startAngle: start, endAngle: end, clockwise: false)
        
        
  
        
        
        
        animationPath.addArcWithCenter(CGPointMake(pieChartCenter.x, pieChartCenter.y), radius: (properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2), startAngle: start, endAngle: end, clockwise: false)
        
        
        
        
        
        animationPath.addArcWithCenter(CGPointMake(pieChartCenter.x, pieChartCenter.y), radius: (properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2), startAngle: end, endAngle: start, clockwise: true)
        
      
        
        
        var path2 = UIBezierPath()
        path2.moveToPoint(CGPointMake(pieChartCenter.x + properties.smallRadius *  cos(start), pieChartCenter.y))
        
        
        var path2Selection = UIBezierPath()
        path2Selection.moveToPoint(CGPointMake(pieChartCenter.x + properties.smallRadius *  cos(start), pieChartCenter.y))
        
        
        path2.addArcWithCenter(CGPointMake(pieChartCenter.x, pieChartCenter.y), radius: properties.bigRadius, startAngle: start, endAngle: end, clockwise: false)
        
        
        path2Selection.addArcWithCenter(CGPointMake(pieChartCenter.x, pieChartCenter.y), radius: properties.bigRadius+properties.expand, startAngle: start, endAngle: end, clockwise: false)
        
        
        
        path.addLineToPoint(path2.currentPoint)
        
        selectionPath.addLineToPoint(path2Selection.currentPoint)
        
        path.addArcWithCenter(CGPointMake(pieChartCenter.x, pieChartCenter.y), radius: properties.bigRadius, startAngle: end, endAngle: start, clockwise: true)
        
        
        path.addLineToPoint(CGPointMake(pieChartCenter.x + properties.smallRadius *  cos(start), pieChartCenter.y + properties.smallRadius * sin(start)))
        
        
        
        selectionPath.addArcWithCenter(CGPointMake(pieChartCenter.x, pieChartCenter.y), radius: properties.bigRadius + properties.expand, startAngle: end, endAngle: start, clockwise: true)
        
        
        selectionPath.addLineToPoint(CGPointMake(pieChartCenter.x + properties.smallRadius *  cos(start), pieChartCenter.y + properties.smallRadius * sin(start)))
        
        

        return TrioPath(myBezierPath: path, myAnimationBezierPath: animationPath, mySelectionBezierPath: selectionPath)
        
    }
    
    
    /**
    Tells whether or not the given frame is overlapping with a shape (delimited by an UIBeizerPath)
    
    :param: frame  the frame
    :param: path   the path
    :param: inside tells whether or not the path should be inside the path
    
    :returns: true if it fits, false otherwise
    */
    func frameFitInPath(frame:CGRect, path:UIBezierPath, inside:Bool) -> Bool {
        
        let topLeftPoint = frame.origin
        let topRightPoint = CGPointMake(frame.origin.x + frame.width, frame.origin.y)
        let bottomLeftPoint = CGPointMake(frame.origin.x, frame.origin.y + frame.height)
        let bottomRightPoint = CGPointMake(frame.origin.x + frame.width, frame.origin.y + frame.height)
        
        if(inside) {
            if(!path.containsPoint(topLeftPoint)
                || !path.containsPoint(topRightPoint)
                || !path.containsPoint(bottomLeftPoint)
                || !path.containsPoint(bottomRightPoint)) {
                    return false
            }
        }
        
        if(!inside) {
            if(path.containsPoint(topLeftPoint)
                || path.containsPoint(topRightPoint)
                || path.containsPoint(bottomLeftPoint)
                || path.containsPoint(bottomRightPoint)) {
                    return false
            }
        }
        
        return true
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

