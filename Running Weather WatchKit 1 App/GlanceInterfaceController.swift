//
//  GlanceInterfaceController.swift
//  Running Weather
//
//  Created by Yifan Zhang on 7/16/15.
//  Copyright © 2015 Yifan Zhang. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation

class GlanceInterfaceController: WKInterfaceController {
    
    @IBOutlet var appIcon: WKInterfaceImage!
    
    @IBOutlet var centerGroup: WKInterfaceGroup!
    
    @IBOutlet var qualityLabel: WKInterfaceLabel!
    
    @IBOutlet var tempLabel: WKInterfaceLabel!
    
    @IBOutlet var humImage: WKInterfaceImage!
    
    @IBOutlet var windImage: WKInterfaceImage!
    
    @IBOutlet var nextHourLabel: WKInterfaceLabel!
    
    @IBOutlet var nextQualityLabel: WKInterfaceLabel!
    
    let locationManager = RWLocationManager()

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
    }

    override func willActivate() {

        super.willActivate()
        
        locationManager.getLocation({(CLLocation myLocation) -> () in
            
            Weather.getNowWeather(myLocation, closure: {(weatherValues: Weather)->() in
                
                self.qualityLabel.setText(weatherValues.assignQuality(weatherValues.temp, humidity: weatherValues.humidity, wind: weatherValues.windSpeed))
                
                self.tempLabel.setText("\(Int(weatherValues.temp))°")
                
                self.humImage.setImageNamed(weatherValues.getHumidityLevel(weatherValues.humidity)+".png")
                
                self.windImage.setImageNamed(weatherValues.getWindLevel(weatherValues.windSpeed)+".png")
                
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
                
                self.centerGroup.setBackgroundImage(finalImage)
                
            })
            
            Weather.getHourlyWeather(myLocation, closure: {()->() in
                
                if hourlyWeatherArr.count > 0 {
                    
                    //TODO STORE BEST WEATHER and then check if it's there, then if not do this
                    Weather.getBestWeather(0, endIndex: 39, closure: {(array: [NSInteger], condition: String)->() in
                            
                        let weatherItem = hourlyWeatherArr[array[0]]
                        
                        let convertedDT = URLHandler.convertDT(weatherItem.dateTime)
                        
                        self.nextHourLabel.setText(convertedDT.day+" "+convertedDT.hour)
                        
                        self.nextQualityLabel.setText("Next "+weatherItem.quality.lowercaseString+" run")
                        
                    })
                    
                }
                
            })
            
        })
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
