//
//  ChangeCityViewController.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-10.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit

protocol ChangeCityDelegate {
    func userEnteredANewCityName(city : String)
}

class ChangeCityViewController: UIViewController {
    
    var delegate : ChangeCityDelegate?
    
    @IBOutlet weak var changeCityTextField: UITextField!
    
    // Dölj status bar.
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Get weather button: Efter användaren skrivit in en stad och klickat på knappen så anropar vi på delegaten userEnteredANewCityName med changeCityTextField.text och går sedan tillbaka till WeatherViewController.
    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        let cityName = changeCityTextField.text!
        delegate?.userEnteredANewCityName(city: cityName)
        self.navigationController?.popViewController(animated: true)
    }
    
}
