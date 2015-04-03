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
        
        
       /* let shape = createShape(0, end: CGFloat(-M_PI/3))
        let shape2 = createShape(CGFloat(-M_PI/3), end: CGFloat(-M_PI))
        let shape3 = createShape(CGFloat(-M_PI), end: CGFloat(-5*M_PI/3))
        let shape4 = createShape(CGFloat(-5*M_PI/3), end: CGFloat(-2*M_PI))
        */
        
        
        
        turn.data = [100,56,304,506,304,501,34,200]
        
        
        turn.build()
        
        view.addSubview(turn)
        /*
        turn.layer.insertSublayer(shape, atIndex:0)
        turn.layer.insertSublayer(shape2, atIndex:0)
        turn.layer.insertSublayer(shape3, atIndex:0)
        turn.layer.insertSublayer(shape4, atIndex:0)
        */

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
        
    
    
    
    
    


}

