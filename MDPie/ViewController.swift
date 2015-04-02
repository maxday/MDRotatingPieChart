//
//  ViewController.swift
//  MDPie
//
//  Created by got2bex on 2015-04-02.
//  Copyright (c) 2015 MD. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    let smallRadius:CGFloat = 60
    let bigRadius:CGFloat = 100
    
    let centerX:CGFloat = 150
    let centerY:CGFloat = 300
    
    var array:Array<UIBezierPath> = Array<UIBezierPath>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let shape = createShape(0, end: CGFloat(-M_PI/3))
        let shape2 = createShape(CGFloat(-M_PI/3), end: CGFloat(-M_PI))
        let shape3 = createShape(CGFloat(-M_PI), end: CGFloat(-5*M_PI/3))
        let shape4 = createShape(CGFloat(-5*M_PI/3), end: CGFloat(-2*M_PI))
        
        self.view.layer.insertSublayer(shape, atIndex:0)
        
        
        
        self.view.layer.insertSublayer(shape2, atIndex:0)
        self.view.layer.insertSublayer(shape3, atIndex:0)
        self.view.layer.insertSublayer(shape4, atIndex:0)
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var cpt = 0
        let p = touches.anyObject()?.locationInView(self.view)
        for currentPath in array {
            if currentPath.containsPoint(p!) {
                println("yes sir")
                println(cpt)
                return
            }
            cpt++
        }
    }
   
    
    func createShape(start:CGFloat, end:CGFloat) -> CAShapeLayer {
    
        var mask = CAShapeLayer()

        mask.frame = self.view.frame
        let path = drawSlice(start, end: end)
        mask.path = path.CGPath
        mask.lineWidth = 1.0
        mask.strokeColor = UIColor.redColor().CGColor
        mask.fillColor = UIColor.greenColor().CGColor
        
        
        
        
        array.append(path)
        
        return mask;
    
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

