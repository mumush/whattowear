//
//  Current.swift
//  WhatToWear
//
//  Created by Ryan Hoffmann on 2/19/15.
//  Copyright (c) 2015 Mumush. All rights reserved.
//

import Foundation
import UIKit


struct Current {
    
    var icon: UIImage?
    var currentTime: String?
    
    var temperature: Int
    var apparentTemp: Int
    var humidity: Double
    var precipIntensity: Double
    var summary: String
    
    
    init(weatherDictionary : NSDictionary) {
        
        let currentWeather : NSDictionary = weatherDictionary["currently"] as NSDictionary
        
        self.temperature = currentWeather["temperature"] as Int
        self.apparentTemp = currentWeather["apparentTemperature"] as Int
        self.humidity = currentWeather["humidity"] as Double
        self.precipIntensity = currentWeather["precipIntensity"] as Double
        self.summary = currentWeather["summary"] as String

        
        self.icon = weatherIconFromString(currentWeather["icon"] as String)

        self.currentTime = dateStringFromUnixTime(currentWeather["time"] as Int)
        
    }
    
    
    func dateStringFromUnixTime(unixTime : Int) -> String {
        
        let timeInSeconds = NSTimeInterval(unixTime)
        let weatherDate = NSDate(timeIntervalSince1970: timeInSeconds)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        
        return dateFormatter.stringFromDate(weatherDate)
        
        
    }
    

    //Use the "icon" string that Forecast gives us and return an
    //image with the same name
    //If the returned icon string doesn't match any assets
    //use the default weather asset (recommended by forecast)
    func weatherIconFromString(stringIcon : String) -> UIImage {
        
        if let weatherImage = UIImage(named: stringIcon) {
            
            return weatherImage
            
        }
        else {
            
            return UIImage(named: "weather_default")!
        }
        
    }
    
    
}