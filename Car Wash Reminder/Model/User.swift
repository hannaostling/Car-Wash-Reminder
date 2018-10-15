//
//  User.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-10.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import Foundation

class User {
    
    var startSearchingDate = Date()
    var timeIntervalInWeeks: Int = 0
    var timeIntervalChoiseIsMade: Bool = false
    let car = Car()
    
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
    
    
}
