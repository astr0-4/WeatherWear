//
//  ViewController.swift
//  Stormy
//
//  Created by Alex on 2015-09-02.
//  Copyright (c) 2015 Alex. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentWeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var currentTemperatureLabel: UILabel?
    @IBOutlet weak var currentHumidityLabel: UILabel?
    @IBOutlet weak var currentPrecipitationLabel: UILabel?
    @IBOutlet weak var currentWeatherIcon: UIImageView?
    @IBOutlet weak var currentWeatherSummary: UILabel?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var refreshButton: UIButton?
    
    let locationManager = CLLocationManager()
    var currentLongitude: Double = 37.8267
    var currentLatitude: Double = -122.4233
    
    private let forecastAPIKey: String = {
        if let plistPath = NSBundle.mainBundle().pathForResource("CurrentWeather", ofType: "plist"),
            let weatherDictionary = NSDictionary(contentsOfFile: plistPath), let APIKey = weatherDictionary["APIKey"] as? String {
                return weatherDictionary["APIKey"] as! String
        } else {
            return ""
        }
    }()
    
//    let currentCoordinate: (lat: Double, long: Double) = {
//        var locValue:CLLocationCoordinate2D = locationManager.location.coordinate
//        var currentLocation = CLLocation()
//        var currentLatitude = currentLocation.coordinate.latitude
//        var currentLongitude = currentLocation.coordinate.longitude
//        return (currentLatitude, currentLongitude)
//    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        }
        
        retrieveWeatherForecast(currentLatitude, long: currentLongitude)
      //  println("current location: \(coordinate)")

        println("forecast key: \(forecastAPIKey)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrieveWeatherForecast(lat: Double, long: Double) {
        let forecastService = ForecastService(APIKey: forecastAPIKey)
        forecastService.getForecast(currentLatitude, long: currentLongitude) {
            (let currently) in
            if let currentWeather = currently {
                // update UI
                dispatch_async(dispatch_get_main_queue()) {
                    if let temperature = currentWeather.temperature {
                        self.currentTemperatureLabel?.text = "\(temperature)º"
                    }
                    if let humidity = currentWeather.humidity {
                        self.currentHumidityLabel?.text = "\(humidity)%"
                    }
                    if let precipitation = currentWeather.precipProbability {
                        self.currentPrecipitationLabel?.text = "\(precipitation)%"
                    }
                    
                    if let icon = currentWeather.icon {
                        self.currentWeatherIcon?.image = icon
                    }
                    
                    if let summary = currentWeather.summary {
                        self.currentWeatherSummary?.text = summary
                    }
                                       
                    self.toggleRefreshAnimation(false)
                }
            }
        }
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        
        println("location = \(locValue.latitude), \(locValue.longitude)")
        var currentLocation = CLLocation()
        currentLatitude = currentLocation.coordinate.latitude
        currentLongitude = currentLocation.coordinate.longitude
    }

    @IBAction func refreshWeather() {
        toggleRefreshAnimation(true)
        retrieveWeatherForecast(currentLatitude, long:currentLongitude)
    }
    
    func toggleRefreshAnimation(on: Bool) {
        refreshButton?.hidden = on
        if on {
            activityIndicator?.startAnimating()
        } else {
            activityIndicator?.stopAnimating()
        }
    }
}



