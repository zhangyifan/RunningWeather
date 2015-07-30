//
//  TodayInterfaceController.swift
//  Running Weather WatchKit 1 Extension
//
//  Created by Yifan Zhang on 6/27/15.
//  Copyright © 2015 Yifan Zhang. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation

//Global Variables: Our stored weather array for next 5 days, by 3 hour increments
var hourlyWeatherArr: [Weather] = []


class TodayInterfaceController: WKInterfaceController {

    var defaults = NSUserDefaults(suiteName: "group.com.yifanz.RunningWeather")
    
    @IBOutlet var topGroup: WKInterfaceGroup!
    
    @IBOutlet var nowWordLabel: WKInterfaceLabel!
    
    @IBOutlet var nowTemperatureLabel: WKInterfaceLabel!
    
    @IBOutlet var nowSummaryLabel: WKInterfaceLabel!
    
    @IBOutlet var nowHumidityIcon: WKInterfaceImage!
    
    @IBOutlet var nowHumidityLabel: WKInterfaceLabel!
    
    @IBOutlet var nowWindIcon: WKInterfaceImage!
    
    @IBOutlet var nowWindLabel: WKInterfaceLabel!
    
    @IBOutlet var todayTable: WKInterfaceTable!
    
    let maxTodayRows = 8
    
    let locationManager = RWLocationManager()
    
    //Return the right bar color and shape
    func getBar (quality: String, index: NSInteger) -> String {
        
        var imageName = "bar"
        
        //Color
        if quality == "Perfect" {
            
            imageName += "_1"
            
        } else if quality == "Good" {
            
            imageName += "_2"
            
        } else if quality == "Ok" {
            
            imageName += "_3"
            
        } else if quality == "Poor" {
            
            imageName += "_4"
            
        } else if quality == "Terrible" {
            
            imageName += "_5"
            
        }
        
        //Size
        if index == 0 {
            
            imageName += "_roundedtop.png"
            
        } else if index == maxTodayRows - 1 {
            
            imageName += "_roundedbottom.png"
            
        } else {
            
            imageName += "_flat.png"
            
        }
        
        return imageName
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        /* //Cache the old location for initial screen
        self.setNowWeather(myLocation)
        
        self.setHourlyWeather(myLocation)
        
        //Set up Today table
        self.todayTable.setNumberOfRows(self.maxTodayRows, withRowType: "todayTableRowController")*/
        

        print("App launched")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        locationManager.getLocation({(CLLocation myLocation) -> () in
            
            Weather.getNowWeather(myLocation, closure: {(weatherValues: Weather)->() in
                
                self.nowSummaryLabel.setText(weatherValues.conditionDescription)
                
                self.nowTemperatureLabel.setText("\(Int(weatherValues.temp))°")
                
                self.nowHumidityLabel.setText("\(Int(weatherValues.humidity))%")
                
                self.nowWindLabel.setText("\(Int(weatherValues.windSpeed))mph")
                
                self.nowHumidityIcon.setImageNamed(weatherValues.getHumidityLevel(weatherValues.humidity)+".png")
                
                self.nowWindIcon.setImageNamed(weatherValues.getWindLevel(weatherValues.windSpeed)+".png")
                
                self.nowWordLabel.setText(weatherValues.assignQuality(weatherValues.temp, humidity: weatherValues.humidity, wind: weatherValues.windSpeed))
                
                //Crazy complicated way to set alpha on a background image of a group
                let backgroundImage = UIImage(named: weatherValues.icon)
                UIGraphicsBeginImageContextWithOptions((backgroundImage?.size)!, false, 0.0)
                let ctx = UIGraphicsGetCurrentContext()
                let area = CGRectMake(0, 0, (backgroundImage?.size.width)!, (backgroundImage?.size.height)!)
                CGContextScaleCTM(ctx, 1, -1)
                CGContextTranslateCTM(ctx, 0, -area.size.height)
                CGContextSetAlpha(ctx, 0.3)
                CGContextDrawImage(ctx, area, backgroundImage?.CGImage)
                
                let finalImage = UIGraphicsGetImageFromCurrentImageContext()
                
                self.topGroup.setBackgroundImage(finalImage)
            
            })
            
            //Set up Today table
            self.todayTable.setNumberOfRows(self.maxTodayRows, withRowType: "todayTableRowController")
            
            Weather.getHourlyWeather(myLocation, closure: {()->() in
                
                if hourlyWeatherArr.count > self.maxTodayRows {
                    
                    for var i = 0; i < self.maxTodayRows; i++ {
                        
                        let todayRow = self.todayTable.rowControllerAtIndex(i) as! todayTableRowController
                        
                        let weatherItem = hourlyWeatherArr[i]
                        
                        let rowTemp = weatherItem.temp
                        
                        let rowWindImage = weatherItem.getWindLevel(weatherItem.windSpeed)
                        
                        let rowHumidityImage = weatherItem.getHumidityLevel(weatherItem.humidity)
                        
                        let rowDT = URLHandler.convertDT(weatherItem.dateTime)
                        
                        let rowQuality = weatherItem.assignQuality(rowTemp, humidity: weatherItem.humidity, wind: weatherItem.windSpeed)
                        
                        todayRow.timeTempTodayLabel.setText(rowDT.hour+" | \(rowTemp)°")
                        
                        todayRow.windTodayImage.setImageNamed(rowWindImage+".png")
                        
                        todayRow.humidityTodayImage.setImageNamed(rowHumidityImage+".png")
                        
                        todayRow.qualityTodayLabel.setText(rowQuality)
                        
                        todayRow.barTodayImage.setImageNamed(self.getBar(rowQuality, index: i))
                        
                    }
                }
            
            })
            
        })
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
