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
    
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var currentHumidityLabel: UILabel!
    @IBOutlet weak var currentPrecipitationLabel: UILabel!
    @IBOutlet weak var currentWeatherIcon: UIImageView!
    @IBOutlet weak var currentWeatherSummary: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    var currentLongitude: Double
    var currentLatitude: Double
    
    required init?(coder aDecoder: NSCoder) {
        self.currentLatitude = 37.8267
        self.currentLongitude = -122.4233
        super.init(coder: aDecoder)
        
    }
    
    private let forecastAPIKey: String = {
        if let plistPath = NSBundle.mainBundle().pathForResource("APIKey", ofType: "plist"),
            let weatherDictionary = NSDictionary(contentsOfFile: plistPath), let APIKey = weatherDictionary["APIKey"] as? String {
                return weatherDictionary["APIKey"] as! String
        } else {
            return ""
        }
    }()
    
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
        print("forecast key: \(forecastAPIKey)")
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
                        self.currentTemperatureLabel.text = "\(temperature)º"
                    }
                    if let humidity = currentWeather.humidity {
                        self.currentHumidityLabel.text = "\(humidity)%"
                    }
                    if let precipitation = currentWeather.precipProbability {
                        self.currentPrecipitationLabel.text = "\(precipitation)%"
                    }
                    
                    if let icon = currentWeather.icon {
                        self.currentWeatherIcon.image = icon
                    }
                    
                    if let summary = currentWeather.summary {
                        self.currentWeatherSummary.text = summary
                    }
                    
                    if let feelsLikeTemp = currentWeather.feelsLikeTemp {
                        self.feelsLikeLabel.text = "\(feelsLikeTemp)º"
                    }
                    self.reverseGeocoder(self.currentLatitude, long: self.currentLongitude)
                    self.toggleRefreshAnimation(false)
                }
            }
        }
    }

    func reverseGeocoder(lat: Double, long: Double) {
        
        let location = CLLocation(latitude: lat, longitude: long)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemark, error) -> Void in
            if error != nil {
                print("Error: \(error!.localizedDescription) ")
                return
            }
            if let pm = placemark?.first {
             self.locationLabel.text = "\(pm.locality!), \(pm.country!) "
            }
             else {
                print("Error with data")
            }
        })
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("location = \(locValue.latitude), \(locValue.longitude)")
        currentLatitude = locValue.latitude
        currentLongitude = locValue.longitude
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



