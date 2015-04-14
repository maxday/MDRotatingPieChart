//
//  ViewController.swift
//  MDPie
//
//  Created by Maxime DAVID on 2015-04-03.
//  Copyright (c) 2015 Maxime DAVID. All rights reserved.
//

import UIKit


class ViewController: UIViewController, TurnDelegate, TurnDataSource {
    
    var slicesData:Array<Data> = Array<Data>()
     
    let turn = Turn(frame: CGRectMake(0, 0, 320, 320))

    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.addSubview(turn)
        
        slicesData = [
            Data(myValue: 52.4, myColor: UIColor(red: 0.16, green: 0.73, blue: 0.61, alpha: 1), myLabel:"Apple"),
            Data(myValue: 70.5, myColor: UIColor(red: 0.23, green: 0.6, blue: 0.85, alpha: 1), myLabel:"Banana"),
            Data(myValue: 50, myColor: UIColor(red: 0.6, green: 0.36, blue: 0.71, alpha: 1), myLabel:"Coconut"),
            Data(myValue: 60.1, myColor: UIColor(red: 0.46, green: 0.82, blue: 0.44, alpha: 1), myLabel:"Raspberry"),
            Data(myValue: 40.9, myColor: UIColor(red: 0.94, green: 0.79, blue: 0.19, alpha: 1), myLabel:"Strawberry"),
            Data(myValue: 40.7, myColor: UIColor(red: 0.89, green: 0.49, blue: 0.19, alpha: 1), myLabel:"Mango")]
        
        turn.delegate = self
        turn.datasource = self
    
        var properties = Properties()

        properties.smallRadius = 50
        properties.bigRadius = 100
        properties.expand = 25
    
        
        properties.displayValueTypeInSlices = .Percent
        properties.displayValueTypeCenter = .Label
        
        properties.fontTextInSlices = UIFont(name: "Arial", size: 24)!
        
        var nf = NSNumberFormatter()
        nf.groupingSize = 3
        nf.maximumSignificantDigits = 2
        nf.minimumSignificantDigits = 2
        
        properties.nf = nf
        
        turn.properties = properties

        let refreshBtn = UIButton(frame: CGRectMake(650, 550, 200, 50))
        refreshBtn.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        refreshBtn.setTitle("Refresh", forState: UIControlState.Normal)
        refreshBtn.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(refreshBtn)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }

    func refresh()  {
        turn.build()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didOpenSliceAtIndex(index: Int) {
        println("Open slice at \(index)")
    }
    
    func didCloseSliceAtIndex(index: Int) {
        println("Close slice at \(index)")
    }
    
    func willOpenSliceAtIndex(index: Int) {
        println("Will open slice at \(index)")
    }
    
    func willCloseSliceAtIndex(index: Int) {
        println("Will close slice at \(index)")
    }
    
    func colorForSliceAtIndex(index:Int) -> UIColor {
        return slicesData[index].color
    }
    
    func valueForSliceAtIndex(index:Int) -> CGFloat {
        return slicesData[index].value
    }
    
    func labelForSliceAtIndex(index:Int) -> String {
        return slicesData[index].label
    }
    
    func numberOfSlices() -> Int {
        return slicesData.count
    }
    

}


class Data {
    var value:CGFloat
    var color:UIColor = UIColor.grayColor()
    var label:String = ""
    
    init(myValue:CGFloat, myColor:UIColor, myLabel:String) {
        value = myValue
        color = myColor
        label = myLabel
    }
}

