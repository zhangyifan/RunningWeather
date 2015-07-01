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
    
    //NEED TO CREATE TABLE ROW CONTROLLERS AND CONNECT THEM
    var defaults = NSUserDefaults(suiteName: "group.com.yifanz.RunningWeather")
    
    @IBOutlet var nowWordLabel: WKInterfaceLabel!
    
    @IBOutlet var nowTemperatureLabel: WKInterfaceLabel!
    
    @IBOutlet var nowSummaryLabel: WKInterfaceLabel!
    
    @IBOutlet var nowHumidityIcon: WKInterfaceImage!
    
    @IBOutlet var nowHumidityLabel: WKInterfaceLabel!
    
    @IBOutlet var nowWindIcon: WKInterfaceImage!
    
    @IBOutlet var nowWindLabel: WKInterfaceLabel!
    
    //CLLocation object - use that instead of latitude, longitude variables
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
                
            } else {
                
                print("Error: Lat and Long still 0.0")
                
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
            
        print("Location manager didFailWithError: "+String(error))
        
        //Handle UI accordingly
            
    }
    
    //Collect all the descriptions and update summary label
    func appendDescriptions (weatherArray: NSArray){
        
        var description = ""

        for item in weatherArray {
            
            let weatherDict = item as! NSDictionary
            
            if description == "" {
                
                description += weatherDict["description"] as! String
                
            } else {
                
                description = description + " & " + String(weatherDict["description"])
                
            }
            
            self.nowSummaryLabel.setText(description)
            
        }
        
    }
    
    func getNowWeather(latitude: Double, longitude: Double) {
        
        let url = NSURL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=imperial&APPID="+weatherAPIKey)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
            
            if error == nil {
                
                do {
                    
                    let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    //Checking that the main and wind arrays exist.  IN FUTURE BREAK APART FOR SAFETY
                    if let main = jsonResult["main"] as? NSDictionary, wind = jsonResult["wind"] as? NSDictionary, weather = jsonResult["weather"] as? NSArray {
                        
                        //Getting all the weather conditions
                        self.appendDescriptions(weather)
                        
                        //Checking that the fields we need exist.  IN FUTURE BREAK APART FOR SAFETY
                        if let temp = main["temp"] as? Int, humidity = main["humidity"] as? NSValue, windSpeed = wind["speed"] as? Int {
                            
                            self.nowTemperatureLabel.setText("\(temp)°")
                            
                            self.nowHumidityLabel.setText("\(humidity)%")
                            
                            self.nowWindLabel.setText("\(windSpeed)mph")
                            
                        } else {
                            
                            print("Error with main or wind values inside")
                            
                        }
                        
                    } else {
                        
                        print("Error with main or wind arrays")
                        
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
