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
     
    let turn = Turn(frame: CGRectMake(0, 0, 700, 700))
    
    var i=0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        slicesData = [Data(myValue: 50,myColor: "1ABC9C", myLabel:"Apple"), Data(myValue: 70,myColor: "9B59B6", myLabel:"Banana"), Data(myValue: 50,myColor: "F1C40F", myLabel:"Coconut"), Data(myValue: 40, myColor: "2ECC71", myLabel:"Strawberry"), Data(myValue: 40,myColor: "3498DB", myLabel:"Mango"), Data(myValue: 60,myColor: "E74C3C", myLabel:"Raspberry")]
        
        
        turn.delegate = self
        turn.datasource = self
        
        turn.build()

        view.addSubview(turn)
        
    
        let refreshBtn = UIButton(frame: CGRectMake(650, 550, 200, 50))
        refreshBtn.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        refreshBtn.setTitle("Refresh", forState: UIControlState.Normal)
        refreshBtn.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(refreshBtn)
        
        

    }

    func refresh()  {
        turn.build()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
  
 
    
    func didOpenSliceAtIndex(index: Int) {
        //println("Open slice at")
        //println(index)
    }
    
    func didCloseSliceAtIndex(index: Int) {
        //println("Close slice at")
        //println(index)
    }
    
    func willOpenSliceAtIndex(index: Int) {
        //println("Will open slice at")
        //println(index)
    }
    
    func willCloseSliceAtIndex(index: Int) {
        //println("Will close slice at")
        //println(index)
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

