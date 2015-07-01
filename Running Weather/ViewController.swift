//
//  ViewController.swift
//  Running Weather
//
//  Created by Yifan Zhang on 6/27/15.
//  Copyright © 2015 Yifan Zhang. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var defaults = NSUserDefaults(suiteName: "group.com.yifanz.RunningWeather")

    /*var locationManager = CLLocationManager()
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print(locations)

    }*/

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Can add ability of user to set default calculations of best running weather
        
        /*locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

