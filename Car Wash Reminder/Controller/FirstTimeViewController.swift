//
//  FirstTimeViewController.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-17.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit

class FirstTimeViewController: UIViewController {
    
    @IBOutlet weak var messageTextView: UITextView!
    
    let logic = StartViewController.logic
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        logic.readUserDefaults()
        setTextMessade()
    }
    
    // Sätter texten.
    func setTextMessade() {
        messageTextView.text = "Hej"
    }
    
    // När användaren klickar på "Okej" så sätts logic.user.hasOpenedAppBefore till sant.
    @IBAction func okButtonPressed(_ sender: Any) {
        logic.user.hasOpenedAppBefore = true
        logic.defaults.set(logic.user.hasOpenedAppBefore, forKey:logic.defaultsUserOpenedAppBefore)
    }
    

}
