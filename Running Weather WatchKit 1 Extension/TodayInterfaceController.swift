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
    
    //Collect all the descriptions and return a summary
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
    
    //Parse temperature, humidity and windspeed from JSON and print errors
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
                    
                } catch {
                    
                    print("Error happened with JSON")
                    
                }
                
            } else {
                
                print(error)
                
            }
        }
        
        task!.resume()
        
    }
    
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

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        myLocationManager.delegate = self
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        myLocationManager.requestAlwaysAuthorization()
        myLocationManager.startUpdatingLocation()
        
        //In the future create function to handle if user does not grant location access
        
        //Set up Today table
        todayTable.setNumberOfRows(8, withRowType: "todayTableRowController")
        
        let todayRow = todayTable.rowControllerAtIndex(0) as! todayTableRowController
        
        todayRow.qualityTodayLabel.setText("Hello!")
        
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
