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
    @IBOutlet weak var carWashedStatusSwitch: UISwitch!
    @IBOutlet weak var carWashedStatusLabel: UILabel!
    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var weeksPickerView: UIPickerView!
    @IBOutlet weak var selectedTimeIntervalLabel: UILabel!
    
    var logic = Logic()
    var timeIntervals = ["Varje vecka", "Varannan vecka"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //logic.checkIfUserShouldWashCar()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
        addTimeIntervals()
        weeksPickerView.dataSource = self
        weeksPickerView.delegate = self
    }

    // Test button.
    @IBAction func testButtonPressed(_ sender: Any) {
        if thumbImage.image == UIImage(named: "thumbs-up") {
            thumbImage.image = UIImage(named: "thumbs-down")
            logic.thumbsUp = false
        } else {
            thumbImage.image = UIImage(named: "thumbs-up")
            logic.thumbsUp = true
        }
    }
    
    
    // Send notification button.
    @IBAction func sendNotificationButtonPressed(_ sender: Any) {
        sendNotification(title: "Dags att tvätta bilen", subtitle: "Imorgon är det soligt...", body: "Passa på att tvätta bilen idag!")
    }
    
    //
    @IBAction func carWashedSwitch(_ sender: Any) {
        if carWashedStatusSwitch.isOn {
            UIApplication.shared.applicationIconBadgeNumber = 0
        } else {
        }
    }
    
    // Done button
    @IBAction func doneButton(_ sender: Any) {
        for i in 0...timeIntervals.count-1 {
            if selectedTimeIntervalLabel.text == timeIntervals[i] {
                let usersTimeIntervalInWeeks = i+1
                logic.user.timeIntervalInWeeks = usersTimeIntervalInWeeks
                print("Users time interval in weeks:",logic.user.timeIntervalInWeeks)
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
