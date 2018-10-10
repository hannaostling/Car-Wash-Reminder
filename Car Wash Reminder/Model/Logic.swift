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
    var thumbsUp: Bool = false
    let user = User(timeIntervalInWeeks: 0)
    
    // Funktionen innehåller en timer som anropar på "runsEverySecond()" varje sekund.
    func checkIfUserShouldWashCar() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runsEverySecond), userInfo: nil, repeats: true)
    }
    
    // Skriver ut om thumbsUp är sann eller falsk.
    @objc func runsEverySecond() {
        print("Thumbs up is: \(thumbsUp)")
    }
    
}
