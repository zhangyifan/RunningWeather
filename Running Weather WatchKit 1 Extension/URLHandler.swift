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
    
    func getResponse (urlString: String) {
        
        url = NSURL(string: urlString)!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) -> Void in
            
            if error == nil {
                
                do {
                    
                    self.jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                } catch {
                    
                    print("Error happened with jsonResult")
                    
                }
                
            } else {
                
                print(error)
                
            }
        }
        
        task!.resume()
        
    }

}
