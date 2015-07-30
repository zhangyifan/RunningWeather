//
//  Weather.swift
//  Running Weather
//
//  Created by Yifan Zhang on 7/20/15.
//  Copyright © 2015 Yifan Zhang. All rights reserved.
//

import UIKit
import CoreLocation

let weatherAPIKey = "ef2c62731316105942e0658cb48dbbd5"

//Main weather object, per hour
class Weather: NSObject {
    
    var dateTime: NSDate
    var temp: NSInteger
    var humidity: NSInteger
    var windSpeed: Double
    var clouds: NSInteger
    var rain: Double
    var snow: Double
    var conditionDescription: String
    var icon: String
    var quality: String
    
    init(dateTime: NSDate, temp: NSInteger, humidity: NSInteger, windSpeed: Double, clouds: NSInteger, rain: Double, snow: Double, conditionDescription: String, icon: String, quality: String) {
        
        self.dateTime = dateTime
        self.temp = temp
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.clouds = clouds
        self.rain = rain
        self.snow = snow
        self.conditionDescription = conditionDescription
        self.icon = icon
        self.quality = quality

    }
    
    //Parse temperature, humidity, windspeed, description and datetime from JSON and print errors
    func getWeatherValues(listDict: NSDictionary) -> Weather {
        
        if let dt = listDict["dt"] as? Double {
            
            dateTime = NSDate(timeIntervalSince1970: dt)
            
        } else {
            print("Error with datetime")
        }
        
        if let main = listDict["main"] as? NSDictionary {
            
            if let temperature = main["temp"] as? NSInteger {
                temp = temperature
            } else {
                print("Error with temp")
            }
            
            if let hum = main["humidity"] as? NSInteger {
                humidity = hum
            } else {
                print("Error with humidity")
            }
            
        } else {
            print("Error with main dictionary")
        }
        
        if let wind = listDict["wind"] as? NSDictionary {
            
            if let speed = wind["speed"] as? Double {
                windSpeed = speed
            } else {
                print("Error with windspeed")
            }
            
        } else {
            print("Error with wind dictionary")
        }
        
        if let cloudCover = listDict["clouds"] as? NSDictionary {
            
            if let all = cloudCover["all"] as? NSInteger {
                clouds = all
            } else {
                print("Error with clouds all")
            }
            
        } else {
            print("Error with cloud dictionary")
        }
        
        //Rain and snow may not exist, if there is none in weather forecast
        if let rainy = listDict["rain"] as? NSDictionary {
            
            if let rainVolume = rainy["3h"] as? Double {
                rain = rainVolume
            } else {
                rain = 0.0
            }
            
        } else {
            rain = 0.0
        }
        
        if let snowy = listDict["snow"] as? NSDictionary {
            
            if let snowVolume = snowy["3h"] as? Double {
                snow = snowVolume
            } else {
                snow = 0.0
            }
            
        } else {
            snow = 0.0
        }
        
        if let weather = listDict["weather"] as? NSArray {
            
            var appended = self.appendDescriptionsAndIcons(weather)
            
            conditionDescription = appended.descriptionStr
            icon = appended.iconArr[0]
            
        } else {
            print("Error with weather array")
        }
        
        quality = self.assignQuality(temp, humidity: humidity, wind: windSpeed)
        
        
        //IN FUTURE NEED TO HANDLE IF ANY OF THESE ARE STILL ZERO BC OF ISSUES, WE LATER ASSUME ALL IS FINE
        return Weather(dateTime: dateTime, temp: temp, humidity: humidity, windSpeed: windSpeed, clouds: clouds, rain: rain, snow: snow, conditionDescription: conditionDescription, icon: icon, quality: quality)
        
    }
    
