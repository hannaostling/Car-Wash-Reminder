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
        let carIsCleanDate = getCarIsDirtyDate(withCarIndex: user.chosenCarIndex)
        var carIsCleanBool = getCarIsDirtyBool(withCarIndex: user.chosenCarIndex)
        if carIsCleanDate == Date() {
            carIsCleanBool = true
        }
        let appIsSearching = shouldAppSearchForGoodDate()
        if carIsCleanBool == true && noRainTodayAndTomorrow == true && appIsSearching == true {
            washToday = true
        } else {
            washToday = false
        }
        logicDelegate?.didUpdateUserCities(positionCity: user.lastPositionCity, searchedCity: user.lastSearchedCity)
    }
    
    // Om användarens börja-söka-igen-datum är mindre än, eller lika med dagens datum, då blir shouldCheckForGoodDate = true.
    func shouldAppSearchForGoodDate () -> Bool {
        let searchDate = getCarSearchingDate(withCarIndex: user.chosenCarIndex)
        if searchDate <= Date() {
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
        
    // Läs user defaults.
    func readUserDefaults() {
        print("")
        print("• USER DEFAULTS ")
        if let savedUserOpenedAppBefore = defaults.bool(forKey: defaultsUserOpenedAppBefore) as Bool?  {
            user.hasOpenedAppBefore = savedUserOpenedAppBefore
            print("• User has opened app before: \(user.hasOpenedAppBefore)")
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
                    let carSearchingDate = getCarSearchingDate(withCarIndex: i)
                    let carSearchingDateAsString = getDateInString(date: carSearchingDate)
                    print("• Car \(i+1) name: \(carName)")
                    print("• Car \(i+1) is dirty: \(carIsDirty)")
                    print("• Car \(i+1) time interval: \(carTimeInterval)")
                    print("• Car \(i+1) search day begin: \(carSearchingDateAsString)")
                }
            }
        }
    }
    
    // Returnerar ett datum i en sträng med nice formatl
    func getDateInString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "sv")
        formatter.dateFormat = "d MMMM yyyy"
        let dateString = formatter.string(from: date)
        let dateCapitalized = dateString.capitalized
        return dateCapitalized
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
    
    // Returnera bilens (carIsDirtyDate) med ett visst index
    func getCarSearchingDate(withCarIndex: Int) -> Date {
        let carSearchingDate = user.carObject.carDataDictionaryArray[withCarIndex][user.carObject.carSearchingDate] as! Date
        return carSearchingDate
    }
    
    // Returnera bilens (carWashedDates) med ett visst index
    func getCarWashedDates(withCarIndex: Int) -> [Date] {
        let carWashedDates = user.carObject.carDataDictionaryArray[withCarIndex][user.carObject.carWashedDates] as! [Date]
        return carWashedDates
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
        let carIsDirtyBool = getCarIsDirtyBool(withCarIndex: withCarIndex)
        let shouldAppSearch = shouldAppSearchForGoodDate()
        var rainStatus = ""
        var carCleanSatus = ""
        var appIsSearching = ""
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
        let status = "\(rainStatus) \n \(carCleanSatus) \n \(appIsSearching)"
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
    func didUpdateUI()
}
