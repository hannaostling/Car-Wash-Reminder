//
//  HomeViewController.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-11.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation
import Alamofire
import SwiftyJSON

class HomeViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, LogicDelegate {
    
    let locationManager = CLLocationManager()
    let weatherData = WeatherData()
    var latitude = ""
    var longitude = ""
    var retrievedData: Bool = true
    var fetchedDataTime = Date()
    var positionOrSearch = PositionOrSearch.position
    let logic = StartViewController.logic
    
    @IBOutlet weak var positionButton: UIBarButtonItem!
    @IBOutlet weak var forecastButton: UIBarButtonItem!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherDataView: UIImageView!
    @IBOutlet weak var washedCarButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logic.logicDelegate = self
        logic.askForNotificationPermission()
        logic.checkIfUserShouldWashCar()
        updatePosition()
        if weatherData.city == "" {
            retrievedData = false
        }
    }
    
    // När man klickar på sök-knappen visas en sök-ruta.
    @IBAction func searchButtonPressed(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Visa väder för en annan stad"
        searchController.searchBar.autocapitalizationType = .words
        present(searchController, animated: true, completion: nil)
    }
    
    // När man klickar på position-knappen uppdateras vädret med nuvarande position.
    @IBAction func positionButtonPressed(_ sender: Any) {
        updatePosition()
    }
    
    // När man klickar på "Nu är bilen tvättad" så markeras bilen som tvättad nyligen och appen tar en paus från att leta efter en bra dag att tvätta bilen med tidsintervallet som användaren har valt.
    @IBAction func washedCarButtonPressed(_ sender: Any) {
        var title = "Är du säker?"
        var message = "Appen kommer att sluta leta efter en bra dag att tvätta bilen på \(logic.user.timeIntervalInWeeks) veckor om du trycker på \"Ja\"."
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Nej", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ja", style: UIAlertAction.Style.default, handler: { action in
            self.logic.searchForGoodDayToWashCar = false
            self.logic.user.car.longTimeSinceUserWashedCar = false
            self.logic.user.startSearchingAgainAfter(timeInterval: self.logic.user.timeIntervalInWeeks)
            //self.updatUI()
            title = "Kanon"
            message = "Jag börjar leta efter en ny bra dag att tvätta bilen om \(self.logic.user.timeIntervalInWeeks) veckor igen!"
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "👌🏽", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.logic.defaults.set(self.logic.user.car.longTimeSinceUserWashedCar, forKey:self.logic.defaultsUserCarIsWashedRecently)
            self.logic.defaults.set(self.logic.searchForGoodDayToWashCar, forKey:self.logic.defaultsSearchForGoodDayBool)
            self.logic.defaults.set(self.logic.user.startSearchingDate, forKey:self.logic.defaultsSearchForGoodDayDate)
        }))
        self.present(alert, animated: true, completion: nil)
        setButtonsEnabledOrNotEnabled()
        //updateIWithWeatherData()
    }
    
    // Ge användaren en prognos, varför är det bra/inte bra att tvätta bilen idag?
    @IBAction func forecastButtonPressed(_ sender: Any) {
        giveForecastAlert()
    }
        
    // Ge ja/nej meddelande från bool.
    func boolMessageEmoji(bool: Bool) -> String {
        if bool == true {
            return "✅"
        } else {
            return "❌"
        }
    }
    
    // Hitta en bra dag att tvätta bilen.
    func checkRain() {
        var countBadWeather = 0
        for weather in weatherData.weatherForTodayAndTomorrow {
            if weather == "Rain" || weather == "Thunderstorm" || weather == "Snow" {
                countBadWeather += 1
                print("☔️ \(weather)")
            } else {
                print("🌞 \(weather)")
            }
        }
        if countBadWeather <= 0 {
            logic.noRainTodayAndTomorrow = true
        } else {
            logic.noRainTodayAndTomorrow = false
        }
    }
        
    // När man klickat på sök, hämta data från den inskrivna staden!
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let cityName = searchBar.text!
        logic.user.cityParams = ["q": cityName, "appid": logic.APP_ID]
        logic.defaults.set(logic.user.cityParams, forKey: logic.defaultsCityParams)
        //logic4.user.lastSearchedCity = cityName
        //logic.defaults.set(logi3c.user.lastSearchedCity, forKey: logic.defaultsUserLastSearchedCity)
        positionOrSearch = .search
        getWeather(positionOrSearch: .search)
    }
    
    // Hämtar data med hjälp av CocoaPod 'Alamofire'.
    func getWeatherData(url: String, parameters: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                let forecastWeatherJSON: JSON = JSON(response.result.value!)
                self.updateForecastWeatherData(json: forecastWeatherJSON)
                self.retrievedData = true
                self.fetchedDataTime = Date()
                //print(forecastWeatherJSON)
            } else {
                print("Error \(response.result.error!))")
                self.title = "Connection Issues"
                self.retrievedData = false
            }
        }
    }
    
    // Hämtar data antingen från användarens stad, eller med geografiska positionen.
    func getWeather(positionOrSearch: PositionOrSearch) {
        logic.readUserDefaults()
        if positionOrSearch == .position {
            print("Get weather with position params")
            getWeatherData(url: logic.FORECAST_URL, parameters: logic.user.positionParams)
        } else {
            print("Get weather with city params")
            getWeatherData(url: logic.FORECAST_URL, parameters: logic.user.cityParams)
        }
    }
    
    // Uppdaterar forecast-väder-data med väderinformationen från JSON. Uppdaterar med tumme upp om det är en bra dag att tvätta sin bil.
    func updateForecastWeatherData(json: JSON) {
        if let tempResult = json["list"][0]["main"]["temp"].double {
            self.retrievedData = true
            weatherData.temperature = Int(tempResult - 272.15)
            weatherData.city = json["city"]["name"].stringValue
            weatherData.condition = json["list"][0]["weather"][0]["id"].intValue
            weatherData.weatherIconName = weatherData.updateWeatherIcon(condition: weatherData.condition)
            weatherData.weatherForTodayAndTomorrow.removeAll()
            for i in 0...15 {
                weatherData.weatherForTodayAndTomorrow.append(json["list"][i]["weather"][0]["main"].stringValue)
            }
            print(weatherData.city)
            DispatchQueue.main.async {
                self.checkRain()
                self.title = self.weatherData.city
                self.temperatureLabel.text = "\(self.weatherData.temperature)°"
                self.weatherIcon.image = UIImage(named: self.weatherData.weatherIconName)
                if self.positionOrSearch == .position {
                    self.weatherData.city = self.logic.user.lastPositionCity
                    self.logic.defaults.set(self.logic.user.lastPositionCity, forKey: self.logic.defaultsUserLastPositionCity)
                    print("Fel: \(self.weatherData.city)")
                    print("Fel: \(self.logic.user.lastPositionCity)")
                } else {
                    self.weatherData.city = self.logic.user.lastSearchedCity
                    self.logic.defaults.set(self.logic.user.lastSearchedCity, forKey: self.logic.defaultsUserLastSearchedCity)
                    print("Fel: \(self.weatherData.city)")
                    print("Fel: \(self.logic.user.lastSearchedCity)")
                }
                self.setButtonsEnabledOrNotEnabled()
            }
        }
        else {
            self.retrievedData = false
            self.title = String("\(json["message"])").capitalized
            weatherIcon.image = UIImage(named: "dont_know")
            temperatureLabel.text = ""
        }
    }
    
    // Hämtar användarens position om användaren godkänner "Location When In Use".
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            //print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)" )
            latitude = String(location.coordinate.latitude)
            longitude = String(location.coordinate.longitude)
            //losgic.user.lastPositionCity = weatherData.city
            //logic.defaults.set(logsic.user.lastPositionCity, forKey: logic.defaultsUserLastPositionCity)
            logic.user.positionParams = ["lat": latitude, "lon": longitude, "appid": logic.APP_ID]
            logic.defaults.set(logic.user.positionParams, forKey: logic.defaultsPositionParams)
            positionOrSearch = .position
            getWeather(positionOrSearch: .position)
        }
    }
    
    // Vid misslyckad hämtning av data, uppdatera titeln till "Location unavailable".
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.title = "Plats ej tillgänglig"
        retrievedData = false
        print(error)
    }
    
    // Uppdatera användarens position
    func updatePosition() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
    }
    
    // Sätter knapparnas tillgänglighet beroende på olika villkor.
    func setButtonsEnabledOrNotEnabled() {
        if logic.user.car.longTimeSinceUserWashedCar == true {
            washedCarButton.isEnabled = true
        } else {
            washedCarButton.isEnabled = false
        }
        if retrievedData == true {
            forecastButton.isEnabled = true
        } else {
            forecastButton.isEnabled = false
        }
        if title == "\(logic.user.lastPositionCity)" {
            positionButton.isEnabled = false
        } else {
            positionButton.isEnabled = true
        }
    }
    
    // Ge användaren en prognos.
    func giveForecastAlert() {
        logic.readUserDefaults()
        checkRain()
        var title = ""
        if logic.washToday == true {
            title = "Tvätta bilen idag 😍"
        } else {
            title = "Tvätta inte bilen idag 🙄"
        }
        let longTimeSinceUserWashedCar = boolMessageEmoji(bool: logic.user.car.longTimeSinceUserWashedCar)
        let noRainTodayAndTomorrow = boolMessageEmoji(bool: logic.noRainTodayAndTomorrow)
        let searchForGoodDayToWashCar = boolMessageEmoji(bool: logic.searchForGoodDayToWashCar)
        let howManyDaysLeftToSearchDate = logic.user.howManyDaysToSearchingDate()
        let message = "\(longTimeSinceUserWashedCar) Bilen är inte tvättad nyligen \n \(noRainTodayAndTomorrow) Vädret är bra idag och imorgon \n \(searchForGoodDayToWashCar) \(howManyDaysLeftToSearchDate) dagar kvar tills appen börjar leta efter en bra dag att tvätta bilen."
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Okej", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Background fetch
    func notifyUser(washToday: Bool) {
        if washToday == true {
            //print("Give user notification today!")
            let title = "Dags att tvätta bilen 🚗"
            let body = "Det var länge sedan du tvättade din bil och det ska vara bra väder i \(weatherData.city) både idag och imorgon ☀️"
            logic.sendNotification(title: title, body: body)
        } else {
            //print("Don't give user notification today!")
        }
//        print("")
//        print("* BACKGROUND-FETCH")
//        print("* Appen söker efter datum: \(logic.searchForGoodDayToWashCar)")
//        print("* Länge sedan bilen var tvättad: \(logic.user.car.longTimeSinceUserWashedCar)")
//        print("* Inget regn idag och imorgon: \(logic.noRainTodayAndTomorrow)")
//        let formatter = DateFormatter()
//        let currentTime = Date()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        let date = formatter.string(from: currentTime)
//        let fetchedDate = formatter.string(from: fetchedDataTime)
//        print("* Tid för bakcground-fetch: \(date)")
//        print("* Tid för väder-fetch: \(fetchedDate)")
//        print("* Väder stad: \(weatherData.city)")
//        print("* Väder temperatur: \(weatherData.temperature)")
//        print("* Väderlag id: \(weatherData.condition)")
    }
        
}

enum PositionOrSearch {
    case position
    case search
}
