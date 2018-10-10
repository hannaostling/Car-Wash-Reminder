//
//  User.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-10.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import Foundation

class User {
    
    var timeIntervalInWeeks: Int
    let car = Car()
    
    init(timeIntervalInWeeks: Int) {
        self.timeIntervalInWeeks = timeIntervalInWeeks
    }
    
}
