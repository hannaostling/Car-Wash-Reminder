//
//  Car.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-10.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import Foundation

class Car {

    var id: Int = 0
    var name: String = "Bilen"
    var isNotClean: Bool = true
    var isNotCleanDate = Date()
    var washedDates: [Date] = []
    var carDataDictionaryArray = [[String:Any]]()
    
    // Dictionary nycklar
    let carName = "carName"
    let carIsNotCleanBool = "carIsNotCleanBool"
    let carIsNotCleanDate = "carIsNotCleanDate"
    let carWashedDates = "carWashedDates"
    
    init() {}
    
    init(dataDictionary:[String:Any]) {
        name = dataDictionary[carName] as! String
        isNotClean = dataDictionary[carIsNotCleanBool] as! Bool
        isNotCleanDate = dataDictionary[carIsNotCleanDate] as! Date
        washedDates = dataDictionary[carWashedDates] as! [Date]
    }
    
    func dataDictionaryFromObject() -> [String:Any] {
        var dictionary = [String:Any]()
        dictionary[carName] = name
        dictionary[carIsNotCleanBool] = isNotClean
        dictionary[carIsNotCleanDate] = isNotCleanDate
        dictionary[carWashedDates] = washedDates
        return dictionary
    }
    
    // Returnerar carArray av dictionaryArray
    func giveCarArray(fromDictionaryArray: [[String:Any]]) -> [Car] {
        var dataArray = [Car]()
        for dictionary in fromDictionaryArray {
            let test = Car(dataDictionary: dictionary)
            dataArray.append(test)
        }
        return dataArray
    }
    
    // Returnerar isNotClean bool av carArray
    func giveCarIsNotCleanBool(carArray: [Car], carIndex: Int) -> Bool {
        return carArray[carIndex].isNotClean
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