    //Collect all the descriptions and return a summary of weather, plus array of icons.  COULD BE BETTER WITH MORE ERROR HANDLING IF DESCRIPTION OR ICON IS NULL
    //TODO: SEPARATE INTO TWO FUNCTIONS, DESCRIPTIONS, AND ICONS
    func appendDescriptionsAndIcons (weatherArray: NSArray) -> (descriptionStr:String, iconArr:[String]) {
        
        var description = ""
        var icon:[String] = []
        
        for item in weatherArray {
            
            let weatherDict = item as! NSDictionary
            
            if description == "" {
                
                description += weatherDict["description"] as! String
                
            } else {
                
                description = description + " & " + String(weatherDict["description"]!)
                
            }
            
            //Replace night with day because icons are the same to save storage
            var thisIcon = weatherDict["icon"] as! String
            
            if thisIcon.rangeOfString("n") != nil {
                
                if thisIcon.rangeOfString("01") == nil && thisIcon.rangeOfString("02") == nil && thisIcon.rangeOfString("03") == nil {
                    
                    thisIcon = thisIcon.stringByReplacingOccurrencesOfString("n", withString: "d")
                    
                }
            }
            
            icon.append(thisIcon)
        }
        
        return (description, icon)
        
    }
    
    //Return the right wind name
    func getWindLevel(windSpeed: Double) -> String {
        
        if windSpeed < 6 {
            
            return "wind_low"
            
        } else if windSpeed < 16 {
            
            return "wind_medium"
            
        } else {
            
            return "wind_high"
        }
        
    }
    
    //Return the right humidity name
    func getHumidityLevel(humidity: NSInteger) -> String {
        
        if humidity < 60 {
            
            return "humidity_low"
            
        } else if humidity < 80 {
            
            return "humidity_medium"
            
        } else {
            
            return "humidity_high"
            
        }
    }
    
    //Assign quality of running weather  NEED TO FACTOR IN PRECIPITATION
    func assignQuality(temp: NSInteger, humidity: NSInteger, wind: Double) -> String {
        
        let humidityLevel = self.getHumidityLevel(humidity)
        
        let windLevel = self.getWindLevel(wind)
        
        //Hot temperatures
        if temp > 75 {
            
            if temp > 95 {
                
                return "Terrible"
                
            } else if temp > 85 && temp <= 95 {
                
                if humidityLevel == "humidity_low" {
                    
                    if windLevel == "wind_medium" {
                        
                        return "Ok"
                        
                    } else {
                        
                        return "Poor"
                        
                    }
                } else {
                    
                    return "Terrible"
                    
                }
            } else {
                
                if humidityLevel == "humidity_low" {
                    
                    if windLevel == "wind_medium" {
                        
                        return "Perfect"
                        
                    } else {
                        
                        return "Good"
                        
                    }
                    
                } else if humidityLevel == "humidity_medium" {
                    
                    if windLevel == "wind_medium" {
                        
                        return "Good"
                        
                    } else {
                        
                        return "Ok"
                    }
                    
                } else {
                    
                    return "Poor"
                    
                }
            }
        }
            
        //Cold temperatures
        else if temp < 40 {
            
            if temp > 32 {
                
                if windLevel == "wind_high" {
                    
                    return "Poor"
                    
                } else if windLevel == "wind_medium" {
                    
                    if humidityLevel == "humidity_high" {
                        
                        return "Ok"
                        
                    } else {
                        
                        return "Poor"
                        
                    }
                    
                } else {
                    
                    if humidityLevel == "humidity_high" {
                        
                        return "Good"
                        
                    } else {
                        
                        return "Ok"
                        
                    }
                }
                
            } else if temp > 25 {
                
                if windLevel == "wind_high" {
                    
                    return "Terrible"
                    
                } else if windLevel == "wind_low" {
                    
                    if humidityLevel == "humidity_high" {
                        
                        return "Ok"
                        
                    } else {
                        
                        return "Poor"
                        
                    }
                    
                } else {
                    
                    if humidityLevel == "humidity_high" {
                        
                        return "Poor"
                        
                    } else {
                        
                        return "Terrible"
                        
                    }
                }
                
            } else {
                
                return "Terrible"
                
            }
            
        }
            
        //Ideal temperatures (40-75 degrees)
        else {
            
            if humidityLevel == "humidity_high" {
                
                return "Good"
                
            } else if windLevel == "wind_high" {
                
                return "Good"
                
            } else {
                
                return "Perfect"
                
            }
            
        }
    }
    
