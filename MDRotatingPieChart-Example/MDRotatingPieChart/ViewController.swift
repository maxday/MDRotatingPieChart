//
//  ViewController.swift
//  MDRotatingPieChart
//
//  Created by Maxime DAVID on 2015-04-03.
//  Copyright (c) 2015 Maxime DAVID. All rights reserved.
//

import UIKit


class ViewController: UIViewController, MDRotatingPieChartDelegate, MDRotatingPieChartDataSource {
    
    var slicesData:Array<Data> = Array<Data>()
    
    var pieChart:MDRotatingPieChart!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        pieChart = MDRotatingPieChart(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width))
        
        slicesData = [
            Data(myValue: 10, myColor: UIColor(red: 0.16, green: 0.73, blue: 0.61, alpha: 1), myLabel:"Apple"),
            Data(myValue: 15, myColor: UIColor(red: 0.23, green: 0.6, blue: 0.85, alpha: 1), myLabel:"Banana"),
            Data(myValue: 25, myColor: UIColor(red: 0.6, green: 0.36, blue: 0.71, alpha: 1), myLabel:"Coconut"),
            Data(myValue: 20, myColor: UIColor(red: 0.46, green: 0.82, blue: 0.44, alpha: 1), myLabel:"Raspberry"),
            Data(myValue: 10, myColor: UIColor(red: 0.94, green: 0.79, blue: 0.19, alpha: 1), myLabel:"Cherry"),
            Data(myValue: 5, myColor: UIColor(red: 0.89, green: 0.49, blue: 0.19, alpha: 1), myLabel:"Mango")]
        
        pieChart.delegate = self
        pieChart.datasource = self
    
        view.addSubview(pieChart)
        
        /* 
        Here you can dig into some properties
        -------------------------------------
        */
        var properties = MDRotatingPieChart.Properties()

        properties.smallRadius = 50
        properties.bigRadius = 120
        properties.expand = 25
    
        
        properties.displayValueTypeInSlices = .Percent
        properties.displayValueTypeCenter = .Label
        
        properties.fontTextInSlices = UIFont(name: "Arial", size: 12)!
        properties.fontTextCenter = UIFont(name: "Arial", size: 10)!

        properties.enableAnimation = true
        properties.animationDuration = 0.5
        
        
        let nf = NumberFormatter()
        nf.groupingSize = 3
        nf.maximumSignificantDigits = 2
        nf.minimumSignificantDigits = 2
        
        properties.nf = nf
        
        pieChart.properties = properties
        
        

        let title = UILabel(frame: CGRect(x: 0, y: view.frame.width, width: view.frame.width, height: 100))
        title.text = "@xouuox\n\nMDRotatingPieChart demo \nclick on a slice, or drag the pie :)"
        title.textAlignment = .center
        title.numberOfLines = 4
        view.addSubview(title)
        
        let refreshBtn = UIButton(frame: CGRect(x: (view.frame.width-200)/2, y: view.frame.width+100, width: 200, height: 50))
        refreshBtn.setTitleColor(UIColor.white, for: UIControl.State())
        refreshBtn.setTitle("Refresh", for: UIControl.State())
        refreshBtn.addTarget(self, action: #selector(ViewController.refresh), for: UIControl.Event.touchUpInside)
        refreshBtn.backgroundColor = UIColor.lightGray
        view.addSubview(refreshBtn)
    }
    
    //Delegate
    //some sample messages when actions are triggered (open/close slices)
    func didOpenSliceAtIndex(index: Int) {
        print("Open slice at \(index)")
    }
    
    func didCloseSliceAtIndex(index: Int) {
        print("Close slice at \(index)")
    }
    
    func willOpenSliceAtIndex(index: Int) {
        print("Will open slice at \(index)")
    }
    
    func willCloseSliceAtIndex(index: Int) {
        print("Will close slice at \(index)")
    }
    
    //Datasource
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }
    
    @objc func refresh()  {
        pieChart.build()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


class Data {
    var value:CGFloat
    var color:UIColor = UIColor.gray
    var label:String = ""
    
    init(myValue:CGFloat, myColor:UIColor, myLabel:String) {
        value = myValue
        color = myColor
        label = myLabel
    }
}

