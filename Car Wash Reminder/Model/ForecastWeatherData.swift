//
//  ForecastWeatherData.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-11.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import Foundation

class ForecastWeatherData {
    
    var city: String = ""
    var temperature: Int = 0
    var condition: Int = 0
    var weatherIconName: String = ""
    var weatherForTodayAndTomorrow: [String] = []
    
    func updateWeatherIcon(condition: Int) -> String {
        switch (condition) {
        case 0...300 :
            return "storm1"
        case 301...500 :
            return "light_rain"
        case 501...600 :
            return "much_rain"
        case 601...700 :
            return "snow1"
        case 701...771 :
            return "fog"
        case 772...799 :
            return "storm2"
        case 800 :
            return "sunny"
        case 801...804 :
            return "cloudy"
        case 900...903, 905...1000  :
            return "storm2"
        case 903 :
            return "snow2"
        case 904 :
            return "sunny"
        default :
            return "dont_know"
        }
    }

}
