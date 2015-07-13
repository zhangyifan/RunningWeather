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

//Our main weather object, per hour
class Weather {
    
    var dateTime: NSDate
    var temp: Int
    var humidity: Int
    var windSpeed: Double
    var clouds: Int
    var rain: Double
    var snow: Double
    var description: String
    var icon: String
    var quality: String
    
    init(dateTime: NSDate, temp: Int, humidity: Int, windSpeed: Double, clouds: Int, rain: Double, snow: Double, description: String, icon: String, quality: String) {
        
        self.dateTime = dateTime
        self.temp = temp
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.clouds = clouds
        self.rain = rain
        self.snow = snow
        self.description = description
        self.icon = icon
        self.quality = quality
    }
}

//Our stored weather array for next 5 days, by 3 hour increments
var hourlyWeatherArr: [Weather] = []

class TodayInterfaceController: WKInterfaceController, CLLocationManagerDelegate {

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
    
    var location = CLLocation(latitude: 0.0, longitude: 0.0)
    
    let weatherAPIKey = "ef2c62731316105942e0658cb48dbbd5"
    
    var myLocationManager = CLLocationManager()
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Don't have a location yet
        if location.coordinate.latitude == 0.0 && location.coordinate.longitude == 0.0 {
            
            location = locations[0] as CLLocation
            
            //Make sure location is set and not zero
            if location.coordinate.latitude != 0.0 || location.coordinate.longitude != 0.0 {
        
            myLocationManager.stopUpdatingLocation()
            
            myLocationManager.startMonitoringSignificantLocationChanges()
            
            getNowWeather(location.coordinate.latitude, longitude: location.coordinate.longitude)
                
            getHourlyWeather(location.coordinate.latitude, longitude: location.coordinate.longitude)
                
            } else {
                
                print("Error: Lat and Long still 0.0")
                
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
            
        print("Location manager didFailWithError: "+String(error))
        
        //Handle UI accordingly
            
    }
    
    //Collect all the descriptions and return a summary of weather, plus array of icons.  COULD BE BETTER WITH MORE ERROR HANDLING IF DESCRIPTION OR ICON IS NULL
    func appendDescriptionsAndIcons (weatherArray: NSArray) -> (descriptionStr:String, iconArr:[String]) {
        
        var description = ""
        var icon:[String] = []

        for item in weatherArray {
            
            let weatherDict = item as! NSDictionary
            
            if description == "" {
                
                description += weatherDict["description"] as! String
                
            } else {
                
                description = description + " & " + String(weatherDict["description"]!)
                
            }
            
            //Replace night with day because icons are the same to save storage
            var thisIcon = weatherDict["icon"] as! String
            
            if thisIcon.rangeOfString("n") != nil {
                
                if thisIcon.rangeOfString("01") == nil && thisIcon.rangeOfString("02") == nil {
                    
                    thisIcon = thisIcon.stringByReplacingOccurrencesOfString("n", withString: "d")
                    
                }
            }
            
            icon.append(thisIcon)
        }
        
        return (description, icon)
        
    }
    
    //Parse temperature, humidity, windspeed, description and datetime from JSON and print errors
    func getWeatherValues(listDict: NSDictionary) -> Weather {
        
        var dateTime = NSDate()
        var temp = 0
        var humidity = 0
        var windSpeed = 0.0
        var clouds = 0
        var rain = 0.0
        var snow = 0.0
        var description = ""
        var icon = ""
        var quality = ""
        
        if let dt = listDict["dt"] as? Double {
            
            dateTime = NSDate(timeIntervalSince1970: dt)
            
        } else {
            print("Error with datetime")
        }
        
        if let main = listDict["main"] as? NSDictionary {
            
            if let temperature = main["temp"] as? Int {
                temp = temperature
            } else {
                print("Error with temp")
            }
            
            if let hum = main["humidity"] as? Int {
                humidity = hum
            } else {
                print("Error with humidity")
            }
            
        } else {
            print("Error with main dictionary")
        }
        
        if let wind = listDict["wind"] as? NSDictionary {
            
            if let speed = wind["speed"] as? Double {
                windSpeed = speed
            } else {
                print("Error with windspeed")
            }
            
        } else {
            print("Error with wind dictionary")
        }
        
        if let cloudCover = listDict["clouds"] as? NSDictionary {
            
            if let all = cloudCover["all"] as? Int {
                clouds = all
            } else {
                print("Error with clouds all")
            }
            
        } else {
            print("Error with cloud dictionary")
        }
        
        //Rain and snow may not exist, if there is none in weather forecast
        if let rainy = listDict["rain"] as? NSDictionary {
            
            if let rainVolume = rainy["3h"] as? Double {
                rain = rainVolume
            } else {
                rain = 0.0
            }
            
        } else {
            rain = 0.0
        }
        
        if let snowy = listDict["snow"] as? NSDictionary {
            
            if let snowVolume = snowy["3h"] as? Double {
                snow = snowVolume
            } else {
                snow = 0.0
            }
            
        } else {
            snow = 0.0
        }
        
        if let weather = listDict["weather"] as? NSArray {
            
            var appended = self.appendDescriptionsAndIcons(weather)
            
            description = appended.descriptionStr
            icon = appended.iconArr[0]
            
        } else {
            print("Error with weather array")
        }
        
        quality = TodayInterfaceController.assignQuality(temp, humidity: humidity, wind: windSpeed)
        
        
        //IN FUTURE NEED TO HANDLE IF ANY OF THESE ARE STILL ZERO BC OF ISSUES, WE LATER ASSUME ALL IS FINE
        return Weather(dateTime: dateTime, temp: temp, humidity: humidity, windSpeed: windSpeed, clouds: clouds, rain: rain, snow: snow, description: description, icon: icon, quality: quality)
        
    }
    
    //Convert Unix datetime into usable day of week and hour strings
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
    
    //Set the labels for current weather conditions
    func getNowWeather(latitude: Double, longitude: Double) {
        
        let url = NSURL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=imperial&APPID="+weatherAPIKey)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
            
            if error == nil {
                
                do {
                    
                    let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    let weatherValues = self.getWeatherValues(jsonResult)
                    
                    self.nowSummaryLabel.setText(weatherValues.description)
         
                    self.nowTemperatureLabel.setText("\(Int(weatherValues.temp))°")
                            
                    self.nowHumidityLabel.setText("\(Int(weatherValues.humidity))%")
                            
                    self.nowWindLabel.setText("\(Int(weatherValues.windSpeed))mph")
                    
                    self.nowHumidityIcon.setImageNamed(TodayInterfaceController.getHumidityLevel(weatherValues.humidity)+".png")
                    
                    self.nowWindIcon.setImageNamed(TodayInterfaceController.getWindLevel(weatherValues.windSpeed)+".png")
                    
                    self.nowWordLabel.setText(TodayInterfaceController.assignQuality(weatherValues.temp, humidity: weatherValues.humidity, wind: weatherValues.windSpeed))
                    
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
                    
                } catch {
                    
                    print("Error happened with JSON")
                    
                }
                
            } else {
                
                print(error)
                
            }
        }
        
        task!.resume()
        
    }
    
