//
//  NameViewController.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-22.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit

class NameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameCarTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    let logic = Logic.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.hideKeyboardWhenTappedAround()
        nameCarTextField.delegate = self
        nextButton.isEnabled = false
        logic.askForNotificationPermission()
        logic.readUserDefaults()
    }
    
    // Next button
    @IBAction func nextButtonPressed(_ sender: Any) {
        next()
    }
    
    // När användaren börjar skriva, sätt knappen till enabled
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nextButton.isEnabled = true
        nextButton.alpha = 1.0
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameCarTextField.resignFirstResponder()
        next()
        return true
    }
    
    // Vad som ska häna när användaren klickar på nästa, ovsett om det är från return button i textfield eller om det är knappen "nextButton".
    func next() {
        logic.readUserDefaults()
        let carArray = logic.user.carObject.giveCarArray(fromDictionaryArray: logic.user.carObject.carDataDictionaryArray)
        let carIndex = carArray.count
        let carName = nameCarTextField.text!
        nameTheCar(carName: carName, carIndex: carIndex)
    }
    
    // Alert: fråga om användaren om
    func nameTheCar(carName: String, carIndex: Int) {
        var title = ""
        var message = ""
        if carName.count == 0 {
            title = "För kort namn"
            message = "Bilens namn måste bestå av minst 1 bokstav"
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if carName.count > 0 && carName.count < 9 {
            // Skapa array för test-objekt
            var cars = [Car]()
            for dataDictionary in logic.user.carObject.carDataDictionaryArray {
                let car = Car(dataDictionary: dataDictionary)
                cars.append(car)
            }
            // Skapa nytt car-objekt
            let car = Car()
            car.name = "\(carName)"
            car.isNotClean = true
            car.id = cars.count
            cars.append(car)
            // Sätt användarens chosenCarIndex till samma som nya bilens id
            logic.user.chosenCarIndex = car.id
            logic.defaults.set(self.logic.user.chosenCarIndex, forKey:self.logic.defaultsUserChosenCarIndex)
            // Skapa ny array med dictionaries för att hålla all data som skall sparas
            var carsDataArray = [[String:Any]]()
            for car in cars {
                let carDictionaryFromObject = car.dataDictionaryFromObject()
                carsDataArray.append(carDictionaryFromObject)
            }
            // Sparar carsDataArray med user defaults
            logic.defaults.set(carsDataArray, forKey: logic.defaultsCarDataDictionaryArray)
            performSegue(withIdentifier: "fromNameCarToTime", sender: self)
        } else {
            title = "För långt namn"
            message = "Bilens namn måste bestå av max 8 bokstäver"
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
