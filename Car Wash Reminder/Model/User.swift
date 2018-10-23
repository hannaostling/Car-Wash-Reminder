//
//  User.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-10.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import Foundation
import UIKit

class User {

    var startSearchingDate = Date()
    var timeIntervalInWeeks: Int = 0
    var timeIntervalChoiseIsMade: Bool = false
    var hasOpenedAppBefore: Bool = false
    var lastSearchedCity: String = ""
    var lastPositionCity: String = ""
    var positionParams = ["":""]
    var cityParams = ["":""]
    var chosenCarIndex = 0
    var cars = [Car]()
    let carObject = Car()
    
    init() {
        setCars()
    }
    
    func setCars() {
        cars = carObject.giveCarArray(fromDictionaryArray: carObject.carDataDictionaryArray)
    }
    
    // Returnerar en sträng av startSearchingDate
    func dateWithFormatter() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let date = formatter.string(from: startSearchingDate)
        return date
    }
    
    // Returnerar ett heltal hur många dagar det är kvar tills appen börjar leta efter ett datum igen.
    func howManyDaysToSearchingDate() -> Int {
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: Date())
        let date2 = calendar.startOfDay(for: startSearchingDate)
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        let daysLeft = components.day!
        return daysLeft
    }
    
    // Börja söka igen efter användarens tidsinterval.
    func startSearchingAgainAfter(timeInterval: Int) {
        let daysToAdd = 7 * timeInterval
        let calendar = Calendar.current
        let currentDate = Date()
        startSearchingDate = calendar.date(byAdding: .day, value: daysToAdd, to: currentDate)!
        let carNotWashedRecently = daysToAdd - 6
        //let carArray = car.giveCarArray(fromDictionaryArray: car.carDataDictionaryArray)
        cars[chosenCarIndex].isNotCleanDate = calendar.date(byAdding: .day, value: carNotWashedRecently, to: currentDate)!
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let currentDateInString = formatter.string(from: Date())
        let carIsNotCleanDate = formatter.string(from: cars[chosenCarIndex].isNotCleanDate)
        let startSearchingDateInString = formatter.string(from: startSearchingDate)
        print("Dagens datum: \(currentDateInString)")
        print("Bilen räknas som smutsig igen: \(carIsNotCleanDate)")
        print("Appen börjar leta efter bra datum: \(startSearchingDateInString)")
    }
    
}