    //Update hourlyWeatherArr with hourly weather conditions, update Today table
    func getHourlyWeather(latitude: Double, longitude: Double) {
        
        let url = NSURL(string: "http://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&units=imperial&APPID="+weatherAPIKey)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
            
            if error == nil {
    
                do {
                    
                    let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    //Checking that the list array exists
                    if let list = jsonResult["list"] as? NSArray {
                        
                        for item in list {
                            
                            let listDict = item as! NSDictionary
                            
                            let weatherValues = self.getWeatherValues(listDict)
                            
                            hourlyWeatherArr.append(weatherValues)
                            
                            if hourlyWeatherArr.count > self.maxTodayRows {
                                
                                //MIGHT WANT TO MOVE TO SEPARATE FUNCTION?
                                for var i = 0; i < self.maxTodayRows; i++ {
                                    
                                    let todayRow = self.todayTable.rowControllerAtIndex(i) as! todayTableRowController
                                    
                                    let weatherItem = hourlyWeatherArr[i]
                                    
                                    let rowTemp = weatherItem.temp
                                    
                                    let rowWindImage = TodayInterfaceController.getWindLevel(weatherItem.windSpeed)
                                    
                                    let rowHumidityImage = TodayInterfaceController.getHumidityLevel(weatherItem.humidity)
                                    
                                    let rowDT = TodayInterfaceController.convertDT(weatherItem.dateTime)
                                    
                                    todayRow.timeTempTodayLabel.setText(rowDT.hour+" | \(rowTemp)°")
                                    
                                    todayRow.windTodayImage.setImageNamed(rowWindImage+".png")
                                    
                                    todayRow.humidityTodayImage.setImageNamed(rowHumidityImage+".png")
                                    
                                    todayRow.qualityTodayLabel.setText(TodayInterfaceController.assignQuality(rowTemp, humidity: weatherItem.humidity, wind: weatherItem.windSpeed))
                                    
                                }
            
                            }
                            
                        }
                        
                    } else {
                        
                        print("Error with list array")
                        
                    }
                    
                } catch {
                    
                    print("Error happened with JSON")
                    
                }
                
            } else {
                
                print(error)
                
            }
        }
        
