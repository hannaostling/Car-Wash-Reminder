//
//  ChooseCarTableViewController.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-23.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit

class ChooseCarTableViewController: UITableViewController {
    
    let logic = StartViewController.logic
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
        let carArray = logic.user.carObject.giveCarArray(fromDictionaryArray: logic.user.carObject.carDataDictionaryArray)
        let car = carArray[indexPath.row]
        let carCell = tableView.dequeueReusableCell(withIdentifier: "car", for: indexPath) as! ChooseCarTableViewCell
        carCell.setCar(car: car)
        return carCell
    }
    
    // När man klickar på en rad.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        logic.user.chosenCarIndex = indexPath.row
        logic.defaults.set(self.logic.user.chosenCarIndex, forKey:self.logic.defaultsUserChosenCarIndex)
        let carName = logic.user.carObject.carDataDictionaryArray[indexPath.row][logic.user.carObject.carName] as! String
        let title = "Ditt val är sparat"
        let message = "Nu visas information för \"\(carName)\""
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Tillbaka knapp
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "fromChooseCarToNewCar", sender: self)
    }
    
}
