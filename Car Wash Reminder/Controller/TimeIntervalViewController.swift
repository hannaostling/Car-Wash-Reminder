//
//  TimeIntervalViewController.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-17.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit
import UserNotifications

class TimeIntervalViewController: UIViewController {

    @IBOutlet weak var weeksPickerView: UIPickerView!
    
    let logic = Logic.sharedInstance
    var timeIntervals = ["Varje vecka", "Varannan vecka"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        logic.readUserDefaults()
        let carName = logic.user.carObject.carDataDictionaryArray[logic.user.chosenCarIndex][logic.user.carObject.carName] as! String
        title = "Välj tidsintervall för \(carName)"
        addTimeIntervals()
        weeksPickerView.dataSource = self
        weeksPickerView.delegate = self
    }
    
    // När använvaren väljer tidsintervall och klickar på "klar" så sparas tidsintervallet som ett heltal i logis.user.timeIntervalInWeeks.
    @IBAction func doneButtonPressed(_ sender: Any) {
        if logic.user.timeIntervalChoiseIsMade == false {
            logic.user.timeIntervalInWeeks = 1
        }
        logic.user.timeIntervalChoiseIsMade = true
        logic.defaults.set(logic.user.timeIntervalInWeeks, forKey:logic.defaultsUserTimeInterval)
        logic.defaults.set(logic.user.timeIntervalChoiseIsMade, forKey:logic.defaultsUserMadeChoice)
    }
    
    // Om användaren inte förstår vad det är för tidsintervall så kan man klicka på info för att få mer information.
    @IBAction func infoButtonPressed(_ sender: Any) {
        print("Info button pressed!")
        giveInformationAlert()
    }
    
    // Lägger till fler element i timeIntervals.
    func addTimeIntervals() {
        for i in 3...12 {
            let timeInterval = "Var \(i):e vecka"
            timeIntervals.append(timeInterval)
        }
    }
    
    // Alert med information till användaren.
    func giveInformationAlert() {
        let title = "Information"
        let message = "Appen söker efter en bra dag att tvätta din bil med bakgrundsdata och du får en notis när det är bra läge att tvätta bilen. \n \n När du sedan tvättat din bil kan du markera din bil som tvättad. Då kommer appen ta en paus från att söka efter en bra dag att tvätta bilen. \n \n Hur lång paus vill du att appen ska låta bli att leta efter en bra dag att tvätta bilen? Det tidsintervallet väljer du här."
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Okej", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

extension TimeIntervalViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeIntervals.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        logic.user.timeIntervalChoiseIsMade = true
        let selectedWeekInterval = row+1
        logic.user.timeIntervalInWeeks = selectedWeekInterval
        logic.defaults.set(logic.user.timeIntervalInWeeks, forKey:logic.defaultsUserTimeInterval)
        logic.defaults.set(logic.user.timeIntervalChoiseIsMade, forKey:logic.defaultsUserMadeChoice)
        print("Selected time interval: \(selectedWeekInterval)")
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeIntervals[row]
    }
    
}