        task!.resume()
    
    }
    
    //Return the right wind image name
    class func getWindLevel(windSpeed: Double) -> String {
        
        if windSpeed < 6 {
            
            return "wind_low"
            
        } else if windSpeed < 16 {
            
            return "wind_medium"
            
        } else {
            
            return "wind_high"
        }
        
    }
    
    //Return the right humidity image name
    class func getHumidityLevel(humidity: Int) -> String {
        
        if humidity < 60 {
            
            return "humidity_low"
            
        } else if humidity < 80 {
            
            return "humidity_medium"
            
        } else {
            
            return "humidity_high"
            
        }
    }
    
    //Assign quality of running weather  NEED TO FACTOR IN PRECIPITATION
    class func assignQuality(temp: Int, humidity: Int, wind: Double) -> String {
        
        let humidityLevel = TodayInterfaceController.getHumidityLevel(humidity)
        
        let windLevel = TodayInterfaceController.getWindLevel(wind)
        
        //Hot temperatures
        if temp > 75 {
            
            if temp > 95 {
                
                return "Terrible"
                
            } else if temp > 85 && temp <= 95 {
                
                if humidityLevel == "humidity_low" {
                    
                    if windLevel == "wind_medium" {
                        
                        return "Ok"
                        
                    } else {
                        
                        return "Poor"
                        
                    }
                } else {
                    
                    return "Terrible"
                    
                }
            } else {
                
                if humidityLevel == "humidity_low" {
                    
                    if windLevel == "wind_medium" {
                        
                        return "Perfect"
                        
                    } else {
                        
                        return "Good"
                        
                    }
                    
                } else if humidityLevel == "humidity_medium" {
                    
                    if windLevel == "wind_medium" {
                        
                        return "Good"
                        
                    } else {
                        
                        return "Ok"
                    }
                    
                } else {
                    
                    return "Poor"
                    
                }
            }
        }
        
        //Cold temperatures
        else if temp < 40 {
            
            if temp > 32 {
                
                if windLevel == "wind_high" {
                    
                    return "Poor"
                    
                } else if windLevel == "wind_medium" {
                    
                    if humidityLevel == "humidity_high" {
                        
                        return "Ok"
                        
                    } else {
                        
                        return "Poor"
                        
                    }
                    
                } else {
                    
                    if humidityLevel == "humidity_high" {
                        
                        return "Good"
                        
                    } else {
                        
                        return "Ok"
                        
                    }
                }
                
            } else if temp > 25 {
                
                if windLevel == "wind_high" {
                    
                    return "Terrible"
                    
                } else if windLevel == "wind_low" {
                    
                    if humidityLevel == "humidity_high" {
                        
                        return "Ok"
                        
                    } else {
                        
                        return "Poor"
                        
                    }
                    
                } else {
                    
                    if humidityLevel == "humidity_high" {
                        
                        return "Poor"
                        
                    } else {
                        
                        return "Terrible"
                        
                    }
                }
                
            } else {
                
                return "Terrible"
                
            }
            
        }
        
        //Ideal temperatures (40-75 degrees)
        else {
            
            if humidityLevel == "humidity_high" {
                
                return "Good"
                
            } else if windLevel == "wind_high" {
                
                return "Good"
                
            } else {
                
                return "Perfect"
                
            }
            
        }
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        myLocationManager.delegate = self
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        myLocationManager.requestAlwaysAuthorization()
        myLocationManager.startUpdatingLocation()
        
        //In the future create function to handle if user does not grant location access
        
        //Set up Today table
        todayTable.setNumberOfRows(maxTodayRows, withRowType: "todayTableRowController")
        
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
