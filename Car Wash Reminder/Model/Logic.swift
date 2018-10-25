//  Logic.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-08.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UserNotifications
import Foundation
import UIKit

class Logic {
   
    static let sharedInstance = Logic()
    
    let user = User()
    let defaults = UserDefaults.standard
    let FORECAST_URL = "http://api.openweathermap.org/data/2.5/forecast?"
    let APP_ID = "8d3cdc147cc33854e24e8e8c15f128cb"
    var noRainTodayAndTomorrow: Bool = false
    var washToday: Bool = false
    var logicDelegate: LogicDelegate?
    var timer = Timer()
    
    // User defaults nycklar.
    let defaultsUserLastSearchedCity = "defaultsUserLastSearchedCity"
    let defaultsUserLastPositionCity = "letdefaultsUserLastPositionCity"
    //let defaultsUserTimeInterval = "defaultsUserTimeInterval"
    //let defaultsUserMadeChoice = "defaultsUserMadeChoice"
    let defaultsSearchForGoodDayDate = "defaultsSearchForGoodDayDate"
    let defaultsCityParams = "defaultsCityParams"
    let defaultsPositionParams = "defaultsPositionParams"
    let defaultsUserOpenedAppBefore = "defaultsUserOpenedAppBefore"
    let defaultsSelectedCity = "defaultsSelectedCity"
    let defaultsCarDataDictionaryArray = "defaultsCarDataDictionaryArray"
    let defaultsUserChosenCarIndex = "defaultsUserChosenCarIndex"
    