    //Function to pick the best weather in a given period of time, Skipping 1am items
    class func getBestWeather(startIndex: NSInteger, endIndex: NSInteger, closure: (array: [NSInteger], condition: String)->() ) {
        
        //Arrays of indexes of various weather qualities
        var perfectArr:[NSInteger] = []
        var goodArr:[NSInteger] = []
        var okArr:[NSInteger] = []
        var poorArr:[NSInteger] = []
        var terribleArr:[NSInteger] = []
        
        for var i = startIndex; i <= endIndex; i++ {
            
            let weatherItem = hourlyWeatherArr[i]
            
            let quality = weatherItem.assignQuality(weatherItem.temp, humidity: weatherItem.humidity, wind: weatherItem.windSpeed )
            
            //Removing the 1am items
            if URLHandler.convertDT(weatherItem.dateTime).hour != "1AM" {
                
                if quality == "Perfect" {
                    
                    perfectArr.append(i)
                    
                } else if quality == "Good" {
                    
                    goodArr.append(i)
                    
                } else if quality == "OK" {
                    
                    okArr.append(i)
                    
                } else if quality == "Poor" {
                    
                    poorArr.append(i)
                    
                } else {
                    
                    terribleArr.append(i)
                    
                }
            }
        }
        
        if perfectArr.count > 0 {
            
            closure(array: perfectArr, condition: "Perfect")
            
        } else if goodArr.count > 0 {
            
            closure(array: goodArr, condition: "Good")
            
        } else if okArr.count > 0 {
            
            closure(array: okArr, condition: "Ok")
            
        } else if poorArr.count > 0 {
            
            closure(array: goodArr, condition: "Good")
            
        } else {
            
            closure(array: terribleArr, condition: "Terrible")
            
        }
    }
    
    //Get current weather conditions
    class func getNowWeather(location: CLLocation, closure: (weatherValues: Weather)->()) {
        
        let nowWeatherHandler = URLHandler(url: NSURL(), jsonResult: NSDictionary())
        
        let nowWeather = Weather(dateTime: NSDate(), temp: 0, humidity: 0, windSpeed: 0.0, clouds: 0, rain: 0.0, snow: 0.0, conditionDescription: "", icon: "", quality: "")
        
        nowWeatherHandler.getResponse("http://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&units=imperial&APPID="+weatherAPIKey, closure: {(jsonResult: NSDictionary) -> () in
            
            let weatherValues = nowWeather.getWeatherValues(jsonResult)
            
            closure(weatherValues: weatherValues)
            
        })
        
    }
    
    //Update hourlyWeatherArr with hourly weather conditions
    class func getHourlyWeather(location: CLLocation, closure: ()->()) {
        
        let hourlyWeatherHandler = URLHandler(url: NSURL(), jsonResult: NSDictionary())
        
        hourlyWeatherHandler.getResponse("http://api.openweathermap.org/data/2.5/forecast?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&units=imperial&APPID="+weatherAPIKey, closure: {(jsonResult: NSDictionary) -> () in
            
            //Checking that the list array exists
            if let list = jsonResult["list"] as? NSArray {
                
                for item in list {
                    
                    let listDict = item as! NSDictionary
                    
                    let hourlyWeather = Weather(dateTime: NSDate(), temp: 0, humidity: 0, windSpeed: 0.0, clouds: 0, rain: 0.0, snow: 0.0, conditionDescription: "", icon: "", quality: "")
                    
                    let weatherValues = hourlyWeather.getWeatherValues(listDict)
                    
                    hourlyWeatherArr.append(weatherValues)
                    
                }
                
                closure()
                
            } else {
                
                print("Error with hourly NSArray")
            }

        })
        
    }
    
    
}
