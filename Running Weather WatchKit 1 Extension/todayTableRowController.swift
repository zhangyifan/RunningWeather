//
//  todayTableRowController.swift
//  Running Weather
//
//  Created by Yifan Zhang on 7/7/15.
//  Copyright © 2015 Yifan Zhang. All rights reserved.
//

import UIKit
import WatchKit

class todayTableRowController: NSObject {
    
    @IBOutlet var barTodayImage: WKInterfaceImage!
    
    @IBOutlet var timeTempTodayLabel: WKInterfaceLabel!
    
    @IBOutlet var qualityTodayLabel: WKInterfaceLabel!
    
    @IBOutlet var humidityTodayImage: WKInterfaceImage!
    
    @IBOutlet var windTodayImage: WKInterfaceImage!
}
