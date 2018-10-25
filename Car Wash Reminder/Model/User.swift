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

    var hasOpenedAppBefore: Bool = false
    var lastSearchedCity: String = ""
    var lastPositionCity: String = ""
    var positionParams = ["":""]
    var cityParams = ["":""]
    var chosenCarIndex = 0
    let carObject = Car()
    
    func checkUserStatus() -> UserStatus {
        let amountOfCars = carObject.carDataDictionaryArray.count
        if amountOfCars == 0 {
            if hasOpenedAppBefore == false {
                return .firstTime
            } else {
                return .nameFirstCar
            }
        } else {
            let carDictionaryArray = carObject.carDataDictionaryArray
            var cars = [Car]()
            for dictionary in carDictionaryArray {
                let car = Car(dataDictionary: dictionary)
                cars.append(car)
            }
            let lastIndex = cars.count-1
            let lastCarInCarArrayTimeInterval = carObject.carDataDictionaryArray[lastIndex][carObject.carTimeInterval] as! Int
            if lastCarInCarArrayTimeInterval == 0 {
                return .setTimeIntervalForFirstCar
            } else {
                return .userHasAtLeastOneCar
            }
        }
    }
    
}

enum UserStatus {
    case firstTime
    case nameFirstCar
    case setTimeIntervalForFirstCar
    case userHasAtLeastOneCar
}
