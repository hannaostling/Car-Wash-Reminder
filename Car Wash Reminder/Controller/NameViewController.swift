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
    
    let logic = StartViewController.logic
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let carIndex = logic.user.cars.count
        let carName = nameCarTextField.text!
        nameTheCar(carName: carName, carIndex: carIndex)
    }
    
    // Alert: fråga om användaren om
    func nameTheCar(carName: String, carIndex: Int) {
        var title = ""
        var message = ""
        if carName.count == 0 {
            title = "Inget namn?"
            let name = "Bilen"
            message = "Om du inte vill namnge din bil kommer vi kalla den för \"\(name)\", är det okej?"
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Avbryt", style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
                self.logic.user.cars.append(Car())
                self.performSegue(withIdentifier: "fromNameCarToTime", sender: self)
                self.logic.user.cars[carIndex].name = "\(name)"
            }))
            self.present(alert, animated: true, completion: nil)
        } else if carName.count > 0 && carName.count < 9 {
            logic.user.cars.append(Car())
            logic.user.cars[carIndex].name = "\(carName)"
            performSegue(withIdentifier: "fromNameCarToTime", sender: self)
        } else {
            title = "För långt namn"
            message = "Bilens namn måste bestå av max 8 bokstäver"
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        logic.defaults.set(logic.user.carObject.carDataDictionaryArray, forKey: logic.defaultsCarDataDictionaryArray)
        print("Antal bilar: \(logic.user.cars.count)")
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
