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
    
    //Function to pick the best weather in a given period of time
    class func getBestWeather(startIndex: Int, endIndex: Int) {
        
        //NEED TO FINISH, START AND END ARE FOR WEATHERARRAY TO COMPARE
        for var i = startIndex; i <= endIndex; i++ {
            
            let weatherDict = hourlyWeatherArr[i]
            
            let quality = TodayInterfaceController.assignQuality(weatherDict["temp"]!, humidity: weatherDict["humidity"]!, wind: weatherDict["wind"]! )
            
        }
        
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        //Set up week table
        weekTable.setNumberOfRows(8, withRowType: "weekTableRowController")
        
        if hourlyWeatherArr.count > 0 {
            
            for var i = 0; i < 8; i++ {
                
                let weekRow = self.weekTable.rowControllerAtIndex(i) as! weekTableRowController
                
                let weatherDict = hourlyWeatherArr[i]
                
                let rowTemp = weatherDict["temp"]!
                
                weekRow.tempWeekLabel.setText("\(Int(rowTemp))°")
                
                let rowDT = TodayInterfaceController.convertDT(weatherDict["dt"]!)
                
                weekRow.dayWeekLabel.setText(rowDT.day)
                
                weekRow.hourWeekLabel.setText(rowDT.hour)
                
            }
            
        } else {
            
            print("Weather Array number of rows still zero")
            
        }
        
        print("Week page launched")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
