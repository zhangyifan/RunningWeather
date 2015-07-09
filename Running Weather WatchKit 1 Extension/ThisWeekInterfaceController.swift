//
//  ThisWeekInterfaceController.swift
//  Running Weather
//
//  Created by Yifan Zhang on 6/27/15.
//  Copyright © 2015 Yifan Zhang. All rights reserved.
//

import WatchKit
import Foundation


class ThisWeekInterfaceController: WKInterfaceController {

    @IBOutlet var weekTable: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        //Set up week table
        weekTable.setNumberOfRows(8, withRowType: "weekTableRowController")
        
        /*Checking if global variables and functions work
        var array = hourlyWeatherArr as NSArray
        
        var string = TodayInterfaceController.appendDescriptions(array)*/
        
        print("Week page launched")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
