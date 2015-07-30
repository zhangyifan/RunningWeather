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
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if hourlyWeatherArr.count > 0 {
            
            //Set up week table
            Weather.getBestWeather(8, endIndex: 39, closure: {(array: [NSInteger], condition: String)->() in
            
                self.weekTable.setNumberOfRows(array.count, withRowType: "weekTableRowController")
                
                for var i = 0; i < array.count; i++ {
                    
                    let weekRow = self.weekTable.rowControllerAtIndex(i) as! weekTableRowController
                
                    let weatherItem = hourlyWeatherArr[array[i]]
                    
                    weekRow.tempWeekLabel.setText("\(weatherItem.temp)°")
                    
                    let rowDT = URLHandler.convertDT(weatherItem.dateTime)
                
                    weekRow.dayWeekLabel.setText(rowDT.day)
                
                    weekRow.hourWeekLabel.setText(rowDT.hour)
                
                    weekRow.conditionWeekImage.setImageNamed(weatherItem.icon+".png")
                
                }
            
            })
            
        } else {
            
            print("Weather Array number of rows still zero")
            
            /*Have to store location with NSUserDefaults
            locationManager.getLocation({(CLLocation myLocation) -> () in

                
            })*/
            
        }
        
        print("Week page launched")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
