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

class ForecastViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/forecast?"
    let APP_ID = "8d3cdc147cc33854e24e8e8c15f128cb"
    let locationManager = CLLocationManager()
    let forecastWeatherData = ForecastWeatherData()
    
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
    
    // Hämtar data med hjälp av CocoaPod 'Alamofire'.
    func getWeatherData(url: String, parameters: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                let forecastWeatherJSON: JSON = JSON(response.result.value!)
                print(forecastWeatherJSON)
                self.updateWeatherData(json: forecastWeatherJSON)
            }
            else {
                print("Error \(response.result.error!))")
                self.title = "Connection Issues"
            }
        }
    }
    
    // Uppdatera data med väderinformationen från JSON.
    func updateWeatherData(json: JSON) {
        if json["city"]["name"].stringValue != "" {
            
            // City name
            forecastWeatherData.city = json["city"]["name"].stringValue
            self.title = forecastWeatherData.city
            print("City: \(forecastWeatherData.city)")
            
            // City main weather
            // Ta de 16 första väderna förklaring:
            // Från "http://api.openweathermap.org/data/2.5/forecast?" får vi 40 vädern som är en 5-dagars prognos.
            // 40/5 för att få fram hur många vädern per dag = 8
            // 8 * 2 eftersom vi vill ha vädern för 2 dagar.
            var forecastMainWeatherForTodayAndTomorrow: [String] = [json["list"][0]["weather"][0]["main"].stringValue]
            for i in 1...15 {
                forecastMainWeatherForTodayAndTomorrow.append(json["list"][i]["weather"][0]["main"].stringValue)
            }
            
            // Om main weather någon gång är == "Rain" så printa "JA", annars "NEJ".
            for forecastMainWeather in forecastMainWeatherForTodayAndTomorrow {
                if forecastMainWeather == "Rain" {
                    print("NO")
                } else {
                    print("YES")
                }
            }
        }
        else {
            self.title = "Weather Unavailble"
        }
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
            getWeatherData(url: WEATHER_URL, parameters: params)
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
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "forecastChangeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
}
