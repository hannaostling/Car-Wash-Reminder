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
    var retrievedDataButDidNotSucceed = false
    var fetchedDataTime = Date()
    let logic = StartViewController.logic
    var positionOrSearch = PositionOrSearch.position
    
    //@IBOutlet weak var positionButton: UIBarButtonItem!
    @IBOutlet weak var forecastButton: UIBarButtonItem!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherDataView: UIImageView!
    @IBOutlet weak var washedCarButton: UIButton!
    
    
    @IBOutlet weak var citySegmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        logic.logicDelegate = self
        logic.askForNotificationPermission()
        logic.checkIfUserShouldWashCar()
        if let value = UserDefaults.standard.value(forKey: logic.defaultsSelectedCity) {
            let selectedIndex = value as! Int
            citySegmentControl.selectedSegmentIndex = selectedIndex
        }
        if citySegmentControl.selectedSegmentIndex == 0 {
            updatePosition()
        } else {
            positionOrSearch = .search
            getWeather(positionOrSearch: .search)
        }
        if weatherData.city == "" {
            retrievedData = false
        }
    }
    
    // Gå till Historik
    @IBAction func historyButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "fromHomeToHistory", sender: self)
    }
    
    // När man klickar på sök-knappen visas en sök-ruta.
    @IBAction func searchButtonPressed(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Visa väder för en annan stad"
        searchController.searchBar.autocapitalizationType = .words
        present(searchController, animated: true, completion: nil)
    }

    // När man klickar på "Nu är bilen tvättad" så markeras bilen som tvättad nyligen och appen tar en paus från att leta efter en bra dag att tvätta bilen med tidsintervallet som användaren har valt.
    @IBAction func washedCarButtonPressed(_ sender: Any) {
        var title = "Är du säker?"
        var message = ""
        if self.logic.user.timeIntervalInWeeks == 1 {
            message = "Appen kommer pausa letandet efter en bra dag att tvätta bilen i \(logic.user.timeIntervalInWeeks) vecka om du trycker på \"Ja\"."
        } else {
            message = "Appen kommer pausa letandet efter en bra dag att tvätta bilen i \(logic.user.timeIntervalInWeeks) veckor om du trycker på \"Ja\"."
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Nej", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ja", style: UIAlertAction.Style.default, handler: { action in
            self.logic.user.startSearchingAgainAfter(timeInterval: self.logic.user.timeIntervalInWeeks)
            let carIndex = self.logic.user.chosenCarIndex
            // Skapar temorär array för car-objekt
            var cars = [Car]()
            for carDictionary in self.logic.user.carObject.carDataDictionaryArray {
                let car = Car(dataDictionary: carDictionary)
                cars.append(car)
            }
            // Tar bort det carObjekt som ska ändras
            cars.remove(at: carIndex)
            // Skapa nytt car-objekt
            let car = Car()
            car.name = self.logic.user.carObject.carDataDictionaryArray[carIndex][self.logic.user.carObject.carName] as! String
            car.isNotClean = false
            car.isNotCleanDate = self.logic.user.carObject.carDataDictionaryArray[carIndex][self.logic.user.carObject.carIsNotCleanDate] as! Date
            car.washedDates = self.logic.user.carObject.carDataDictionaryArray[carIndex][self.logic.user.carObject.carWashedDates] as! [Date]
            car.washedDates.append(Date())
            // Lägg till det nya (blir som att vi  ändrat ett element)
            cars.append(car)
            // Skapa ny array med dictionaries för att hålla all data som skall sparas
            var carsDataArray = [[String:Any]]()
            for car in cars {
                let carDictionaryFromObject = car.dataDictionaryFromObject()
                carsDataArray.append(carDictionaryFromObject)
            }
            // Spara
            self.logic.defaults.set(carsDataArray, forKey: self.logic.defaultsCarDataDictionaryArray)
            // Ändrar chosenCarIndex till den som vi la till nu
            print("Chosen index: \(self.logic.user.chosenCarIndex)")
            self.logic.user.chosenCarIndex = carsDataArray.count-1
            print("Chosen index: \(self.logic.user.chosenCarIndex)")
            // Sparar
            self.logic.defaults.set(self.logic.user.chosenCarIndex, forKey:self.logic.defaultsUserChosenCarIndex)
            title = "Kanon"
            if self.logic.user.timeIntervalInWeeks == 1 {
                message = "Jag börjar leta efter en ny bra dag att tvätta bilen om \(self.logic.user.timeIntervalInWeeks) vecka igen!"
            } else {
                message = "Jag börjar leta efter en ny bra dag att tvätta bilen om \(self.logic.user.timeIntervalInWeeks) veckor igen!"
            }
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "👌🏽", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.logic.defaults.set(self.logic.user.startSearchingDate, forKey:self.logic.defaultsSearchForGoodDayDate)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Ge användaren en prognos, varför är det bra/inte bra att tvätta bilen idag?
    @IBAction func forecastButtonPressed(_ sender: Any) {
        giveForecastAlert()
    }
    
    // Välj att hämta väder för den stad man klickar på.
    @IBAction func chooseCitySement(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: logic.defaultsSelectedCity)
        let getIndex = citySegmentControl.selectedSegmentIndex
        switch (getIndex) {
        case 0:
           positionOrSearch = .position
           getWeather(positionOrSearch: .position)
        case 1:
            positionOrSearch = .search
            getWeather(positionOrSearch: .search)
        default:
            print("No segment selected.")
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
        logic.user.lastSearchedCity = cityName
        logic.defaults.set(logic.user.cityParams, forKey: logic.defaultsCityParams)
        logic.defaults.set(logic.user.lastSearchedCity, forKey: logic.defaultsUserLastSearchedCity)
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
            } else {
                let title = String("Connection Issues")
                let alert = self.logic.noWeatherDataAlert(title: title)
                self.present(alert, animated: true, completion: nil)
                print("Error \(response.result.error!))")
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
            retrievedDataButDidNotSucceed = false
            retrievedData = true
            weatherData.temperature = Int(tempResult - 272.15)
            weatherData.city = json["city"]["name"].stringValue
            weatherData.condition = json["list"][0]["weather"][0]["id"].intValue
            weatherData.weatherIconName = weatherData.updateWeatherIcon(condition: weatherData.condition)
            weatherData.weatherForTodayAndTomorrow.removeAll()
            for i in 0...15 {
                weatherData.weatherForTodayAndTomorrow.append(json["list"][i]["weather"][0]["main"].stringValue)
            }
            DispatchQueue.main.async {
                self.checkRain()
                self.temperatureLabel.text = "\(self.weatherData.temperature)°"
                self.weatherIcon.image = UIImage(named: self.weatherData.weatherIconName)
                if self.positionOrSearch == .position {
                    self.logic.user.lastPositionCity = self.weatherData.city
                    self.logic.defaults.set(self.logic.user.lastPositionCity, forKey: self.logic.defaultsUserLastPositionCity)
                }
            }
        } else {
            retrievedDataButDidNotSucceed = true
            temperatureLabel.text = String("\(json["message"])").capitalized
            weatherIcon.image = UIImage(named: "dont_know")
        }
    }
    
    // Hämtar användarens position om användaren godkänner "Location When In Use".
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            latitude = String(location.coordinate.latitude)
            longitude = String(location.coordinate.longitude)
            logic.user.positionParams = ["lat": latitude, "lon": longitude, "appid": logic.APP_ID]
            logic.defaults.set(logic.user.positionParams, forKey: logic.defaultsPositionParams)
            positionOrSearch = .position
            getWeather(positionOrSearch: .position)
        }
    }
    
    // Vid misslyckad hämtning av data, uppdatera titeln till "Location unavailable".
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let title = String("Plats ej tillgänglig")
        let alert = self.logic.noWeatherDataAlert(title: title)
        self.present(alert, animated: true, completion: nil)
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
    
    // Ge användaren en prognos.
    func giveForecastAlert() {
        logic.readUserDefaults()
        checkRain()
        let carName = logic.user.carObject.carDataDictionaryArray[logic.user.chosenCarIndex][logic.user.carObject.carName] as! String
        let carNotClean = logic.user.carObject.carDataDictionaryArray[logic.user.chosenCarIndex][logic.user.carObject.carIsNotCleanBool] as! Bool
        let alert = logic.alert.forecast(carName:"\(carName)", washToday: logic.washToday, longTimeSinceWashedCar: carNotClean, noRainTodayOrTomorrow: logic.noRainTodayAndTomorrow, searchingForGoodDate: logic.shouldAppSearchForGoodDate(), daysLeftToSearchingAgain: logic.user.howManyDaysToSearchingDate())
        self.present(alert, animated: true, completion: nil)
    }
    
    // Background fetch
    func notifyUser(washToday: Bool) {
        if washToday == true {
            print("Give user notification today!")
            let title = "Dags att tvätta bilen 🚗"
            let body = "Det var länge sedan du tvättade din bil och det ska vara bra väder i \(weatherData.city) både idag och imorgon ☀️"
            logic.sendNotification(title: title, body: body)
        } else {
            print("Don't give user notification today!")
        }
    }
    
    // Uppdaterar segmentcontrol.
    func didUpdateUserCities(positionCity: String, searchedCity: String) {
        citySegmentControl.setTitle("\(positionCity)", forSegmentAt: 0)
        citySegmentControl.setTitle("\(searchedCity)", forSegmentAt: 1)
        if searchedCity == "" {
            citySegmentControl.setTitle("Senaste sök", forSegmentAt: 1)
        }
        if searchedCity == "" && citySegmentControl.selectedSegmentIndex == 1 {
            temperatureLabel.text = "Du har inte gjort någon sökning hittils."
        }
        if positionCity == "" {
            citySegmentControl.setTitle("Position", forSegmentAt: 0)
        }
        if positionOrSearch == .position {
            citySegmentControl.selectedSegmentIndex = 0
        } else {
            citySegmentControl.selectedSegmentIndex = 1
        }
        let carNotClean = logic.user.carObject.carDataDictionaryArray[logic.user.chosenCarIndex][logic.user.carObject.carIsNotCleanBool] as! Bool
        let carName = logic.user.carObject.carDataDictionaryArray[logic.user.chosenCarIndex][logic.user.carObject.carName] as! String
        if carNotClean == true {
            washedCarButton.setTitle("Klicka på mig när \(carName) är tvättad", for: .normal)
            washedCarButton.isEnabled = true
            washedCarButton.alpha = 1.0
        } else {
            washedCarButton.setTitle("\(carName) är tvättad nyligen", for: .normal)
            washedCarButton.isEnabled = false
            washedCarButton.alpha = 0.5
        }
        if retrievedData == true && retrievedDataButDidNotSucceed == false {
            forecastButton.isEnabled = true
        } else {
            forecastButton.isEnabled = false
        }
    }
}

enum PositionOrSearch {
    case position
    case search
}
