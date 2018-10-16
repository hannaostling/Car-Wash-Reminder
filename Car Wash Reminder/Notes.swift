//
//  Notes.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-16.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import Foundation
//import Alamofire
//import SwiftyJSON
//Alamofire.request(url, method: .get, parameters: cityParams).responseJSON {
//    response in
//    if response.result.isSuccess {
//        let json: JSON = JSON(response.result.value!)
//        //if let tempResult = json["list"][0]["main"]["temp"].double {
//        //weatherData.temperature = Int(tempResult - 272.15)
//        weatherData.city = json["city"]["name"].stringValue
//        weatherData.condition = json["list"][0]["weather"][0]["id"].intValue
//        weatherData.weatherIconName = weatherData.updateWeatherIcon(condition: weatherData.condition)
//        weatherData.weatherForTodayAndTomorrow.removeAll()
//        for i in 0...15 {
//            weatherData.weatherForTodayAndTomorrow.append(json["list"][i]["weather"][0]["main"].stringValue)
//        }
//        print(weatherData.city)
//        completionHandler(.newData)
//
//
//
//        //homeVC.notifyUser(washToday: homeVC.logic.washToday)
//        print("Sucseeded")
//        var countBadWeather = 0
//        for weather in weatherData.weatherForTodayAndTomorrow {
//            if weather == "Rain" || weather == "Thunderstorm" || weather == "Snow" {
//                countBadWeather += 1
//                print("☔️ \(weather)")
//            } else {
//                print("🌞 \(weather)")
//            }
//        }
//        if countBadWeather <= 0 {
//            homeVC.logic.noRainTodayAndTomorrow = true
//        } else {
//            homeVC.logic.noRainTodayAndTomorrow = false
//        }
//        //                        updateUI()
//        //                    } else {
//        //                        completionHandler(.failed)
//        //                        print("Failed")
//        //                    }
//
//        DispatchQueue.main.async {
//            homeVC.notifyUser(washToday: homeVC.logic.washToday)
//        }
//    } else {
//        print("Error \(response.result.error!))")
//        completionHandler(.failed)
//    }
//}
