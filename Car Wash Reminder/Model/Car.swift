//
//  Car.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-10.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import Foundation

class Car {

    var name: String = "Bilen"
    var isDirty: Bool = true
    var isDirtyDate = Date()
    var washedDates: [Date] = []
    var timeIntervalInWeeks: Int = 0
    var carDataDictionaryArray = [[String:Any]]()
    
    // Dictionary nycklar
    let carName = "carName"
    let carIsDirtyBool = "carIsDirtyBool"
    let carIsDirtyDate = "carIsDirtyDate"
    let carWashedDates = "carWashedDates"
    let carTimeInterval = "carTimeInterval"
    
    init() {}
    
    init(dataDictionary:[String:Any]) {
        name = dataDictionary[carName] as! String
        isDirty = dataDictionary[carIsDirtyBool] as! Bool
        isDirtyDate = dataDictionary[carIsDirtyDate] as! Date
        washedDates = dataDictionary[carWashedDates] as! [Date]
        timeIntervalInWeeks = dataDictionary[carTimeInterval] as! Int
    }
    
    func dataDictionaryFromObject() -> [String:Any] {
        var dictionary = [String:Any]()
        dictionary[carName] = name
        dictionary[carIsDirtyBool] = isDirty
        dictionary[carIsDirtyDate] = isDirtyDate
        dictionary[carWashedDates] = washedDates
        dictionary[carTimeInterval] = timeIntervalInWeeks
        return dictionary
    }
    
    // Returnerar ett heltal hur många dagar har det gått sen ett inskickat datum.
    func howManyDaysAgo(date: Date) -> Int {
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: date)
        let date2 = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        let daysLeft = components.day!
        return daysLeft
    }

}
