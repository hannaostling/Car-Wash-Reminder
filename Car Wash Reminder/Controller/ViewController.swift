//
//  ViewController.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-08.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
        
    var logic = Logic()
    
    @IBOutlet weak var thumb: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logic.checkIfUserShouldWashCar()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
    }

    // Test button.
    @IBAction func testButton(_ sender: Any) {
        if thumb.image == UIImage(named: "thumbs-up") {
            thumb.image = UIImage(named: "thumbs-down")
            logic.thumbsUp = false
        } else {
            thumb.image = UIImage(named: "thumbs-up")
            logic.thumbsUp = true
        }
    }
    
    // Send notification button.
    @IBAction func sendNotificationButtonPressed(_ sender: Any) {
        sendNotification(title: "Dags att tvätta bilen", subtitle: "Imorgon är det soligt...", body: "Passa på att tvätta bilen idag!")
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
    
}
