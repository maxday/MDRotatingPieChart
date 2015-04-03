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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        slicesData = [Data(myValue: 50,myColor: "1ABC9C"), Data(myValue: 70,myColor: "9B59B6"), Data(myValue: 400,myColor: "F1C40F"), Data(myValue: 20,myColor: "2ECC71"), Data(myValue: 40,myColor: "3498DB"), Data(myValue: 150,myColor: "E74C3C")]
        
        
        turn.delegate = self
        turn.datasource = self
        
        turn.build()

        view.addSubview(turn)

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
    
    func numberOfSlices() -> Int {
        return slicesData.count
    }
    
    
    
    
    
    
    


}

