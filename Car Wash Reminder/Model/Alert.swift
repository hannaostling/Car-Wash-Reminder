//
//  Alert.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-19.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import Foundation
import UIKit

class Alert {
    
    func forecast(carName: String, washToday: Bool, longTimeSinceWashedCar: Bool, noRainTodayOrTomorrow: Bool, searchingForGoodDate: Bool, daysLeftToSearchingAgain: Int) -> UIAlertController {
        var title = ""
        var line1 = ""
        var line2 = ""
        var line3 = ""
        var message = ""
        if washToday == true {
            title = "Tvätta \"\(carName)\" idag 👍🏽"
        } else {
            title = "Tvätta inte \"\(carName)\" idag 👎🏽"
        }
        let longTimeSinceUserWashedCar = boolMessageEmoji(bool: longTimeSinceWashedCar)
        let noRainTodayAndTomorrow = boolMessageEmoji(bool: noRainTodayOrTomorrow)
        let searchForGoodDayToWashCar = boolMessageEmoji(bool: searchingForGoodDate)
        if noRainTodayOrTomorrow == true {
            line1 = "\(noRainTodayAndTomorrow) Bra väder både idag och imorgon\n"
        } else {
            line1 = "\(noRainTodayAndTomorrow) Dåligt väder idag eller imorgon\n"
        }
        if longTimeSinceWashedCar == true {
            line2 = "\(longTimeSinceUserWashedCar) Bilen är inte tvättad nyligen\n"
        } else {
            line2 =  "\(longTimeSinceUserWashedCar) Bilen är tvättad nyligen\n"
        }
        if searchingForGoodDate == true {
            line3 = "\(searchForGoodDayToWashCar) Appen söker just nu efter en bra dag att tvätta bilen"
        } else {
            line3 = "\(searchForGoodDayToWashCar) Det är \(daysLeftToSearchingAgain) dagar kvar tills appen börjar söka efter en bra dag att tvätta bilen"
        }
        message = line1+line2+line3
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Okej", style: UIAlertAction.Style.default, handler: nil))
        return alert
    }
    
    // Ge ja/nej meddelande från bool.
    func boolMessageEmoji(bool: Bool) -> String {
        if bool == true {
            return "✅"
        } else {
            return "❌"
        }
    }
    
}
