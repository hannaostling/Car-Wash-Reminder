//
//  Logic.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-08.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import Foundation
import UIKit

class Logic {
    
    var timer = Timer()
    let user = User()
    let defaults = UserDefaults.standard
    var noRainTodayAndTomorrow: Bool = false
    var searchForGoodDayToWashCar: Bool = false
    var washToday: Bool = false
    
    // User defaults nycklar.
    let defaultsUserTimeInterval = "defaultsUserTimeInterval"
    let defaultsUserMadeChoice = "defaultsUserMadeChoice"
    let defaultsUserCarIsWashedRecently = "defaultsUserCarIsWashedRecently"
    let defaultsSearchForGoodDayBool = "defaultsSearchForGoodDayBool"
    let defaultsSearchForGoodDayDate = "defaultsSearchForGoodDayDate"
    
    // Funktionen innehåller en timer som anropar på "runsEverySecond()" varje sekund.
    func checkIfUserShouldWashCar() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runsEverySecond), userInfo: nil, repeats: true)
    }
    
    // Skriver ut om thumbsUp är sann eller falsk.
    @objc func runsEverySecond() {
        if searchForGoodDayToWashCar == true && user.car.longTimeSinceUserWashedCar == true && noRainTodayAndTomorrow == true {
            washToday = true
            print("Notifikation")
        } else {
            washToday = false
        }
        if user.car.isNotWashedRecentlyDate == Date() {
            user.car.longTimeSinceUserWashedCar = true
        }
    }
    
}
