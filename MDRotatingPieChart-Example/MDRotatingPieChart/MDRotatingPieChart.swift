//
//  MDRotatingPieChart.swift
//  MDRotatingPieChart
//
//  Created by Maxime DAVID on 2015-04-03.
//  Copyright (c) 2015 Maxime DAVID. All rights reserved.
//

import UIKit
import QuartzCore
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


/**
*  DataSource : all methods are mandatory to build the pie chart
*/
protocol MDRotatingPieChartDataSource {
    
    /**
    Gets slice color
    :param: index slice index in your data array
    :returns: the color of the slice at the given index
    */
    func colorForSliceAtIndex(_ index:Int) -> UIColor
    
    /**
    Gets slice value
    :param: index slice index in your data array
    :returns: the value of the slice at the given index
    */
    func valueForSliceAtIndex(_ index:Int) -> CGFloat
    
    /**
    Gets slice label
    :param: index slice index in your data array
    :returns: the label of the slice at the given index
    */
    func labelForSliceAtIndex(_ index:Int) -> String
    
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
    @objc optional func willOpenSliceAtIndex(_ index:Int)
    
    /**
    Triggered when a slice is going to be closed
    :param: index slice index in your data array
    */
    @objc optional func willCloseSliceAtIndex(_ index:Int)
    
    /**
    Triggered when a slice has just finished opening
    :param: index slice index in your data array
    */
    @objc optional func didOpenSliceAtIndex(_ index:Int)
    
    /**
    Triggered when a slice has just finished closing
    :param: index slice index in your data array
    */
    @objc optional func didCloseSliceAtIndex(_ index:Int)
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
    var displayValueTypeInSlices:DisplayValueType = .percent
    //label format in center
    var displayValueTypeCenter:DisplayValueType = .label

    //font to use in slices
    var fontTextInSlices:UIFont = UIFont(name: "Arial", size: 12)!
    //font to use in the center
    var fontTextCenter:UIFont = UIFont(name: "Arial", size: 10)!
    
    //tells whether or not the pie should be animated
    var enableAnimation = true
    //if so, this describes the duration of the animation
    var animationDuration:CFTimeInterval = 0.5
    
    //number formatter to use
    var nf = NumberFormatter()
    
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
    var pieChartCenter:CGPoint = CGPoint.zero
    
    //current slice translation
    var currentTr:CGPoint = CGPoint.zero
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //saves the center (since the frame will change after some rotations)
        pieChartCenter.x = frame.width/2
        pieChartCenter.y = frame.height/2
        
