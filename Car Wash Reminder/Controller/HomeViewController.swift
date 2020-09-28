import UIKit
import UserNotifications
import CoreLocation
import Alamofire
import SwiftyJSON

class HomeViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, LogicDelegate {
    
    let logic = Logic.sharedInstance
    let locationManager = CLLocationManager()
    let weatherData = WeatherData()
    var latitude = ""
    var longitude = ""
    var retrievedData: Bool = true
    var retrievedDataButDidNotSucceed = false
    var fetchedDataTime = Date()
    var positionOrSearch = PositionOrSearch.position
    
    @IBOutlet weak var washedCarButton: UIButton!
    @IBOutlet weak var washStatusLabel: UILabel!
    
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
    
    // Gå till ChooseCarTableViewController
    @IBAction func changeCarButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "fromHomeToChooseCar", sender: self)
    }
    
    // När man klickar på "Nu är bilen tvättad" så markeras bilen som tvättad nyligen och appen tar en paus från att leta efter en bra dag att tvätta bilen med tidsintervallet som användaren har valt.
    @IBAction func washedCarButtonPressed(_ sender: Any) {
        var title = "Är du säker?"
        var message = ""
        let carTimeInterval = logic.getCarTimeInterval(withCarIndex: logic.user.chosenCarIndex)
        if carTimeInterval == 1 {
            message = "Appen kommer pausa letandet efter en bra dag att tvätta bilen i \(carTimeInterval) vecka om du trycker på \"Ja\"."
        } else {
            message = "Appen kommer pausa letandet efter en bra dag att tvätta bilen i \(carTimeInterval) veckor om du trycker på \"Ja\"."
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Nej", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ja", style: UIAlertAction.Style.default, handler: { action in
            let carIndex = self.logic.user.chosenCarIndex
            var cars = [Car]()
            for carDictionary in self.logic.user.carObject.carDataDictionaryArray {
                let car = Car(dataDictionary: carDictionary)
                cars.append(car)
            }
            cars.remove(at: carIndex)
            let carArray = self.logic.getCarArray()
            let car = carArray[carIndex]
            let startSearchDate = self.logic.user.carObject.startSearchingAgainAfter(timeInterval: carTimeInterval)
            car.startSearchingDate = startSearchDate
            car.isDirtyBool = false
            car.isDirtyDate = self.logic.getCarIsDirtyDate(withCarIndex: carIndex)
            car.washedDates = self.logic.getCarWashedDates(withCarIndex: carIndex)
            car.washedDates.append(Date())
            cars.append(car)
            var carsDataArray = [[String:Any]]()
            for car in cars {
                let carDictionaryFromObject = car.dataDictionaryFromObject()
                carsDataArray.append(carDictionaryFromObject)
            }
            self.logic.defaults.set(carsDataArray, forKey: self.logic.defaultsCarDataDictionaryArray)
            self.logic.user.chosenCarIndex = carsDataArray.count-1
            self.logic.defaults.set(self.logic.user.chosenCarIndex, forKey:self.logic.defaultsUserChosenCarIndex)
            self.didUpdateUI()
            title = "Kanon"
            let carName = self.logic.getCarName(withCarIndex: self.logic.user.chosenCarIndex)
            if carTimeInterval == 1 {
                message = "Om en vecka börjar appen leta efter ett nytt bra tillfälle att tvätta \(carName)!"
            } else {
                message = "Om \(carTimeInterval) veckor börjar appen leta efter ett nytt bra tillfälle att tvätta \(carName)!"
            }
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "👌🏽", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
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
                self.washStatusLabel.text = "Anslutningsproblem"
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
                if self.positionOrSearch == .position {
                    self.logic.user.lastPositionCity = self.weatherData.city
                    self.logic.defaults.set(self.logic.user.lastPositionCity, forKey: self.logic.defaultsUserLastPositionCity)
                    self.didUpdateUI()
                }
            }
        } else {
            retrievedDataButDidNotSucceed = true
            let errorMessage = String("\(json["message"])").capitalized
            if logic.user.lastSearchedCity != "" {
                washStatusLabel.text = errorMessage
            }
            print(errorMessage)
            didUpdateUI()
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
        washStatusLabel.text = String("Plats ej tillgänglig")
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
    
    // Uppdaterar UI
    func didUpdateUI() {
        logic.readUserDefaults()
        if !retrievedDataButDidNotSucceed {
            let carIsDirty = logic.getCarIsDirtyBool(withCarIndex: logic.user.chosenCarIndex)
            let carName = logic.getCarName(withCarIndex: logic.user.chosenCarIndex)
            let carStatus = logic.getStatus(withCarIndex: logic.user.chosenCarIndex)
            washStatusLabel.text = carStatus
            if carIsDirty == true {
                washedCarButton.setTitle("Klicka här när \(carName) är tvättad", for: .normal)
                washedCarButton.isEnabled = true
                washedCarButton.alpha = 1.0
            } else {
                washedCarButton.setTitle("\(carName) är tvättad nyligen", for: .normal)
                washedCarButton.isEnabled = false
                washedCarButton.alpha = 0.5
            }
        }
    }
    
    // Sätter den här viewControllerns delegat till samma som i ChooseCarTBC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromHomeToChooseCar" {
            let chooseCarTBC = segue.destination as! ChooseCarTableViewController
            chooseCarTBC.logicDelegate = self
        }
    }
}

enum PositionOrSearch {
    case position
    case search
}
