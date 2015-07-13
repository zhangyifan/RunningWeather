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
    class func getBestWeather(startIndex: Int, endIndex: Int) -> (indexArr: [Int], qualityName: String){
        
        //Arrays of indexes of various weather qualities
        var perfectArr:[Int] = []
        var goodArr:[Int] = []
        var okArr:[Int] = []
        var poorArr:[Int] = []
        var terribleArr:[Int] = []

        for var i = startIndex; i <= endIndex; i++ {
            
            let weatherItem = hourlyWeatherArr[i]
            
            let quality = TodayInterfaceController.assignQuality(weatherItem.temp, humidity: weatherItem.humidity, wind: weatherItem.windSpeed )
            
            if quality == "Perfect" {
                
                perfectArr.append(i)
                
            } else if quality == "Good" {
                
                goodArr.append(i)
                
            } else if quality == "OK" {
                
                okArr.append(i)
                
            } else if quality == "Poor" {
                
                poorArr.append(i)
                
            } else {
                
                terribleArr.append(i)
                
            }
        }
        
        if perfectArr.count > 0 {
            
            return (perfectArr, "Perfect")
            
        } else if goodArr.count > 0 {
            
            return (goodArr, "Good")
            
        } else if okArr.count > 0 {
            
            return (okArr, "Ok")
            
        } else if poorArr.count > 0 {
            
            return (goodArr, "Good")
            
        } else {
            
            return (terribleArr, "Terrible")
            
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        //Set up week table
        var bestWeather = ThisWeekInterfaceController.getBestWeather(8, endIndex: 39)
        
        weekTable.setNumberOfRows(bestWeather.indexArr.count, withRowType: "weekTableRowController")
        
        if hourlyWeatherArr.count > 0 {
            
            for var i = 0; i < bestWeather.indexArr.count; i++ {
                
                let weekRow = self.weekTable.rowControllerAtIndex(i) as! weekTableRowController
                
                let weatherItem = hourlyWeatherArr[bestWeather.indexArr[i]]
                
                weekRow.tempWeekLabel.setText("\(weatherItem.temp)°")
                
                let rowDT = TodayInterfaceController.convertDT(weatherItem.dateTime)
                
                weekRow.dayWeekLabel.setText(rowDT.day)
                
                weekRow.hourWeekLabel.setText(rowDT.hour)
                
                weekRow.conditionWeekImage.setImageNamed(weatherItem.icon+".png")
                
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
