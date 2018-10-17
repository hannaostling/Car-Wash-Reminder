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
    
    let FORECAST_WEATHER_URL = "http://api.openweathermap.org/data/2.5/forecast?"
    let APP_ID = "8d3cdc147cc33854e24e8e8c15f128cb"
    let locationManager = CLLocationManager()
    let weatherData = WeatherData()
    var latitude = ""
    var longitude = ""
    var userHasAllowedLocationService: Bool = false
    var logic = Logic()
    var timeIntervals = ["Varje vecka", "Varannan vecka"]
    var retrievedData: Bool = true
    var counter = 0
    var fetchedDataTime = Date()
    
    @IBOutlet weak var positionButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var forecastButton: UIBarButtonItem!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var timeIntervalView: UIView!
    @IBOutlet weak var weatherDataView: UIImageView!
    @IBOutlet weak var weeksPickerView: UIPickerView!
    @IBOutlet weak var washedCarButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
        checkUserTimeInterval()
        logic.logicDelegate = self
        if logic.user.timeIntervalChoiseIsMade == true {
            askUserForWhenInUseAuthorization()
            updatePosition()
            logic.checkIfUserShouldWashCar()
        }
        if weatherData.city == "" {
            retrievedData = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readUserDefaults()
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                userHasAllowedLocationService = true
            } else {
                userHasAllowedLocationService = false
            }
        }
    }
    
    // Dölj status bar.
    override var prefersStatusBarHidden: Bool {
        return true
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
        if userHasAllowedLocationService == true {
            print(logic.user.positionParams)
            getWeatherData(url: FORECAST_WEATHER_URL, parameters: logic.user.positionParams)
            positionButton.isEnabled = false
        }
        print("Position button pressed!")
    }
    
    // När man klickar på "Nu är bilen tvättad" så markeras bilen som tvättad nyligen och appen tar en paus från att leta efter en bra dag att tvätta bilen med tidsintervallet som användaren har valt.
    @IBAction func washedCarButtonPressed(_ sender: Any) {
        var title = "Är du säker?"
        var message = "Vill du verkligen markera bilen som tvättad? Appen kommer att sluta leta efter en bra dag att tvätta bilen på \(logic.user.timeIntervalInWeeks) veckor om du trycker på \"Ja\"."
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Nej", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ja", style: UIAlertAction.Style.default, handler: { action in
            self.logic.searchForGoodDayToWashCar = false
            self.logic.user.car.longTimeSinceUserWashedCar = false
            self.logic.user.startSearchingAgainAfter(timeInterval: self.logic.user.timeIntervalInWeeks)
            self.updateUI()
            title = "Kanon!"
            message = "Jag börjar leta efter en ny bra dag att tvätta bilen om \(self.logic.user.timeIntervalInWeeks) veckor igen!"
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "👌🏽", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.logic.defaults.set(self.logic.user.car.longTimeSinceUserWashedCar, forKey:self.logic.defaultsUserCarIsWashedRecently)
            self.logic.defaults.set(self.logic.searchForGoodDayToWashCar, forKey:self.logic.defaultsSearchForGoodDayBool)
            self.logic.defaults.set(self.logic.user.startSearchingDate, forKey:self.logic.defaultsSearchForGoodDayDate)
        }))
        self.present(alert, animated: true, completion: nil)
        updateUI()
    }
    
    // När använvaren väljer tidsintervall och klickar på "klar" så sparas tidsintervallet som ett heltal i logis.user.timeIntervalInWeeks.
    @IBAction func doneButtonPressed(_ sender: Any) {
        if logic.user.timeIntervalChoiseIsMade == false {
            logic.user.timeIntervalInWeeks = 1
        }
        checkUserTimeInterval()
        askUserForWhenInUseAuthorization()
        logic.user.timeIntervalInWeeks = logic.user.timeIntervalInWeeks
        logic.user.timeIntervalChoiseIsMade = true
        logic.searchForGoodDayToWashCar = true
        logic.user.car.longTimeSinceUserWashedCar = true
        logic.defaults.set(logic.user.car.longTimeSinceUserWashedCar, forKey:logic.defaultsUserCarIsWashedRecently)
        logic.defaults.set(logic.user.timeIntervalInWeeks, forKey:logic.defaultsUserTimeInterval)
        logic.defaults.set(logic.user.timeIntervalChoiseIsMade, forKey:logic.defaultsUserMadeChoice)
        logic.defaults.set(logic.searchForGoodDayToWashCar, forKey:logic.defaultsSearchForGoodDayBool)
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
        positionButton.isEnabled = true
        let cityName = searchBar.text!
        logic.user.cityParams = ["q": cityName, "appid": APP_ID]
        getWeatherData(url: FORECAST_WEATHER_URL, parameters: logic.user.cityParams)
        logic.user.city = cityName
        logic.defaults.set(logic.user.cityParams, forKey: logic.defaultsCityParams)
        logic.defaults.set(logic.user.city, forKey: logic.defaultsUserCity)
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
        checkBadRequest()
    }
    
    // Hämtar data antingen från användarens stad, eller med geografiska positionen.
    func getWeather() {
        if logic.user.city == "" {
            logic.user.positionParams = ["lat": latitude, "lon": longitude, "appid": APP_ID]
            getWeatherData(url: FORECAST_WEATHER_URL, parameters: logic.user.positionParams)
            logic.defaults.set(logic.user.positionParams, forKey: logic.defaultsPositionParams)
            positionButton.isEnabled = false
        } else {
            getWeatherData(url: FORECAST_WEATHER_URL, parameters: logic.user.cityParams)
            positionButton.isEnabled = true
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
            checkRain()
            updateUI()
        }
        else {
            self.retrievedData = false
            self.title = String("\(json["message"])").capitalized
            weatherIcon.image = UIImage(named: "dont_know")
            temperatureLabel.text = ""
        }
        checkBadRequest()
    }
    
    // Uppdaterar UI.
    func updateUI() {
        self.title = weatherData.city
        temperatureLabel.text = "\(weatherData.temperature)°"
        weatherIcon.image = UIImage(named: weatherData.weatherIconName)
        checkBadRequest()
        if logic.user.car.longTimeSinceUserWashedCar == true {
            washedCarButton.isEnabled = true
        } else {
            washedCarButton.isEnabled = false
        }
    }
    
    // Hämtar användarens position om användaren godkänner "Location When In Use".
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)" )
            latitude = String(location.coordinate.latitude)
            longitude = String(location.coordinate.longitude)
            getWeather()
        }
    }
    
    // Vid misslyckad hämtning av data, uppdatera titeln till "Location unavailable".
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.title = "Location unavailable"
        retrievedData = false
        print(error)
    }
    
    // Lägger till fler element i timeIntervals.
    func addTimeIntervals() {
        for i in 3...12 {
            let timeInterval = "Var \(i):e vecka"
            timeIntervals.append(timeInterval)
        }
    }
    
    // Kollar om användaren har valt ett tidsintervall.
    func checkUserTimeInterval() {
        readUserDefaults()
        if logic.user.timeIntervalChoiseIsMade == false {
            title = ""
            weatherDataView.isHidden = true
            washedCarButton.isHidden = true
            timeIntervalView.isHidden = false
            forecastButton.isEnabled = false
            searchButton.isEnabled = false
            addTimeIntervals()
            weeksPickerView.dataSource = self
            weeksPickerView.delegate = self
        } else {
            weatherDataView.isHidden = false
            washedCarButton.isHidden = false
            timeIntervalView.isHidden = true
            forecastButton.isEnabled = true
            searchButton.isEnabled = true
        }
    }
    
    // Uppdatera positionen om användare tillåtit tillståndet.
    func updatePosition() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
    }
    
    // Fråga användaren om tillstånd att kolla position när användaren använder appen.
    func askUserForWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
        updatePosition()
    }
    
    // Kollar om vi lyckats hämta data och om vi inte gjort det, ska man inte kunna klicka på "Prognos".
    func checkBadRequest() {
        if retrievedData == true {
            forecastButton.isEnabled = true
        } else {
            forecastButton.isEnabled = false
        }
    }
    
    // Läser sparad data.
    func readUserDefaults() {
        print("")
        print("• USER DEFAULTS ")
        if let searchForGoodDay = logic.defaults.bool(forKey: logic.defaultsSearchForGoodDayBool) as Bool? {
            logic.searchForGoodDayToWashCar = searchForGoodDay
            print("• Searching for good day to wash car: \(logic.searchForGoodDayToWashCar)")
        }
        if let noChoise = logic.defaults.bool(forKey: logic.defaultsUserMadeChoice) as Bool? {
            logic.user.timeIntervalChoiseIsMade = noChoise
            print("• User has made a timeinterval choise: \(logic.user.timeIntervalChoiseIsMade)")
        }
        if let savedUserTimeIntervalInWeeks = logic.defaults.integer(forKey: logic.defaultsUserTimeInterval) as Int? {
            logic.user.timeIntervalInWeeks = savedUserTimeIntervalInWeeks
            print("• User timeinterval in weeks: \(logic.user.timeIntervalInWeeks)")
        }
        if let savedUserCarIsWashedRecently = logic.defaults.bool(forKey: logic.defaultsUserCarIsWashedRecently) as Bool? {
            logic.user.car.longTimeSinceUserWashedCar = savedUserCarIsWashedRecently
            print("• Long time since user washed car: \(logic.user.car.longTimeSinceUserWashedCar)")
        }
        if let savedUserSearchAgainDate = logic.defaults.object(forKey: logic.defaultsSearchForGoodDayDate) {
            logic.user.startSearchingDate = savedUserSearchAgainDate as! Date
            print("• App start searching: \(logic.user.startSearchingDate)")
        }
        if let savedUserCity = logic.defaults.string(forKey: logic.defaultsUserCity) as String? {
            logic.user.city = savedUserCity
            print("• User city: \(logic.user.city)")
        }
        if let savedUserCityParams = logic.defaults.dictionary(forKey: logic.defaultsCityParams) as! [String:String]? {
            logic.user.cityParams = savedUserCityParams
        }
        if let savedUserPositionParams = logic.defaults.dictionary(forKey: logic.defaultsPositionParams) as! [String:String]? {
            logic.user.positionParams = savedUserPositionParams
        }
    }
    
    // Ge användaren en prognos.
    func giveForecastAlert() {
        checkRain()
        readUserDefaults()
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
            print("Notification today because washToday is true!")
            let title = "Dags att tvätta bilen 🚗"
            let body = "Det var länge sedan du tvättade din bil och det ska vara bra väder i \(weatherData.city) både idag och imorgon ☀️"
            logic.sendNotification(title: title, body: body)
        } else {
            print("No notification today because washToday is false!")
        }
        print("")
        print("* BACKGROUND-FETCH")
        print("* Appen söker efter datum: \(logic.searchForGoodDayToWashCar)")
        print("* Länge sedan bilen var tvättad: \(logic.user.car.longTimeSinceUserWashedCar)")
        print("* Inget regn idag och imorgon: \(logic.noRainTodayAndTomorrow)")
        
        let formatter = DateFormatter()
        let currentTime = Date()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.string(from: currentTime)
        let fetchedDate = formatter.string(from: fetchedDataTime)
        print("* Tid för bakcground-fetch: \(date)")
        print("* Tid för väder-fetch: \(fetchedDate)")
        
        print("* Väder stad: \(weatherData.city)")
        print("* Väder temperatur: \(weatherData.temperature)")
        print("* Väderlag id: \(weatherData.condition)")
    }
        
}

extension HomeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeIntervals.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        logic.user.timeIntervalChoiseIsMade = true
        let selectedWeekInterval = row+1
        logic.user.timeIntervalInWeeks = selectedWeekInterval
        logic.defaults.set(logic.user.timeIntervalInWeeks, forKey:logic.defaultsUserTimeInterval)
        logic.defaults.set(logic.user.timeIntervalChoiseIsMade, forKey:logic.defaultsUserMadeChoice)
        print("Selected time interval: \(selectedWeekInterval)")
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeIntervals[row]
    }
    
}
