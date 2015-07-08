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

class TodayInterfaceController: WKInterfaceController, CLLocationManagerDelegate {

    var defaults = NSUserDefaults(suiteName: "group.com.yifanz.RunningWeather")
    
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
    
    var hourlyWeatherArr: [Dictionary<String, Int>] = []
    
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
    
    //Collect all the descriptions and return a summary of weather
    func appendDescriptions (weatherArray: NSArray) -> String {
        
        var description = ""

        for item in weatherArray {
            
            let weatherDict = item as! NSDictionary
            
            if description == "" {
                
                description += weatherDict["description"] as! String
                
            } else {
                
                description = description + " & " + String(weatherDict["description"])
                
            }
        }
        
        return description
        
    }
    
    //Parse temperature, humidity, windspeed and description from JSON and print errors
    func getWeatherValues(listDict: NSDictionary) -> (temperature: Int, humidity: Int, windSpeed: Int, description: String) {
        
        var temperature = 0
        var humidity = 0
        var windSpeed = 0
        var description = ""
        
        if let main = listDict["main"] as? NSDictionary {
            
            if let temp = main["temp"] as? Int {
                
                temperature = temp
                
            } else {
                
                print("Error with temp")
                
            }
            
            if let hum = main["humidity"] as? Int {
                
                humidity = hum
                
            } else {
                
                print("Error with humidity")
                
            }
            
        } else {
            
            print("Error with main in forecast")
            
        }
        
        if let wind = listDict["wind"] as? NSDictionary {
            
            if let speed = wind["speed"] as? Int {
                
                windSpeed = speed
                
            } else {
                
                print("Error with windspeed")
                
            }
            
        } else {
            
            print("Error with wind in forecast")
            
        }
        
        if let weather = listDict["weather"] as? NSArray {
            
            description = self.appendDescriptions(weather)
            
        } else {
            
            print("Error with weather array")
            
        }
        
        return (temperature, humidity, windSpeed, description)
        
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
         
                    self.nowTemperatureLabel.setText("\(weatherValues.temperature)°")
                            
                    self.nowHumidityLabel.setText("\(weatherValues.humidity)%")
                            
                    self.nowWindLabel.setText("\(weatherValues.windSpeed)mph")
                    
                    self.nowHumidityIcon.setImageNamed(self.chooseHumidityImage(weatherValues.humidity))
                    
                    self.nowWindIcon.setImageNamed(self.chooseWindImage(weatherValues.windSpeed))
                    
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
                            
                            //Need to get date time values processed
                            
                            let values = ["temp":weatherValues.temperature, "humidity":weatherValues.humidity, "wind":weatherValues.windSpeed]
                            
                            self.hourlyWeatherArr.append(values)
                            
                            if self.hourlyWeatherArr.count > self.maxTodayRows {
                                
                                //MIGHT WANT TO MOVE TO SEPARATE FUNCTION
                                for var i = 0; i < self.maxTodayRows; i++ {
                                    
                                    let todayRow = self.todayTable.rowControllerAtIndex(i) as! todayTableRowController
                                    
                                    let weatherDict = self.hourlyWeatherArr[i]
                                    
                                    let rowTemp = weatherDict["temp"]
                                    
                                    let rowWindImage = self.chooseWindImage(weatherDict["wind"]!)
                                    
                                    let rowHumidityImage = self.chooseHumidityImage(weatherDict["humidity"]!)
                                    
                                    todayRow.timeTempTodayLabel.setText("1pm | \(rowTemp!)°")
                                    
                                    todayRow.windTodayImage.setImageNamed(rowWindImage+".png")
                                    
                                    todayRow.humidityTodayImage.setImageNamed(rowHumidityImage+".png")
                                    
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
    func chooseWindImage(windSpeed: Int) -> String {
        
        if windSpeed < 6 {
            
            return "wind_low"
            
        } else if windSpeed < 16 {
            
            return "wind_medium"
            
        } else {
            
            return "wind_high"
        }
        
    }
    
    //Return the right humidity image name
    func chooseHumidityImage(humidity: Int) -> String {
        
        if humidity < 45 {
            
            return "humidity_low"
            
        } else if humidity < 70 {
            
            return "humidity_medium"
            
        } else {
            
            return "humidity_high"
            
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
