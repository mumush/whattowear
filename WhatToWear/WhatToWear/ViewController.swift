//
//  ViewController.swift
//  WhatToWear
//
//  Created by Ryan Hoffmann on 2/18/15.
//  Copyright (c) 2015 Mumush. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    
    
    
    
    
    private let apiKey = "8e47cf6912754d5c148a50425e44706e"

    private let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.initLocationManager()
        
    }
    
    
    func initLocationManager() {
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                
                println("Reverese Geocode Error: \(error)")
                return
            }
            
            
            if placemarks.count > 0 {
                
                let locationPlacemark = placemarks[0] as CLPlacemark
                self.displayLocation(locationPlacemark)
            }
            else {
                
                println("Error with Placemarks")
            }
            
        })
        
    }
    
    func displayLocation(placemark : CLPlacemark) {
        
        //NOT SURE THIS IS THE CORRECT PLACE FOR THIS
        //tell the location manager to stop updating our new location after it gets it once
        self.locationManager.stopUpdatingLocation()
        
        println("\(placemark.location.coordinate.latitude), \(placemark.location.coordinate.longitude)")
        println(placemark.locality)
        
        self.getCurrentWeatherData(placemark.location, locality: placemark.locality)
        
    }
    
    
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        println("Did Fail With Error \(error.localizedDescription)")
        
    }


    
    func getCurrentWeatherData(location : CLLocation, locality : String) {
        
        let baseUrl = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let forecastUrl = NSURL(string: "\(location.coordinate.latitude),\(location.coordinate.longitude)", relativeToURL: baseUrl)
        
        let sharedSession = NSURLSession.sharedSession()
        
        let downloadTask = sharedSession.downloadTaskWithURL(forecastUrl!, completionHandler: { (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if error == nil {
                
                if let dataObject = NSData(contentsOfURL: location) {
                    
                    let weatherDict : NSDictionary = NSJSONSerialization.JSONObjectWithData(dataObject, options: nil, error: nil) as NSDictionary
                    
                    let currentWeather = Current(weatherDictionary: weatherDict)
                    
                    self.updateUI(currentWeather, locality: locality)
                }
                
            }
            else {
                println(error)
            }
            
        })
        
        downloadTask.resume()

    }
    
    
    func updateUI(currentWeather: Current, locality: String) {
        
        println(currentWeather.temperature)
        
        self.changeBackground(currentWeather.temperature)

        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.locationLabel.text = locality
            //self.whatToWearLabel.text = self.determineWhatToWear(currentWeather)
            
            self.tempLabel.text = "\(currentWeather.temperature)"
            self.weatherImage.image = currentWeather.icon
            
            
        })
        
    }
    
    func determineWhatToWear(currentWeather: Current) -> String {
        
        var whatToWear: String = ""
        
        //First based on temp and precipitation, decide if you should wear a hat or raincoat
        
        if currentWeather.temperature <= 40 && currentWeather.precipIntensity > 0.017 { //snowing or freezing rain
            whatToWear += "Hat, "
        }
        else if currentWeather.temperature > 40 && currentWeather.precipIntensity > 0.017 { //raining
            whatToWear += "Raincoat, "
        }
        
        //Now, determine the rest of the normal outerwear
        
        if currentWeather.temperature <= 40 || currentWeather.apparentTemp <= 40 {
            
            whatToWear += "Jacket, Hoodie, Pants"
            
        }
        else if currentWeather.temperature <= 60 || currentWeather.apparentTemp <= 60 {
            
            whatToWear += "Hoodie, T-Shirt, Pants"
            
        }
        else if currentWeather.temperature <= 85 || currentWeather.apparentTemp <= 85 {

            whatToWear += "T-shirt, Shorts"
            
        }
        else { //anything higher than 85...tank and shorts is a safe bet
            
            whatToWear += "Tank, Shorts"
        }
        
        
        return whatToWear
        
    }
    

    //Change background based on the temperature
    //Higher temp -> closer to dark red
    //Lower temp -> closer to light blue
    func changeBackground(temperature: Int) {
        

        var tempColor: UIColor = UIColor(red: 90/255.0, green: 169/255.0, blue: 255/255.0, alpha: 1.0)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                
                self.view.backgroundColor = tempColor
                
                
            })
        })
        
        
    }
    
    

}

