//
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
   
    var timer = Timer()
    let user = User()
    let defaults = UserDefaults.standard
    var noRainTodayAndTomorrow: Bool = false
    var searchForGoodDayToWashCar: Bool = false
    var washToday: Bool = false
    var logicDelegate: LogicDelegate?
    
    // User defaults nycklar.
    let defaultsUserCity = "defaultsUserCity"
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
        let shouldAppSearchForDate = shouldCheckForGoodDate()
        if searchForGoodDayToWashCar == true && user.car.longTimeSinceUserWashedCar == true && noRainTodayAndTomorrow == true && shouldAppSearchForDate == true {
            washToday = true
            let title = "Dags att tvätta bilen 🚗"
            let subtitle = "Passa på medan det är bra väder!"
            let body = "Det var länge sedan du tvättade din bil och det ska vara bra väder både idag och imorgon ☀️"
            sendNotification(title: title, subtitle: subtitle, body: body)
        } else {
            washToday = false
        }
        if user.car.isNotWashedRecentlyDate == Date() {
            user.car.longTimeSinceUserWashedCar = true
        }
        logicDelegate?.test(washToday: washToday)
    }
    
    // Om användarens börja-söka-igen-datum är mindre än, eller lika med dagens datum, då kan canAppCheckForGoodDate = true.
    func shouldCheckForGoodDate () -> Bool {
        if user.startSearchingDate <= Date() {
            return true
        } else {
            return false
        }
    }
    
    // Notification settings
    func sendNotification(title: String, subtitle: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
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
}

protocol LogicDelegate {
    func test(washToday: Bool)
}
