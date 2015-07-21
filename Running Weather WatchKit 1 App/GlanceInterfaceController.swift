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

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
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
