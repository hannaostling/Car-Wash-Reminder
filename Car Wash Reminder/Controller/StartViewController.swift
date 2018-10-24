//
//  StartViewController.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-17.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    let logic = Logic.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        logic.readUserDefaults()
        performSegueBasedOnUserStatus()
    }

    func performSegueBasedOnUserStatus() {
        let userStatus = logic.user.checkUserStatus()
        switch userStatus {
        case .firstTime:
            performSegue(withIdentifier: "fromStartToFirst", sender: self)
        case .nameFirstCar:
            performSegue(withIdentifier: "fromStartToNewCar", sender: self)
        case .setTimeIntervalForFirstCar:
            performSegue(withIdentifier: "fromStartToTime", sender: self)
        case .userHasAtLeastOneCar:
            performSegue(withIdentifier: "fromStartToHome", sender: self)
        }
    }
}
