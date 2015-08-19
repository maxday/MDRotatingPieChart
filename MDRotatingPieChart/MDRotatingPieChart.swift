//
//  MDRotatingPieChart.swift
//  MDRotatingPieChart
//
//  Created by Maxime DAVID on 2015-04-03.
//  Copyright (c) 2015 Maxime DAVID. All rights reserved.
//

import UIKit
import QuartzCore

/**
*  DataSource : all methods are mandatory to build the pie chart
*/
protocol MDRotatingPieChartDataSource {
    
    /**
    Gets slice color
    :param: index slice index in your data array
    :returns: the color of the slice at the given index
    */
    func colorForSliceAtIndex(index:Int) -> UIColor
    
    /**
    Gets slice value
    :param: index slice index in your data array
    :returns: the value of the slice at the given index
    */
    func valueForSliceAtIndex(index:Int) -> CGFloat
    
    /**
    Gets slice label
    :param: index slice index in your data array
    :returns: the label of the slice at the given index
    */
    func labelForSliceAtIndex(index:Int) -> String
    
    /**
    Gets number of slices
    :param: index slice index in your data array
    :returns: the number of slices
    */
    func numberOfSlices() -> Int
}

/**
*  Delegate : all methods are optional
*/
@objc protocol MDRotatingPieChartDelegate {
    
    /**
    Triggered when a slice is going to be opened
    :param: index slice index in your data array
    */
    optional func willOpenSliceAtIndex(index:Int)
    
    /**
    Triggered when a slice is going to be closed
    :param: index slice index in your data array
    */
    optional func willCloseSliceAtIndex(index:Int)
    
    /**
    Triggered when a slice has just finished opening
    :param: index slice index in your data array
    */
    optional func didOpenSliceAtIndex(index:Int)
    
    /**
    Triggered when a slice has just finished closing
    :param: index slice index in your data array
    */
    optional func didCloseSliceAtIndex(index:Int)
}

/**
*  Properties, to customize your pie chart (actually this is not mandatory to use this structure since all values have a default behaviour)
*/
struct Properties {
    //smallest of both radius
    var smallRadius:CGFloat = 50
    //biggest of both radius
    var bigRadius:CGFloat = 120
    //value of the translation when a slice is openned
    var expand:CGFloat = 25
    
    //label format in slices
    var displayValueTypeInSlices:DisplayValueType = .Percent
    //label format in center
    var displayValueTypeCenter:DisplayValueType = .Label

    //font to use in slices
    var fontTextInSlices:UIFont = UIFont(name: "Arial", size: 12)!
    //font to use in the center
    var fontTextCenter:UIFont = UIFont(name: "Arial", size: 10)!
    
    //tells whether or not the pie should be animated
    var enableAnimation = true
    //if so, this describes the duration of the animation
    var animationDuration:CFTimeInterval = 0.5
    
    //number formatter to use
    var nf = NSNumberFormatter()
    
    init() {
        nf.groupingSize = 3
        nf.maximumSignificantDigits = 3
        nf.minimumSignificantDigits = 3
    }
}

class MDRotatingPieChart: UIControl {
    
    //stores the slices
    var slicesArray:Array<Slice> = Array<Slice>()
    
    var delta:CGFloat = 0
    //properties configuration
    var properties = Properties()
    
    //datasource and delegate
    var datasource:MDRotatingPieChartDataSource!
    var delegate:MDRotatingPieChartDelegate!
    
    //tells whether or not a drag action has been done, is so, do not open or close a slice
    var hasBeenDraged:Bool = false
    
    //saves the previous transfomation
    var oldTransform:CATransform3D?
    
    //saves the selected slice index
    var currentSelected:Int = -1
    
    //label
    var labelCenter:UILabel = UILabel()

    //saves the center of the pie chart
    var pieChartCenter:CGPoint = CGPointZero
    
    //current slice translation
    var currentTr:CGPoint = CGPointZero
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        //saves the center (since the frame will change after some rotations)
        pieChartCenter.x = frame.width/2
        pieChartCenter.y = frame.height/2
        
