//
//  ViewController.swift
//  MDPie
//
//  Created by got2bex on 2015-04-02.
//  Copyright (c) 2015 MD. All rights reserved.
//

import UIKit

class ViewController: UIViewController, TurnDelegate, TurnDataSource {
    
    
    
    var slicesData:Array<Data> = Array<Data>()
     
    let turn = Turn(frame: CGRectMake(0, 0, 600, 600))
    
    var i=0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        slicesData = [Data(myValue: 50,myColor: "1ABC9C", myLabel:"Apple"), Data(myValue: 70,myColor: "9B59B6", myLabel:"Banana"), Data(myValue: 400,myColor: "F1C40F", myLabel:"Coconut"), Data(myValue: 20, myColor: "2ECC71", myLabel:"Strawberry"), Data(myValue: 40,myColor: "3498DB", myLabel:"Mango"), Data(myValue: 150,myColor: "E74C3C", myLabel:"Raspberry")]
        
        
        turn.delegate = self
        turn.datasource = self
        
        turn.build()

        view.addSubview(turn)
        
    
        let addBtn = UIButton(frame: CGRectMake(650, 100, 400, 200))
        addBtn.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        addBtn.setTitle("Add slice", forState: UIControlState.Normal)
        addBtn.addTarget(self, action: "addSlice", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(addBtn)
        
        let removeBtn = UIButton(frame: CGRectMake(650, 550, 400, 200))
        removeBtn.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        removeBtn.setTitle("Remove slice", forState: UIControlState.Normal)
        removeBtn.addTarget(self, action: "removeSlice", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(removeBtn)
        
        

    }

    func addSlice()  {
        slicesData.append(Data(myValue:50, myColor:slicesData[++i % slicesData.count-1].color, myLabel:"A new fruit"))
        turn.build()
        
        
        
        
    }
    
    func removeSlice()  {
        slicesData.removeLast()
        turn.build()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
  
 
    
    func didOpenSliceAtIndex(index: Int) {
        println("Open slice at")
        println(index)
    }
    
    func didCloseSliceAtIndex(index: Int) {
        println("Close slice at")
        println(index)
    }
    
    func willOpenSliceAtIndex(index: Int) {
        println("Will open slice at")
        println(index)
    }
    
    func willCloseSliceAtIndex(index: Int) {
        println("Will close slice at")
        println(index)
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

