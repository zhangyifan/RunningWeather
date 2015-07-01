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
    
    //NEED TO FIGURE OUT HOW TO NOT SET THIS
    var latitude = 0.0
    
    var longitude = 0.0
    
    let weatherAPIKey = "ef2c62731316105942e0658cb48dbbd5"
    
    var locationManager = CLLocationManager()
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locationArray = locations as NSArray
        
        let location = locationArray[0] as! CLLocation
        
        latitude = location.coordinate.latitude
        
        longitude = location.coordinate.longitude
        
        print("\(latitude) \(longitude)")
        
        //Need to not set to 0.0.  Is this right for startMonitoringSigChanges?
        if latitude != 0.0 || longitude != 0.0 {
            
            locationManager.stopUpdatingLocation()
            
            locationManager.startMonitoringSignificantLocationChanges()
            
            getNowWeather(latitude, longitude: longitude)
            
        } else {
            
            print("Lat and long still 0.0")
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
            
            print("Location manager didFailWithError: "+String(error))
            
    }
    
    func getNowWeather(latitude: Double, longitude: Double) {
        
        let url = NSURL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=imperial&APPID="+weatherAPIKey)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
            
            if error == nil {
                
                do {
                    
                    var jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    print(jsonResult)
                    
                    //Checking that the main and wind arrays exist.
                    if let main = jsonResult["main"] as? NSDictionary, wind = jsonResult["wind"] as? NSDictionary, weather = jsonResult["weather"] as? NSArray {
                        
                        //Getting all the weather conditions
                        var summaryDescription = ""
                        
                        for item in weather {
                            
                            var weatherDict = item as! NSDictionary
                            
                            if summaryDescription == "" {
                                
                                summaryDescription += weatherDict["description"] as! String
                                
                            } else {
                                
                                summaryDescription = summaryDescription + " & " + String(weatherDict["description"])
                                
                            }
                            
                            print(summaryDescription)
                            
                        }
                        
                        self.nowSummaryLabel.setText(summaryDescription)
                        
                        //Checking that the fields we need exist.  DON'T KNOW HOW WEATHER WORKS
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
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
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
