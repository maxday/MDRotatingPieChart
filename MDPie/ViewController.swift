//
//  ViewController.swift
//  MDPie
//
//  Created by got2bex on 2015-04-02.
//  Copyright (c) 2015 MD. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
     
    let turn = Turn(frame: CGRectMake(0, 0, 600, 600))
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        turn.data = [Data(myValue: 50,myColor: "1ABC9C"), Data(myValue: 70,myColor: "9B59B6"), Data(myValue: 100,myColor: "F1C40F"), Data(myValue: 20,myColor: "2ECC71"), Data(myValue: 40,myColor: "3498DB"), Data(myValue: 150,myColor: "E74C3C")]
        
        
        turn.build()
        
        view.addSubview(turn)
       

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
        
    
    
    
    
    


}