        //builds and adds the centered label
        labelCenter.frame = CGRect.zero
        labelCenter.center = CGPoint(x: pieChartCenter.x, y: pieChartCenter.y)
        labelCenter.textColor = UIColor.black
        labelCenter.textAlignment = NSTextAlignment.center
        addSubview(labelCenter)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }

    /**
    Resets the pie chart
    */
    func reset() {
        self.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
        
        labelCenter.transform = self.transform
        labelCenter.text = ""
        
        for currentShape in slicesArray {
            currentShape.shapeLayer.removeFromSuperlayer()
        }
        slicesArray.removeAll(keepingCapacity: false)
    }
    
    /**
    Contructs the pie chart
    */
    func build() {

        guard let dataSrc = datasource else {
            print("Did you forget to set your datasource ?")
            return
        }
        
        reset()
        
        let total = computeTotal()
        
        var currentStartAngle:CGFloat = 0
        var angleSum:CGFloat = 0
        
        for index in 0 ..< dataSrc.numberOfSlices() {
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
    func prepareSlice(_ angleSum:inout CGFloat, currentStartAngle:inout CGFloat, total:CGFloat, index:Int) {
    
        let currentValue  = datasource.valueForSliceAtIndex(index)
        let currentAngle = currentValue * 2 * .pi / total
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
        
        self.layer.insertSublayer(slice.shapeLayer, at:0)
        
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
    func getMiddlePoint(_ angleSum:CGFloat) -> CGPoint {
        
        let middleRadiusX = properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2
        let middleRadiusY = properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2
        
        return CGPoint(
            x: cos(angleSum) * middleRadiusX + pieChartCenter.x,
            y: sin(angleSum) * middleRadiusY + pieChartCenter.y
        )
    }
    
    /**
    Creates the label
    :param: angleSum sum of already prepared slices
    :param: slice    the slice
    :returns: a new label
    */
    func createLabel(_ angleSum:CGFloat, slice:Slice) -> UILabel {
        let label = UILabel(frame: CGRect.zero)
        
        label.center = getMiddlePoint(angleSum)
        
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.black
        label.font = properties.fontTextInSlices
        
        label.text = formatFromDisplayValueType(slice, displayType: properties.displayValueTypeInSlices)
        
        let tmpCenter = label.center
        label.sizeToFit()
        label.center = tmpCenter
        label.isHidden = !frameFitInPath(label.frame, path: slice.paths.bezierPath, inside:true)
        return label;
    }
    
    
    /**
    Adds an animation to a slice
    :param: slice the slice to be animated
    */
    func addAnimation(_ slice:Slice) {
        
        let animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        animateStrokeEnd.duration = properties.animationDuration
        animateStrokeEnd.fromValue = 0.0
        animateStrokeEnd.toValue = 1.0
        
        slice.shapeLayer.add(animateStrokeEnd, forKey: "animate stroke end animation")
        CATransaction.commit()
    }
    
    /**
    Computes the total value of slices
    :returns: the total value
    */
    func computeTotal() -> CGFloat {
        var total:CGFloat = 0
        for index in 0 ..< datasource.numberOfSlices() {
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
    func openSlice(_ index:Int) {
    
        guard let dataSrc = datasource else {
            print("Did you forget to set your datasource ?")
            return
        }
        
        //save the transformation
        oldTransform = slicesArray[index].shapeLayer.transform
        
        //update the label
        labelCenter.text = formatFromDisplayValueType(slicesArray[index], displayType: properties.displayValueTypeCenter)
        let centerTmp = labelCenter.center
        labelCenter.sizeToFit()
        labelCenter.center = centerTmp
        
        labelCenter.isHidden = false
        
        for cpt in 0 ..< dataSrc.numberOfSlices() {
            if(!frameFitInPath(labelCenter.frame, path: slicesArray[cpt].paths.bezierPath, inside:false)) {
                labelCenter.isHidden = true
                break;
            }
        }
        
        //move
        var angleSum:CGFloat = 0
        for i in 0..<index {
            angleSum += slicesArray[i].angle
        }
        angleSum += slicesArray[index].angle/2.0
        
        let transX:CGFloat = properties.expand*cos(angleSum)
        let transY:CGFloat = properties.expand*sin(angleSum)
        
        let translate = CATransform3DMakeTranslation(transX, transY, 0);
        currentTr = CGPoint(x: -transX, y: -transY)
        
        delegate?.willOpenSliceAtIndex!(index)
        slicesArray[index].shapeLayer.transform = translate
        
        delegate?.didOpenSliceAtIndex!(index)
        
        currentSelected = index
    }
    
    /**
    Computes the logic of opening/closing slices
    :param: index the slice index
    */
    func openCloseSlice(_ index:Int)  {
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
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        //makes sure to reset the drag event
        hasBeenDraged = false

        let currentPoint = touch.location(in: self)
      
        if ignoreThisTap(currentPoint) {
            return false;
        }
        
        let deltaX = currentPoint.x - pieChartCenter.x
        let deltaY = currentPoint.y - pieChartCenter.y

        delta = atan2(deltaY,deltaX)
        return true
    }
    
    //UIControl implementation
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        //drag event detected, we won't open/close any slices
        hasBeenDraged = true
        let currentPoint = touch.location(in: self)
        
        let deltaX = currentPoint.x - pieChartCenter.x
        let deltaY = currentPoint.y - pieChartCenter.y
        
        let ang = atan2(deltaY,deltaX);
        let angleDifference = delta - ang
        
        //rotate !
        self.transform = self.transform.rotated(by: -angleDifference)
        
        //reset labels
        let savedTransform = slicesArray[0].labelObj?.transform
        let savedTransformCenter = labelCenter.transform
        
        for slice in slicesArray  {
            if(slice.labelObj != nil)  {
                slice.labelObj?.transform = savedTransform!.rotated(by: angleDifference)
            }
        }
        
        labelCenter.transform = savedTransformCenter.rotated(by: angleDifference)
        
        return true;
    }
    
    //UIControl implementation
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        //don't open/close slice if a drag event has been detected
        if(hasBeenDraged) {
            return
        }
        
        let currentPoint = touch?.location(in: self)

        var cpt = 0
        for currentPath in slicesArray {
            
            //click on a slice
            if currentPath.paths.bezierPath.contains(currentPoint!) {
                openCloseSlice(cpt)
                return
            }
            
            //click on the current opened slice
            if currentPath.paths.bezierPath.contains(CGPoint(x: (currentPoint?.x)!+currentTr.x, y: (currentPoint?.y)!+currentTr.y)) && cpt == currentSelected {
                openCloseSlice(cpt)
                return
            }
            
            cpt += 1
        }
    }

    
    /**
    Checks whether or not a tap shoud be dismissed (too close from the center or too far)
    :param: currentPoint current tapped point
    :returns: true if it should be ignored, false otherwise
    */
    func ignoreThisTap(_ currentPoint:CGPoint) -> Bool {
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
    func createSlice(_ start:CGFloat, end:CGFloat, color:UIColor, label:String, value:CGFloat, percent:CGFloat) -> Slice {
        
        let mask = CAShapeLayer()
        
        mask.frame = self.frame
        let path = computeDualPath(start, end: end)
        mask.path = path.animationBezierPath.cgPath
        mask.lineWidth = properties.bigRadius - properties.smallRadius
        mask.strokeColor = color.cgColor
        mask.fillColor = color.cgColor
        
        let slice = Slice(myPaths: path, myShapeLayer: mask, myAngle: end-start, myLabel:label, myValue:value, myPercent:percent)

        return slice;
    }
    
    
    /**
    Formats the text
    :param: slice       a slice
    :param: displayType an enum representing a display value type
    :returns: a formated text ready to be displayed
    */
    func formatFromDisplayValueType(_ slice:Slice, displayType:DisplayValueType) -> String {
    
        var toRet = ""
        
        switch(displayType) {
        case .value :
            toRet = "\(slice.value)"
            break
        case .percent :
            toRet = "\(properties.nf.string(from: NSNumber(value: Float(slice.percent)))!)%"
            break
        case .label :
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
    func computeAnimationPath(_ start:CGFloat, end:CGFloat) -> UIBezierPath {
        let animationPath = UIBezierPath()
        
        animationPath.move(to: getMiddlePoint(start))
        
        animationPath.addArc(withCenter: pieChartCenter, radius: (properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2), startAngle: start, endAngle: end, clockwise: false)
        
        animationPath.addArc(withCenter: pieChartCenter, radius: (properties.smallRadius + (properties.bigRadius-properties.smallRadius)/2), startAngle: end, endAngle: start, clockwise: true)

        return animationPath;
    }

    /**
    Computes and returns a pair of UIBezierPaths
    :param: start start angle
    :param: end   end angle
    :returns: the pair
    */
    func computeDualPath(_ start:CGFloat, end:CGFloat) -> DualPath {
        
        let pathRef = computeAnimationPath(start, end: end)
        
        let other = CGPath(__byStroking: pathRef.cgPath, transform: nil, lineWidth: properties.bigRadius-properties.smallRadius, lineCap: .butt, lineJoin: .miter, miterLimit: 1)
        
        let ok = UIBezierPath(cgPath: other!)
      
        return DualPath(myBezierPath: ok, myAnimationBezierPath: pathRef)
    }
    
    
    /**
    Tells whether or not the given frame is overlapping with a shape (delimited by an UIBeizerPath)
    :param: frame  the frame
    :param: path   the path
    :param: inside tells whether or not the path should be inside the path
    :returns: true if it fits, false otherwise
    */
    func frameFitInPath(_ frame:CGRect, path:UIBezierPath, inside:Bool) -> Bool {
        
        let topLeftPoint = frame.origin
        let topRightPoint = CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y)
        let bottomLeftPoint = CGPoint(x: frame.origin.x, y: frame.origin.y + frame.height)
        let bottomRightPoint = CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y + frame.height)
        
        if(inside) {
            if(!path.contains(topLeftPoint)
                || !path.contains(topRightPoint)
                || !path.contains(bottomLeftPoint)
                || !path.contains(bottomRightPoint)) {
                    return false
            }
        }
        
        if(!inside) {
            if(path.contains(topLeftPoint)
                || path.contains(topRightPoint)
                || path.contains(bottomLeftPoint)
                || path.contains(bottomRightPoint)) {
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
    case percent
    case value
    case label
}

