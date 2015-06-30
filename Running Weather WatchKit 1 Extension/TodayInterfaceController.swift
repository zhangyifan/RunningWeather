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
    
    @IBOutlet var nowWordLabel: WKInterfaceLabel!
    
    @IBOutlet var nowTemperatureLabel: WKInterfaceLabel!
    
    @IBOutlet var nowSummaryLabel: WKInterfaceLabel!
    
    @IBOutlet var nowHumidityIcon: WKInterfaceImage!
    
    @IBOutlet var nowHumidityLabel: WKInterfaceLabel!
    
    @IBOutlet var nowWindIcon: WKInterfaceImage!
    
    @IBOutlet var nowWindLabel: WKInterfaceLabel!
    
    let weatherAPIKey = "ef2c62731316105942e0658cb48dbbd5"
    
    var locationManager = CLLocationManager()
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print(locations)
        
        //***NEED TO STOP GETTING LOCATIONS, ONLY CURRENT ONE***
        
    }
    
    func getNowWeather(latitude: Double, longitude: Double) {
        
        let url = NSURL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=imperial&APPID="+weatherAPIKey)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
            
            if error == nil {
                
                //print(data)
                
                do {
                    
                    var jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    print(jsonResult)
                    
                    //Checking that the main and wind arrays exist.  ***NEED TO FIGURE OUT WEATHER DESCRIPTION ARRAY***
                    if let main = jsonResult["main"] as? NSDictionary, wind = jsonResult["wind"] as? NSDictionary {
                        
                        //Checking that the fields we need exist
                        if let temp = main["temp"] as? NSValue, humidity = main["humidity"] as? NSValue, windSpeed = wind["speed"] as? NSValue {
                            
                            self.nowTemperatureLabel.setText("\(temp)")
                            
                            self.nowHumidityLabel.setText("\(humidity)%")

                            //***NOTE NEED TO TURN WINDSPEED INTO INT TO SAVE SPACE***
                            self.nowWindLabel.setText("\(windSpeed)")
                            
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
        
        getNowWeather(41.8369, longitude: -87.6847)
        
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
