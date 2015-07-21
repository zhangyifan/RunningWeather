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

//Our stored weather array for next 5 days, by 3 hour increments
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
    
    let weatherAPIKey = "ef2c62731316105942e0658cb48dbbd5"
    
    //Set the labels for current weather conditions
    func setNowWeather(location: CLLocation) {
        
        let nowWeatherHandler = URLHandler(url: NSURL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&units=imperial&APPID="+weatherAPIKey)!, jsonResult: NSDictionary())
        
        nowWeatherHandler.getResponse("http://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&units=imperial&APPID="+weatherAPIKey)
        
        let nowWeather = Weather(dateTime: NSDate(), temp: 0, humidity: 0, windSpeed: 0.0, clouds: 0, rain: 0.0, snow: 0.0, conditionDescription: "", icon: "", quality: "")
        
        let weatherValues = nowWeather.getWeatherValues(nowWeatherHandler.jsonResult)
                    
                    self.nowSummaryLabel.setText(weatherValues.description)
         
                    self.nowTemperatureLabel.setText("\(Int(weatherValues.temp))°")
                            
                    self.nowHumidityLabel.setText("\(Int(weatherValues.humidity))%")
                            
                    self.nowWindLabel.setText("\(Int(weatherValues.windSpeed))mph")
                    
                    self.nowHumidityIcon.setImageNamed(nowWeather.getHumidityLevel(weatherValues.humidity)+".png")
                    
                    self.nowWindIcon.setImageNamed(nowWeather.getWindLevel(weatherValues.windSpeed)+".png")
                    
                    self.nowWordLabel.setText(nowWeather.assignQuality(weatherValues.temp, humidity: weatherValues.humidity, wind: weatherValues.windSpeed))
                    
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
        
    }
    
    //Update hourlyWeatherArr with hourly weather conditions, update Today table
    func setHourlyWeather(location: CLLocation) {
        
        let hourlyWeatherHandler = URLHandler(url: NSURL(string: "")!, jsonResult: NSDictionary(contentsOfFile: "")!)
        
        hourlyWeatherHandler.getResponse("http://api.openweathermap.org/data/2.5/forecast?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&units=imperial&APPID="+weatherAPIKey)
                    
        //Checking that the list array exists
        if let list = hourlyWeatherHandler.jsonResult["list"] as? NSArray {
                        
            for item in list {
                            
                let listDict = item as! NSDictionary
                            
                let hourlyWeather = Weather(dateTime: NSDate(), temp: 0, humidity: 0, windSpeed: 0.0, clouds: 0, rain: 0.0, snow: 0.0, conditionDescription: "", icon: "", quality: "")
                
                let weatherValues = hourlyWeather.getWeatherValues(listDict)
                            
                hourlyWeatherArr.append(weatherValues)
                            
                if hourlyWeatherArr.count > self.maxTodayRows {
                                
                    for var i = 0; i < self.maxTodayRows; i++ {
                                    
                        let todayRow = self.todayTable.rowControllerAtIndex(i) as! todayTableRowController
                                    
                        let weatherItem = hourlyWeatherArr[i]
                                    
                        let rowTemp = weatherItem.temp
                                    
                        let rowWindImage = hourlyWeather.getWindLevel(weatherItem.windSpeed)
                                    
                        let rowHumidityImage = hourlyWeather.getHumidityLevel(weatherItem.humidity)
                                    
                        let rowDT = TodayInterfaceController.convertDT(weatherItem.dateTime)
                                    
                        let rowQuality = hourlyWeather.assignQuality(rowTemp, humidity: weatherItem.humidity, wind: weatherItem.windSpeed)
                                    
                        todayRow.timeTempTodayLabel.setText(rowDT.hour+" | \(rowTemp)°")
                                    
                        todayRow.windTodayImage.setImageNamed(rowWindImage+".png")
                                    
                        todayRow.humidityTodayImage.setImageNamed(rowHumidityImage+".png")
                                    
                        todayRow.qualityTodayLabel.setText(rowQuality)
                                    
                        todayRow.barTodayImage.setImageNamed(self.getBar(rowQuality, index: i))
                                    
                    }
                }
            }
            
        } else {
            
            print("Error with hourly NSArray")
        }
    }
    
    //Convert Unix datetime NSIntegero usable day of week and hour strings
    class func convertDT(date: NSDate) -> (day: String, hour: String) {
        
        let dayFormatter = NSDateFormatter()
        dayFormatter.dateFormat = "E"
        dayFormatter.timeZone = NSTimeZone()
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "ha"
        timeFormatter.timeZone = NSTimeZone()
        
        
        let localDay = dayFormatter.stringFromDate(date)
        let localTime = timeFormatter.stringFromDate(date)
        
        return (localDay, localTime)
        
    }
    
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
        
        let locationManager = RWLocationManager()
        
        locationManager.getLocation()
        
        //Set up Today table
        todayTable.setNumberOfRows(maxTodayRows, withRowType: "todayTableRowController")
        
        setNowWeather(locationManager.location)
        
        setHourlyWeather(locationManager.location)

        print("App launched")
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
