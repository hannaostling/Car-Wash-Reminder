//
//  ForecastViewController.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-11.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ForecastViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, ChangeCityDelegate {
    
    let FORECAST_WEATHER_URL = "http://api.openweathermap.org/data/2.5/forecast?"
    let APP_ID = "8d3cdc147cc33854e24e8e8c15f128cb"
    let locationManager = CLLocationManager()
    let forecastWeatherData = ForecastWeatherData()
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Dölj status bar.
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // När man klickar på sök-knappen visas en sök-ruta.
    @IBAction func searchButton(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Visa väder för en annan stad"
        searchController.searchBar.autocapitalizationType = .words
        present(searchController, animated: true, completion: nil)
    }
    
    // När man klickat på sök, hämta data från den inskrivna staden!
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let cityName = searchBar.text!
        let params: [String:String] = ["q": cityName, "appid": APP_ID]
        getWeatherData(url: FORECAST_WEATHER_URL, parameters: params)
    }
    
    // Hämtar data med hjälp av CocoaPod 'Alamofire'.
    func getWeatherData(url: String, parameters: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                let forecastWeatherJSON: JSON = JSON(response.result.value!)
                print(forecastWeatherJSON)
                self.updateForecastWeatherData(json: forecastWeatherJSON)
            } else {
                print("Error \(response.result.error!))")
                self.title = "Connection Issues"
            }
        }
    }
    
    // Uppdaterar forecast-väder-data med väderinformationen från JSON.
    func updateForecastWeatherData(json: JSON) {
        if let tempResult = json["list"][0]["main"]["temp"].double {
            forecastWeatherData.temperature = Int(tempResult - 272.15)
            forecastWeatherData.name = json["city"]["name"].stringValue
            forecastWeatherData.condition = json["list"][0]["weather"][0]["id"].intValue
            forecastWeatherData.weatherIconName = forecastWeatherData.updateWeatherIcon(condition: forecastWeatherData.condition)
            var forecastMainWeatherForTodayAndTomorrow: [String] = [json["list"][0]["weather"][0]["main"].stringValue]
            for i in 1...15 {
                forecastMainWeatherForTodayAndTomorrow.append(json["list"][i]["weather"][0]["main"].stringValue)
            }
            for forecastMainWeather in forecastMainWeatherForTodayAndTomorrow {
                if forecastMainWeather == "Rain" || forecastMainWeather == "Thunderstorm" || forecastMainWeather == "Snow" {
                    print("NO: \(forecastMainWeather)")
                } else {
                    print("YES: \(forecastMainWeather)")
                }
            }
            updateUIWithWeatherData()
        }
        else {
            self.title = "Weather Unavailble"
        }
    }
    
    // Uppdaterar UI med väderdata.
    func updateUIWithWeatherData() {
        self.title = forecastWeatherData.name
        temperatureLabel.text = "\(forecastWeatherData.temperature)°"
        weatherIcon.image = UIImage(named: forecastWeatherData.weatherIconName)
    }
    
    // Hämtar användarens position om användaren godkänner "Location When In Use".
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)" )
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params: [String:String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]
            getWeatherData(url: FORECAST_WEATHER_URL, parameters: params)
        }
    }
    
    // Vid misslyckad hämtning av data, uppdatera titeln till "Location unavailable".
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        self.title = "Location unavailable"
    }
    
    // När användaren skriver in en stad i ChangeCityViewController, uppdatera vyn med data från inskrivna staden.
    func userEnteredANewCityName(city: String) {
        let params: [String:String] = ["q": city, "appid": APP_ID]
        //getWeatherData(url: WEATHER_URL, parameters: params)
        getWeatherData(url: FORECAST_WEATHER_URL, parameters: params)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
}
