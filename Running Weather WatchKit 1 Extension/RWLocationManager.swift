//
//  RWLocationManager.swift
//  Running Weather
//
//  Created by Yifan Zhang on 7/20/15.
//  Copyright © 2015 Yifan Zhang. All rights reserved.
//

import UIKit
import WatchKit
import CoreLocation

//Class to handle getting locations
class RWLocationManager: NSObject, CLLocationManagerDelegate {
    
    var location = CLLocation(latitude: 0.0, longitude: 0.0)
    
    var myLocationManager = CLLocationManager()
    
    func getLocation() {
        
        myLocationManager.delegate = self
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        myLocationManager.requestAlwaysAuthorization()
        myLocationManager.startUpdatingLocation()
        
        //Make sure location is set and not zero
        if location.coordinate.latitude != 0.0 || location.coordinate.longitude != 0.0 {
            
            myLocationManager.stopUpdatingLocation()
            
            myLocationManager.startMonitoringSignificantLocationChanges()
            
        } else {
            
            print("Error: Lat and Long still 0.0")
            
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            
            location = locations[0] as CLLocation
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("Location manager didFailWithError: "+String(error))
        
        //Handle UI accordingly
        
    }

}
