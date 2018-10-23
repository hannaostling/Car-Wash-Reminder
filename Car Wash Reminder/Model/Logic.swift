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
   
    let user = User()
    let alert = Alert()
    let defaults = UserDefaults.standard
    let FORECAST_URL = "http://api.openweathermap.org/data/2.5/forecast?"
    let APP_ID = "8d3cdc147cc33854e24e8e8c15f128cb"
    var noRainTodayAndTomorrow: Bool = false
    var searchForGoodDayToWashCar: Bool = false
    var washToday: Bool = false
    var logicDelegate: LogicDelegate?
    var timer = Timer()
    
    // User defaults nycklar.
    let defaultsUserLastSearchedCity = "defaultsUserLastSearchedCity"
    let defaultsUserLastPositionCity = "letdefaultsUserLastPositionCity"
    let defaultsUserTimeInterval = "defaultsUserTimeInterval"
    let defaultsUserMadeChoice = "defaultsUserMadeChoice"
    let defaultsSearchForGoodDayBool = "defaultsSearchForGoodDayBool"
    let defaultsSearchForGoodDayDate = "defaultsSearchForGoodDayDate"
    let defaultsCityParams = "defaultsCityParams"
    let defaultsPositionParams = "defaultsPositionParams"
    let defaultsUserOpenedAppBefore = "defaultsUserOpenedAppBefore"
    let defaultsSelectedCity = "defaultsSelectedCity"
    let defaultsCarDataDictionaryArray = "defaultsCarDataDictionaryArray"
    
    // Funktionen innehåller en timer som anropar på "runsEverySecond()" varje sekund.
    func checkIfUserShouldWashCar() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runsEverySecond), userInfo: nil, repeats: true)
    }
    
    // Kollar om det är bra dag att tvätta bilen eller inte.
    @objc func runsEverySecond() {
        let shouldAppSearchForDate = shouldCheckForGoodDate()
        if searchForGoodDayToWashCar == true && user.cars[user.chosenCarIndex].isNotClean == true && noRainTodayAndTomorrow == true && shouldAppSearchForDate == true {
            washToday = true
        } else {
            washToday = false
        }
        if user.cars[user.chosenCarIndex].isNotCleanDate == Date() {
            user.cars[user.chosenCarIndex].isNotClean = true
        }
        logicDelegate?.notifyUser(washToday: washToday)
        logicDelegate?.didUpdateUserCities(positionCity: user.lastPositionCity, searchedCity: user.lastSearchedCity)
    }
    
    // Om användarens börja-söka-igen-datum är mindre än, eller lika med dagens datum, då kan canAppCheckForGoodDate = true.
    func shouldCheckForGoodDate () -> Bool {
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
        if let searchForGoodDay = defaults.bool(forKey: defaultsSearchForGoodDayBool) as Bool? {
            searchForGoodDayToWashCar = searchForGoodDay
            print("• Searching for good day to wash car: \(searchForGoodDayToWashCar)")
        }
        if let noChoise = defaults.bool(forKey: defaultsUserMadeChoice) as Bool? {
            user.timeIntervalChoiseIsMade = noChoise
            print("• User has made a timeinterval choise: \(user.timeIntervalChoiseIsMade)")
        }
        if let savedUserTimeIntervalInWeeks = defaults.integer(forKey: defaultsUserTimeInterval) as Int? {
            user.timeIntervalInWeeks = savedUserTimeIntervalInWeeks
            print("• User timeinterval in weeks: \(user.timeIntervalInWeeks)")
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
        if let savedCarDataDictionaryArray = defaults.array(forKey: defaultsCarDataDictionaryArray) as! [[String:Any]]? {
            user.carObject.carDataDictionaryArray = savedCarDataDictionaryArray
            print("• User amount of cars: \(user.cars.count)")
            if user.cars.count > 0 {
                for car in user.cars {
                    print("• Car \(user.cars.count) name: \(car.name)")
                    print("• Car \(user.cars.count) is not clean: \(car.isNotClean)")
                }
            }
        }
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

