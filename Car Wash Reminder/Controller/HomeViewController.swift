//
//  HomeViewController.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-09.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit
import UserNotifications

class HomeViewController: UIViewController {
    
    @IBOutlet weak var timeIntervalView: UIView!
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var goodDayToWashCarSwitch: UISwitch!
    @IBOutlet weak var carIsWashedSwitch: UISwitch!
    @IBOutlet weak var carWashedStatusLabel: UILabel!
    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var weeksPickerView: UIPickerView!
    @IBOutlet weak var selectedTimeIntervalLabel: UILabel!
    
    var logic = Logic()
    var timeIntervals = ["Varje vecka", "Varannan vecka"]
    
    // if (Kolla varje dag om lastWashedDate + tidsintervall > dagens datum) == true { notifikation }
    // backgroundDataFetch 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logic.checkIfUserShouldWashCar()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
        addTimeIntervals()
        weeksPickerView.dataSource = self
        weeksPickerView.delegate = self
        checkUserTimeInterval()
        checkCarWashedStatus()
    }

    // Send notification button.
    @IBAction func sendNotificationButtonPressed(_ sender: Any) {
        sendNotification(title: "Dags att tvätta bilen", subtitle: "Imorgon är det soligt...", body: "Passa på att tvätta bilen idag!")
    }
    
    // Sätt logig.thumbsUp till falsk om den är sann och till sann om den är falsk.
    @IBAction func goodDayToWashTest(_ sender: Any) {
        if logic.user.car.goodDayToWash == true {
            logic.user.car.goodDayToWash = false
        } else {
            logic.user.car.goodDayToWash = true
        }
        checkCarWashedStatus()
    }
    
    // Användaren drar switchen till on om bilen är tvättad
    @IBAction func carIsWashed(_ sender: Any) {
        // EJ KLAR
        if logic.user.car.isWashed == true {
            carIsWashedSwitch.isOn = false
            logic.user.car.isWashed = false
            UIApplication.shared.applicationIconBadgeNumber = 1
        } else {
            carIsWashedSwitch.isOn = true
            logic.user.car.isWashed = true
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        print("Bil är tvättad: \(logic.user.car.isWashed)")
    }
    
    // När använvaren väljer tidsintervall och klickar på "klar" så sparas tidsintervallet som ett heltal i logis.user.timeIntervalInWeeks.
    @IBAction func doneButton(_ sender: Any) {
        for i in 0...timeIntervals.count-1 {
            if selectedTimeIntervalLabel.text == timeIntervals[i] {
                let usersTimeIntervalInWeeks = i+1
                logic.user.timeIntervalInWeeks = usersTimeIntervalInWeeks
                print("Users time interval in weeks:",logic.user.timeIntervalInWeeks)
                logic.defaults.set(logic.user.timeIntervalInWeeks, forKey:logic.defaultsUserTimeInterval)
                timeIntervalView.isHidden = true
                homeView.isHidden = false
            }
        }
    }
    
    // Notification settings
    func sendNotification(title: String, subtitle: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.badge = 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "threeSeconds", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    // Lägger till fler element i timeIntervals
    func addTimeIntervals() {
        for i in 3...12 {
            let timeInterval = "Var \(i):e vecka"
            timeIntervals.append(timeInterval)
        }
    }
    
    // Kollar om användaren har valt ett tidsintervall.
    func checkUserTimeInterval() {
        if let savedUserTimeInterval = logic.defaults.integer(forKey: logic.defaultsUserTimeInterval) as Int? {
            logic.user.timeIntervalInWeeks = savedUserTimeInterval
        }
        if logic.user.timeIntervalInWeeks == 0 {
            timeIntervalView.isHidden = false
            homeView.isHidden = true
        } else {
            timeIntervalView.isHidden = true
            homeView.isHidden = false
        }
    }
    
    // Kollar status på logic.thumbsUp (gör till enum senare) och sätter bild samt switch.
    func checkCarWashedStatus() {
        if logic.user.car.goodDayToWash == true {
            goodDayToWashCarSwitch.isOn = true
            thumbImage.image = UIImage(named: "thumbs-up")
        } else {
            goodDayToWashCarSwitch.isOn = false
            thumbImage.image = UIImage(named: "thumbs-down")
        }
    }
    
}

extension HomeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeIntervals.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTimeIntervalLabel.text = timeIntervals[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeIntervals[row]
    }
}
