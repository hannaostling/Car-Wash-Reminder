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

class HomeViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    
    let FORECAST_WEATHER_URL = "http://api.openweathermap.org/data/2.5/forecast?"
    let APP_ID = "8d3cdc147cc33854e24e8e8c15f128cb"
    let locationManager = CLLocationManager()
    let weatherData = WeatherData()
    var latitude = ""
    var longitude = ""
    var userHasAllowedLocationService: Bool = false
    var logic = Logic()
    var timeIntervals = ["Varje vecka", "Varannan vecka"]
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var forecastButton: UIBarButtonItem!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var timeIntervalView: UIView!
    @IBOutlet weak var weatherDataView: UIImageView!
    @IBOutlet weak var carIsWashedRecentlySwitch: UISwitch!
    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var weeksPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
        checkUserTimeInterval()
        updatePosition()
        logic.checkIfUserShouldWashCar()
    }
    
    // Dölj status bar.
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Kolla om användare har godkänt "Location when in use".
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readUserDefaults()
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                userHasAllowedLocationService = true
            } else {
                userHasAllowedLocationService = false
            }
            print("userHasAllowedLocationService: \(userHasAllowedLocationService)")
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
    
    // När man klickar på refresh-knappen uppdateras vädret med nuvarande position.
    @IBAction func refreshButtonPressed(_ sender: Any) {
        if userHasAllowedLocationService == true {
            let params: [String:String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]
            getWeatherData(url: FORECAST_WEATHER_URL, parameters: params)
        }
    }
    
    // Användaren drar switchen till on om bilen är tvättad
    @IBAction func carIsWashed(_ sender: Any) {
        if logic.user.car.longTimeSinceUserWashedCar == false {
            logic.user.car.longTimeSinceUserWashedCar = true
        } else {
            logic.user.car.longTimeSinceUserWashedCar = false
            startSearchingAgainAfter(timeInterval: logic.user.timeIntervalInWeeks)
        }
        print("Länge sedan bil blev tvättad: \(logic.user.car.longTimeSinceUserWashedCar)")
        logic.defaults.set(logic.user.car.longTimeSinceUserWashedCar, forKey:logic.defaultsUserCarIsWashedRecently)
        updateUI()
    }
    
    // När använvaren väljer tidsintervall och klickar på "klar" så sparas tidsintervallet som ett heltal i logis.user.timeIntervalInWeeks.
    @IBAction func doneButtonPressed(_ sender: Any) {
        if logic.user.timeIntervalChoiseIsMade == false {
            logic.user.timeIntervalInWeeks = 1
        }
        print("Users time interval in weeks:",logic.user.timeIntervalInWeeks)
        checkUserTimeInterval()
        askUserForWhenInUseAuthorization()
        logic.user.timeIntervalInWeeks = logic.user.timeIntervalInWeeks
        logic.user.timeIntervalChoiseIsMade = true
        logic.searchForGoodDayToWashCar = true
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
    func searchForGoodDayToWashCar() {
        logic.noRainTodayAndTomorrow = false
        for weather in weatherData.weatherForTodayAndTomorrow {
            if weather != "Rain" || weather != "Thunderstorm" || weather != "Snow" {
                logic.noRainTodayAndTomorrow = true
                //print("✖︎ \(weather)")
            } else {
                //print("✔︎ \(weather)")
            }
        }
        if logic.washToday == true {
            let title = "Dags att tvätta bilen 🚗"
            let subtitle = "Din bil är inte tvättad nyligen och det ska vara bra väder både idag och imorgon..."
            let body = "Passa på att tvätta bilen idag!"
            sendNotification(title: title, subtitle: subtitle, body: body)
        }
    }
    
    // Börja söka igen efter användarens tidsinterval.
    func startSearchingAgainAfter(timeInterval: Int) {
        let daysToAdd = 7 * timeInterval
        let calendar = Calendar.current
        let currentDate = Date()
        logic.user.startSearchingDate = calendar.date(byAdding: .day, value: daysToAdd, to: currentDate)!
        let title = "Kanon!"
        let message = "Jag börjar leta efter en ny bra dag att tvätta bilen om \(timeInterval) veckor igen!"
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "👌🏽", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        logic.searchForGoodDayToWashCar = false
        logic.defaults.set(logic.searchForGoodDayToWashCar, forKey:logic.defaultsSearchForGoodDayBool)
        logic.defaults.set(logic.user.startSearchingDate, forKey:logic.defaultsSearchForGoodDayDate)
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
                //print(forecastWeatherJSON)
                self.updateForecastWeatherData(json: forecastWeatherJSON)
            } else {
                print("Error \(response.result.error!))")
                self.title = "Connection Issues"
            }
        }
    }
    
    // Uppdaterar forecast-väder-data med väderinformationen från JSON. Uppdaterar med tumme upp om det är en bra dag att tvätta sin bil.
    func updateForecastWeatherData(json: JSON) {
        if let tempResult = json["list"][0]["main"]["temp"].double {
            weatherData.temperature = Int(tempResult - 272.15)
            weatherData.city = json["city"]["name"].stringValue
            weatherData.condition = json["list"][0]["weather"][0]["id"].intValue
            weatherData.weatherIconName = weatherData.updateWeatherIcon(condition: weatherData.condition)
            weatherData.weatherForTodayAndTomorrow.removeAll()
            for i in 0...15 {
                weatherData.weatherForTodayAndTomorrow.append(json["list"][i]["weather"][0]["main"].stringValue)
            }
            searchForGoodDayToWashCar()
            updateUI()
        }
        else {
            self.title = String("\(json["message"])").capitalized
            weatherIcon.image = UIImage(named: "dont_know")
            temperatureLabel.text = ""
        }
    }
    
    // Uppdaterar UI.
    func updateUI() {
        self.title = weatherData.city
        temperatureLabel.text = "\(weatherData.temperature)°"
        weatherIcon.image = UIImage(named: weatherData.weatherIconName)
        if logic.user.car.longTimeSinceUserWashedCar == true {
            carIsWashedRecentlySwitch.isOn = false
        } else {
            carIsWashedRecentlySwitch.isOn = true
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
            let params: [String:String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]
            getWeatherData(url: FORECAST_WEATHER_URL, parameters: params)
        }
    }
    
    // Vid misslyckad hämtning av data, uppdatera titeln till "Location unavailable".
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        self.title = "Location unavailable"
    }
    
    // Notification settings
    func sendNotification(title: String, subtitle: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.badge = 1
        content.sound = UNNotificationSound.default
        var dateComponents = DateComponents()
        dateComponents.hour = 17
        dateComponents.minute = 00
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "17:00", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
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
            homeView.isHidden = true
            weatherDataView.isHidden = true
            timeIntervalView.isHidden = false
            forecastButton.isEnabled = false
            refreshButton.isEnabled = false
            searchButton.isEnabled = false
            addTimeIntervals()
            weeksPickerView.dataSource = self
            weeksPickerView.delegate = self
        } else {
            homeView.isHidden = false
            weatherDataView.isHidden = false
            timeIntervalView.isHidden = true
            forecastButton.isEnabled = true
            refreshButton.isEnabled = true
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
    
    // Läser sparad data.
    func readUserDefaults() {
        print("*** Reading from user defaults ***")
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
            print("• RÄTT: User search again date: \(logic.user.startSearchingDate)")
        }
        print("• FEL: User search again date: \(logic.user.startSearchingDate)")
    }
    
    // Ge användaren en prognos.
    func giveForecastAlert() {
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
        let message = "\(longTimeSinceUserWashedCar) Det var länge sedan du tvättade bilen \n \(noRainTodayAndTomorrow) Vädret är bra idag och imorgon \n \(searchForGoodDayToWashCar) Appen letar efter ett bra datum just nu"
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Okej", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
