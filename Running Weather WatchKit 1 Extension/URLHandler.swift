//
//  URLHandler.swift
//  Running Weather
//
//  Created by Yifan Zhang on 7/20/15.
//  Copyright © 2015 Yifan Zhang. All rights reserved.
//

import UIKit
import WatchKit

class URLHandler: NSObject {
    
    var url: NSURL
    
    var jsonResult: NSDictionary
    
    init(url: NSURL, jsonResult: NSDictionary) {
        
        self.url = url
        self.jsonResult = jsonResult
        
    }
    
    func getResponse (urlString: String, closure: (NSDictionary) -> ()) {
        
        url = NSURL(string: urlString)!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) -> Void in
            
            if error == nil {
                
                do {
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    self.jsonResult = json
                    
                    closure(self.jsonResult)
                    
                } catch {
                    
                    print("Error happened with jsonResult")
                    
                }
                
            } else {
                
                print(error)
                
            }
        }
        
        task!.resume()
        
    }
    
    //Convert Unix datetime NSIntegero usable day of week and hour strings
    class func convertDT(date: NSDate) -> (day: String, hour: String) {
        
        let dayFormatter = NSDateFormatter()
        dayFormatter.dateFormat = "E"
        dayFormatter.timeZone = NSTimeZone()
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "ha"
        timeFormatter.timeZone = NSTimeZone()
        
        
        let localDay = dayFormatter.stringFromDate(date)
        let localTime = timeFormatter.stringFromDate(date)
        
        return (localDay, localTime)
        
    }

}
