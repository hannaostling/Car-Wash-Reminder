//
//  StartViewController.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-17.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    static let logic = Logic()
    let logic = StartViewController.logic

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        performSegueBasedOnUserStatus()
    }

    // Kollar om användaren har öppnat appen tidigare samt om användaren gjort ett tidsintervall eller inte.
    func performSegueBasedOnUserStatus() {
        logic.readUserDefaults()
        let amountOfCars = logic.user.carObject.carDataDictionaryArray.count
        if logic.user.hasOpenedAppBefore == false && logic.user.timeIntervalChoiseIsMade == false {
            performSegue(withIdentifier: "fromStartToFirst", sender: self)
        } else if amountOfCars == 0 && logic.user.hasOpenedAppBefore == true {
            performSegue(withIdentifier: "fromStartToNameCar", sender: self)
        } else if logic.user.hasOpenedAppBefore == true && logic.user.timeIntervalChoiseIsMade == false && amountOfCars > 0 {
            performSegue(withIdentifier: "fromStartToTime", sender: self)
        } else {
            performSegue(withIdentifier: "fromStartToHome", sender: self)
        }
    }

}