    // Funktionen innehåller en timer som anropar på "runsEverySecond()" varje sekund.
    func checkIfUserShouldWashCar() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runsEverySecond), userInfo: nil, repeats: true)
    }
    
    // Kollar om det är bra dag att tvätta bilen eller inte.
    @objc func runsEverySecond() {
        let appIsSearching = shouldAppSearchForGoodDate()
        let carIsCleanDate = getCarIsDirtyDate(withCarIndex: user.chosenCarIndex)
        var carIsCleanBool = getCarIsDirtyBool(withCarIndex: user.chosenCarIndex)
        if carIsCleanBool == true && noRainTodayAndTomorrow == true && appIsSearching == true {
            washToday = true
        } else {
            washToday = false
        }
        if carIsCleanDate == Date() {
            carIsCleanBool = true
        }
        logicDelegate?.didUpdateUserCities(positionCity: user.lastPositionCity, searchedCity: user.lastSearchedCity)
    }
    
    // Om användarens börja-söka-igen-datum är mindre än, eller lika med dagens datum, då blir shouldCheckForGoodDate = true.
    func shouldAppSearchForGoodDate () -> Bool {
        if user.startSearchingDate <= Date() {
            return true
        } else {
            return false
        }
    }
    
    // Konfiguera notifikationen.
    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.badge = 0
        content.sound = UNNotificationSound.default
        var dateComponents = DateComponents()
        dateComponents.hour = 17
        dateComponents.minute = 00
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "17:00", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    // Ge användaren alert om det inte går att hämta väderdata.
    func noWeatherDataAlert(title: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: "Försök igen senare", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Okej", style: UIAlertAction.Style.default, handler: nil))
        return alert
    }
    
    // Läs user defaults.
    func readUserDefaults() {
        print("")
        print("• USER DEFAULTS ")
        if let savedUserOpenedAppBefore = defaults.bool(forKey: defaultsUserOpenedAppBefore) as Bool?  {
            user.hasOpenedAppBefore = savedUserOpenedAppBefore
            print("• User has opened app before: \(user.hasOpenedAppBefore)")
        }
        if let savedUserSearchAgainDate = defaults.object(forKey: defaultsSearchForGoodDayDate) {
            user.startSearchingDate = savedUserSearchAgainDate as! Date
            print("• App start searching: \(user.startSearchingDate)")
        }
        if let savedUserLastSearchedCity = defaults.string(forKey: defaultsUserLastSearchedCity) as String? {
            user.lastSearchedCity = savedUserLastSearchedCity
            print("• User last searched city: \(user.lastSearchedCity)")
        }
        if let savedUserPositionCity = defaults.string(forKey: defaultsUserLastPositionCity) as String? {
            user.lastPositionCity = savedUserPositionCity
            print("• User last position city: \(user.lastPositionCity)")
        }
        if let savedUserCityParams = defaults.dictionary(forKey: defaultsCityParams) as! [String:String]? {
            user.cityParams = savedUserCityParams
        }
        if let savedUserPositionParams = defaults.dictionary(forKey: defaultsPositionParams) as! [String:String]? {
            user.positionParams = savedUserPositionParams
        }
        if let savedUserChosenCarIndex = defaults.integer(forKey: defaultsUserChosenCarIndex) as Int? {
            user.chosenCarIndex = savedUserChosenCarIndex
            print("• User chosen car index \(user.chosenCarIndex)")
        }
        if let savedCarDataDictionaryArray = defaults.array(forKey: defaultsCarDataDictionaryArray) as! [[String:Any]]? {
            user.carObject.carDataDictionaryArray = savedCarDataDictionaryArray
            print("• User amount of cars: \(user.carObject.carDataDictionaryArray.count)")
            let carArray = getCarArray()
            if carArray.count != 0 {
                for i in 0...user.carObject.carDataDictionaryArray.count-1 {
                    let carName = getCarName(withCarIndex: i)
                    let carIsDirty = getCarIsDirtyBool(withCarIndex: i)
                    let carTimeInterval = getCarTimeInterval(withCarIndex: i)
                    print("• Car \(i+1) name: \(carName)")
                    print("• Car \(i+1) is dirty: \(carIsDirty)")
                    print("• Car \(i+1) time interval: \(carTimeInterval)")
                }
            }
        }
    }
    
    // Returnera bilens (carName) med ett visst index
    func getCarName(withCarIndex: Int) -> String {
        let carName = user.carObject.carDataDictionaryArray[withCarIndex][user.carObject.carName] as! String
        return carName
    }
    
    // Returnera bilens (carIsDirtyBool) med ett visst index
    func getCarIsDirtyBool(withCarIndex: Int) -> Bool {
        let carIsDirtyBool = user.carObject.carDataDictionaryArray[withCarIndex][user.carObject.carIsDirtyBool] as! Bool
        return carIsDirtyBool
    }
    
    // Returnera bilens (carIsDirtyDate) med ett visst index
    func getCarIsDirtyDate(withCarIndex: Int) -> Date {
        let carIsDirtynDate = user.carObject.carDataDictionaryArray[withCarIndex][user.carObject.carIsDirtyDate] as! Date
        return carIsDirtynDate
    }
    
    // Returnera bilens (carTimeInterval) med ett visst index
    func getCarTimeInterval(withCarIndex: Int) -> Int {
        let carTimeInterval = user.carObject.carDataDictionaryArray[withCarIndex][user.carObject.carTimeInterval] as! Int
        return carTimeInterval
    }
    
    // Returnera en array av alla bilar
    func getCarArray() -> [Car] {
        let dictionaryArray = user.carObject.carDataDictionaryArray
        var dataArray = [Car]()
        for dictionary in dictionaryArray {
            let car = Car(dataDictionary: dictionary)
            dataArray.append(car)
        }
        return dataArray
    }
    
    func getStatus(withCarIndex: Int) -> String {
        readUserDefaults()
        let carName = getCarName(withCarIndex: withCarIndex)
        let carIsDirtyBool = getCarIsDirtyBool(withCarIndex: withCarIndex)
        let startSearchingDate = user.howManyDaysToSearchingDate()
        let shouldAppSearch = shouldAppSearchForGoodDate()
        var washTodayStatus = ""
        var rainStatus = ""
        var carCleanSatus = ""
        var appIsSearching = ""
        if washToday == true {
            washTodayStatus = "Tvätta \"\(carName)\" idag 👍🏽"
        } else {
            washTodayStatus = "Tvätta inte \"\(carName)\" idag 👎🏽"
        }
        if noRainTodayAndTomorrow == true {
            rainStatus = "✓ Bra väder"
        } else {
            rainStatus = "✕ Dåligt väder"
        }
        if carIsDirtyBool == true {
            carCleanSatus = "✓ Bilen är smutsig"
        } else {
            carCleanSatus = "✕ Bilen är tvättad nyligen"
        }
        if shouldAppSearch == true {
            appIsSearching = "✓ Sökning är aktiv"
        } else {
            appIsSearching = "✕ Sökning är inte aktiv"
        }
        let status = "Status: \n \(washTodayStatus) \n \(rainStatus) \n \(carCleanSatus) \n \(appIsSearching)"
        return status
    }
    
    // Fråga användaren efter tillstånd att få skicka notiser.
    func askForNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
    }
    
}

protocol LogicDelegate {
    func notifyUser(washToday: Bool)
    func didUpdateUserCities(positionCity: String, searchedCity: String)
}
