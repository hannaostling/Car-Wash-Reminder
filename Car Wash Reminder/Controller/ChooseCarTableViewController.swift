//
//  ChooseCarTableViewController.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-23.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit

class ChooseCarTableViewController: UITableViewController {
    
    let logic = Logic.sharedInstance
    var logicDelegate: LogicDelegate? = nil
    var dates = [Date]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logic.readUserDefaults()
        dates = logic.user.carObject.carDataDictionaryArray[logic.user.chosenCarIndex][logic.user.carObject.carWashedDates] as! [Date]
        tableView.reloadData()
    }
    
    // Antal rader.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Antal kolumner.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let amountOfRows = logic.user.carObject.carDataDictionaryArray.count
        return amountOfRows
    }
    
    // Konfiguera call.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let carArray = logic.getCarArray()
        let car = carArray[indexPath.row]
        let carCell = tableView.dequeueReusableCell(withIdentifier: "car", for: indexPath) as! ChooseCarTableViewCell
        carCell.setCar(car: car)
        if indexPath.row == logic.user.chosenCarIndex {
            carCell.accessoryType = .checkmark
        } else {
            carCell.accessoryType = .none
        }
        return carCell
    }
    
    // När man klickar på en rad.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        logic.user.chosenCarIndex = indexPath.row
        logic.defaults.set(self.logic.user.chosenCarIndex, forKey:self.logic.defaultsUserChosenCarIndex)
        tableView.reloadData()
        if logicDelegate != nil {
            logicDelegate?.didUpdateUI()
        }
    }
    
    // Ta bort en bil med swipe.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let amountOfCars = logic.getCarArray().count
            let carName = logic.getCarName(withCarIndex: indexPath.row)
            if indexPath.row == logic.user.chosenCarIndex && amountOfCars == 1 {
                let title = "Du måste ha minst en bil"
                let message = "Skapa en ny bil innan du tar bort \(carName)"
                let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if indexPath.row == logic.user.chosenCarIndex && amountOfCars != 1 {
                let title = "Du kan inte ta bort en bil som är markerad"
                let message = "Den bilen som är markerad visas med ett ✓\"✓\", byt bil innan du tar bort \(carName)"
                let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                logic.readUserDefaults()
                var cars = [Car]()
                for carDictionary in self.logic.user.carObject.carDataDictionaryArray {
                    let car = Car(dataDictionary: carDictionary)
                    cars.append(car)
                }
                cars.remove(at: indexPath.row)
                var carsDataArray = [[String:Any]]()
                for car in cars {
                    let carDictionaryFromObject = car.dataDictionaryFromObject()
                    carsDataArray.append(carDictionaryFromObject)
                }
                logic.defaults.set(carsDataArray, forKey: logic.defaultsCarDataDictionaryArray)
                logic.user.chosenCarIndex = 0
                logic.defaults.set(logic.user.chosenCarIndex, forKey: logic.defaultsUserChosenCarIndex)
                logic.readUserDefaults()
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
        }
    }
    
    // Tillbaka knapp
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "fromChooseCarToNewCar", sender: self)
    }
    
}