        //builds and adds the centered label
        labelCenter.frame = CGRectZero
        labelCenter.center = CGPointMake(pieChartCenter.x, pieChartCenter.y)
        labelCenter.textColor = UIColor.blackColor()
        labelCenter.textAlignment = NSTextAlignment.Center
        addSubview(labelCenter)
    }

    /**
    Resets the pie chart
    */
    func reset() {
        self.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0)
        
        labelCenter.transform = self.transform
        labelCenter.text = ""
        
        for currentShape in slicesArray {
            currentShape.shapeLayer.removeFromSuperlayer()
        }
        slicesArray.removeAll(keepCapacity: false)
    }
    
    /**
    Contructs the pie chart
    */
    func build() {

        if(datasource == nil) {
            println("Did you forget to set your datasource ?")
            return
        }
        
        reset()
        
        var total = computeTotal()
        
        var currentStartAngle:CGFloat = 0
        var angleSum:CGFloat = 0
        
        for (var index = 0; index < datasource?.numberOfSlices(); ++index) {
            prepareSlice(&angleSum, currentStartAngle: &currentStartAngle, total: total, index: index)
        }
    }
    
    /**
    Prepares the slice and adds it to the pie chart
    :param: angleSum          sum of already prepared slices
    :param: currentStartAngle start angle
    :param: total             total value of the pie chart
    :param: index             slice index
    */
    func prepareSlice(inout angleSum:CGFloat, inout currentStartAngle:CGFloat, total:CGFloat, index:Int) {
    
        let currentValue  = datasource.valueForSliceAtIndex(index)
        let currentAngle = currentValue * 2 * CGFloat(M_PI) / total
        let currentColor = datasource.colorForSliceAtIndex(index)
        let currentLabel = datasource.labelForSliceAtIndex(index)
        
        //create slice
        let slice = createSlice(currentStartAngle, end: CGFloat(currentStartAngle - currentAngle), color:currentColor, label:currentLabel, value:currentValue, percent:100 * currentValue/total)
        slicesArray.append(slice)
        
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
    
    /**
    Retrieves the middle point of a slice (to set the label)
    :param: angleSum sum of already prepared slices
    :returns: the middle point
    */
    func getMiddlePoint(angleSum:CGFloat) -> CGPoint {
        
        let middleRadiusX = properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2
        let middleRadiusY = properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2
        
        return CGPointMake(
            cos(angleSum) * middleRadiusX + pieChartCenter.x,
            sin(angleSum) * middleRadiusY + pieChartCenter.y
        )
    }
    
    /**
    Creates the label
    :param: angleSum sum of already prepared slices
    :param: slice    the slice
    :returns: a new label
    */
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
    
    /**
    Closes a slice
    */
    func closeSlice() {
        delegate?.willCloseSliceAtIndex!(currentSelected)
        slicesArray[currentSelected].shapeLayer.transform = oldTransform!
        delegate?.didCloseSliceAtIndex!(currentSelected)
        labelCenter.text = ""
    }
    
    /**
    Opens a slice
    
    :param: index the slice index in the data array
    */
    func openSlice(index:Int) {
    
        //save the transformation
        oldTransform = slicesArray[index].shapeLayer.transform
        
        //update the label
        labelCenter.text = formatFromDisplayValueType(slicesArray[index], displayType: properties.displayValueTypeCenter)
        let centerTmp = labelCenter.center
        labelCenter.sizeToFit()
        labelCenter.center = centerTmp
        
        labelCenter.hidden = false
        var cpt = 0;
        for (; cpt < datasource?.numberOfSlices(); ++cpt) {
            if(!frameFitInPath(labelCenter.frame, path: slicesArray[cpt].paths.bezierPath, inside:false)) {
                labelCenter.hidden = true
                break;
            }
        }
        
        //move
        var i=0
        var angleSum:CGFloat = 0
        for(i=0; i<index; ++i) {
            angleSum += slicesArray[i].angle
        }
        angleSum += slicesArray[index].angle/2.0
        
        let transX:CGFloat = properties.expand*cos(angleSum)
        let transY:CGFloat = properties.expand*sin(angleSum)
        
        let translate = CATransform3DMakeTranslation(transX, transY, 0);
        currentTr = CGPointMake(-transX, -transY)
        
        delegate?.willOpenSliceAtIndex!(index)
        slicesArray[index].shapeLayer.transform = translate
        
        delegate?.didOpenSliceAtIndex!(index)
        
        currentSelected = index
    }
    
    /**
    Computes the logic of opening/closing slices
    :param: index the slice index
    */
    func openCloseSlice(index:Int)  {
        // nothing is opened, let's opened one slice
        if(currentSelected == -1)  {
            openSlice(index)

        }
        // here a slice is opened, so let's close it before
        else {
            closeSlice()
            //if the same slice is chosen, no need to open
            if(currentSelected == index) {
                currentSelected = -1
            }
            else {
                openSlice(index)
            }
            
        }
    }
    
    
    //UIControl implementation
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        //makes sure to reset the drag event
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
    
    //UIControl implementation
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        //drag event detected, we won't open/close any slices
        hasBeenDraged = true
        let currentPoint = touch.locationInView(self)
        
        let deltaX = currentPoint.x - pieChartCenter.x
        let deltaY = currentPoint.y - pieChartCenter.y
        
        let ang = atan2(deltaY,deltaX);
        let angleDifference = delta - ang
        
        //rotate !
        self.transform = CGAffineTransformRotate(self.transform, -angleDifference)
        
        //reset labels
        let savedTransform = slicesArray[0].labelObj?.transform
        let savedTransformCenter = labelCenter.transform
        
        for slice in slicesArray  {
            if(slice.labelObj != nil)  {
                slice.labelObj?.transform = CGAffineTransformRotate(savedTransform!, angleDifference)
            }
        }
        
        labelCenter.transform = CGAffineTransformRotate(savedTransformCenter, angleDifference)
        
        return true;
    }
    
    //UIControl implementation
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        //don't open/close slice if a drag event has been detected
        if(hasBeenDraged) {
            return
        }
        
        let currentPoint = touch.locationInView(self)

        var cpt = 0
        for currentPath in slicesArray {
            
            //click on a slice
            if currentPath.paths.bezierPath.containsPoint(currentPoint) {
                openCloseSlice(cpt)
                return
            }
            
            //click on the current opened slice
            if currentPath.paths.bezierPath.containsPoint(CGPointMake(currentPoint.x+currentTr.x, currentPoint.y+currentTr.y)) && cpt == currentSelected {
                openCloseSlice(cpt)
                return
            }
            
            cpt++
        }
    }

    
    /**
    Checks whether or not a tap shoud be dismissed (too close from the center or too far)
    :param: currentPoint current tapped point
    :returns: true if it should be ignored, false otherwise
    */
    func ignoreThisTap(currentPoint:CGPoint) -> Bool {
        let dx = currentPoint.x - pieChartCenter.x
        let dy = currentPoint.y - pieChartCenter.y
        let sqroot = sqrt(dx*dx + dy*dy)
        return sqroot < properties.smallRadius || sqroot > (properties.bigRadius + properties.expand + (properties.bigRadius-properties.smallRadius)/2)
    }
    
    /**
    Creates a slice
    :param: start   start angle
    :param: end     end angle
    :param: color   color
    :param: label   label
    :param: value   value
    :param: percent percent value
    :returns: a new slice
    */
    func createSlice(start:CGFloat, end:CGFloat, color:UIColor, label:String, value:CGFloat, percent:CGFloat) -> Slice {
        
        var mask = CAShapeLayer()
        
        mask.frame = bounds
        let path = computeDualPath(start, end: end)
        mask.path = path.animationBezierPath.CGPath
        mask.lineWidth = properties.bigRadius - properties.smallRadius
        mask.strokeColor = color.CGColor
        mask.fillColor = color.CGColor
        
        var slice = Slice(myPaths: path, myShapeLayer: mask, myAngle: end-start, myLabel:label, myValue:value, myPercent:percent)

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
    
    
    
    /**
    Computes and returns a path representing a slice
    
    :param: start start angle
    :param: end   end angle
    
    :returns: the UIBezierPath build
    */
    func computeAnimationPath(start:CGFloat, end:CGFloat) -> UIBezierPath {
        var animationPath = UIBezierPath()
        
        animationPath.moveToPoint(getMiddlePoint(start))
        
        animationPath.addArcWithCenter(pieChartCenter, radius: (properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2), startAngle: start, endAngle: end, clockwise: false)
        
        animationPath.addArcWithCenter(pieChartCenter, radius: (properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2), startAngle: end, endAngle: start, clockwise: true)

        return animationPath;
    }

    /**
    Computes and returns a pair of UIBezierPaths
    :param: start start angle
    :param: end   end angle
    :returns: the pair
    */
    func computeDualPath(start:CGFloat, end:CGFloat) -> DualPath {
        
        let pathRef = computeAnimationPath(start, end: end)
        
        let other = CGPathCreateCopyByStrokingPath(pathRef.CGPath, nil, properties.bigRadius-properties.smallRadius, kCGLineCapButt, kCGLineJoinMiter, 1)
        
        let ok = UIBezierPath(CGPath: other)
      
        return DualPath(myBezierPath: ok, myAnimationBezierPath: pathRef)
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

/**
*  Stores both BezierPaths, one for the animation and the "real one"
*/
struct DualPath {
    var bezierPath:UIBezierPath
    var animationBezierPath:UIBezierPath
    
    init(myBezierPath:UIBezierPath, myAnimationBezierPath:UIBezierPath) {
        self.bezierPath = myBezierPath
        self.animationBezierPath = myAnimationBezierPath
    }
}

/**
*  Stores a slice
*/
struct Slice {
    var paths:DualPath
    var shapeLayer:CAShapeLayer
    var angle:CGFloat
    var label:String
    var value:CGFloat
    var labelObj:UILabel?
    var percent:CGFloat
    
    init(myPaths:DualPath, myShapeLayer:CAShapeLayer, myAngle:CGFloat, myLabel:String, myValue:CGFloat, myPercent:CGFloat) {
        self.paths = myPaths
        self.shapeLayer = myShapeLayer
        self.angle = myAngle
        self.label = myLabel
        self.value = myValue
        self.percent = myPercent
    }
}

/**
Helper enum to format the labels

- Percent: the percent value
- Value:   the raw value
- Label:   the description
*/
enum DisplayValueType {
    case Percent
    case Value
    case Label
}

