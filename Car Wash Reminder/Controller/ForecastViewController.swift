//
//  ForecastViewController.swift
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

class ForecastViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {

    let FORECAST_WEATHER_URL = "http://api.openweathermap.org/data/2.5/forecast?"
    let APP_ID = "8d3cdc147cc33854e24e8e8c15f128cb"
    let locationManager = CLLocationManager()
    let weatherData = ForecastWeatherData()
    var latitude = ""
    var longitude = ""
    var userHasAllowedLocationService: Bool = false
    var logic = Logic()
    var timeIntervals = ["Varje vecka", "Varannan vecka"]
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var timeIntervalView: UIView!
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var goodDayToWashCarSwitch: UISwitch!
    @IBOutlet weak var carIsWashedSwitch: UISwitch!
    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var weeksPickerView: UIPickerView!
    @IBOutlet weak var selectedTimeIntervalLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        //logic.checkIfUserShouldWashCar()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
        addTimeIntervals()
        weeksPickerView.dataSource = self
        weeksPickerView.delegate = self
        //checkUserTimeInterval()
        //checkCarWashedStatus()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // Dölj status bar.
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // Kolla om användare har godkänt "Location when in use".
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                userHasAllowedLocationService = true
                refreshButton.isEnabled = true
            } else {
               userHasAllowedLocationService = false
                refreshButton.isEnabled = false
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

    // Send notification button.
    @IBAction func sendNotificationButtonPressed(_ sender: Any) {
        sendNotification(title: "Dags att tvätta bilen", subtitle: "Imorgon är det soligt...", body: "Passa på att tvätta bilen idag!")
    }

    // Sätt logig.thumbsUp till falsk om den är sann och till sann om den är falsk.
    @IBAction func goodDayToWashTest(_ sender: Any) {
        if logic.user.car.goodDayToWash == true {
            logic.user.car.goodDayToWash = false
        } else {
            logic.user.car.goodDayToWash = true
        }
        checkCarWashedStatus()
    }

    // Användaren drar switchen till on om bilen är tvättad
    @IBAction func carIsWashed(_ sender: Any) {
        // EJ KLAR
        if logic.user.car.isWashed == true {
            carIsWashedSwitch.isOn = false
            logic.user.car.isWashed = false
            UIApplication.shared.applicationIconBadgeNumber = 1
        } else {
            carIsWashedSwitch.isOn = true
            logic.user.car.isWashed = true
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        print("Bil är tvättad: \(logic.user.car.isWashed)")
    }

    // När använvaren väljer tidsintervall och klickar på "klar" så sparas tidsintervallet som ett heltal i logis.user.timeIntervalInWeeks.
    @IBAction func doneButton(_ sender: Any) {
        for i in 0...timeIntervals.count-1 {
            if selectedTimeIntervalLabel.text == timeIntervals[i] {
                let usersTimeIntervalInWeeks = i+1
                logic.user.timeIntervalInWeeks = usersTimeIntervalInWeeks
                print("Users time interval in weeks:",logic.user.timeIntervalInWeeks)
                logic.defaults.set(logic.user.timeIntervalInWeeks, forKey:logic.defaultsUserTimeInterval)
                timeIntervalView.isHidden = true
                homeView.isHidden = false
                logic.searchingForGoodDayToWashCar = true
            }
        }
    }
    
    // Hitta en bra dag att tvätta bilen.
    func searchForGoodDayToWashCar() {
        logic.itWillRainTodayOrTomorrow = false
        for weather in weatherData.weatherForTodayAndTomorrow {
            if weather == "Rain" || weather == "Thunderstorm" || weather == "Snow" {
                logic.itWillRainTodayOrTomorrow = true
                print("✖︎ \(weather)")
            } else {
                print("✔︎ \(weather)")
            }
        }
        if logic.itWillRainTodayOrTomorrow == true {
            print("Tvätta INTE bilen idag!")
        } else {
            print("Du kan tvätta bilen idag!")
        }
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
            weatherData.temperature = Int(tempResult - 272.15)
            weatherData.city = json["city"]["name"].stringValue
            weatherData.condition = json["list"][0]["weather"][0]["id"].intValue
            weatherData.weatherIconName = weatherData.updateWeatherIcon(condition: weatherData.condition)
            weatherData.weatherForTodayAndTomorrow.removeAll()
            for i in 0...15 {
                 weatherData.weatherForTodayAndTomorrow.append(json["list"][i]["weather"][0]["main"].stringValue)
            }
            searchForGoodDayToWashCar()
            updateUIWithWeatherData()
        }
        else {
            self.title = String("\(json["message"])").capitalized
            weatherIcon.image = UIImage(named: "dont_know")
            temperatureLabel.text = ""
        }
    }

    // Uppdaterar UI med väderdata.
    func updateUIWithWeatherData() {
        self.title = weatherData.city
        temperatureLabel.text = "\(weatherData.temperature)°"
        weatherIcon.image = UIImage(named: weatherData.weatherIconName)
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
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "threeSeconds", content: content, trigger: trigger)
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
        if let savedUserTimeInterval = logic.defaults.integer(forKey: logic.defaultsUserTimeInterval) as Int? {
            logic.user.timeIntervalInWeeks = savedUserTimeInterval
        }
        if logic.user.timeIntervalInWeeks == 0 {
            timeIntervalView.isHidden = false
            homeView.isHidden = true
        } else {
            timeIntervalView.isHidden = true
            homeView.isHidden = false
        }
    }

    // Kollar status på logic.thumbsUp (gör till enum senare) och sätter bild samt switch.
    func checkCarWashedStatus() {
        if logic.user.car.goodDayToWash == true {
            goodDayToWashCarSwitch.isOn = true
            thumbImage.image = UIImage(named: "thumbs-up")
        } else {
            goodDayToWashCarSwitch.isOn = false
            thumbImage.image = UIImage(named: "thumbs-down")
        }
    }

}

extension ForecastViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeIntervals.count
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTimeIntervalLabel.text = timeIntervals[row]
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeIntervals[row]
    }
    
}
