//
//  HistoryTableViewController.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-19.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    
    let logic = Logic.sharedInstance
    var dates = [Date]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logic.readUserDefaults()
        dates = logic.user.carObject.carDataDictionaryArray[logic.user.chosenCarIndex][logic.user.carObject.carWashedDates] as! [Date]
        let carName = logic.user.carObject.carDataDictionaryArray[logic.user.chosenCarIndex][logic.user.carObject.carName] as! String
        title = "\(carName) senast tvättad"
        tableView.reloadData()
    }
    
    // Antal rader.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Antal kolumner.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let amountOfRows = dates.count
        return amountOfRows
    }
    
    // Konfiguera call.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.rowHeight = 100
        var reversedArray: [Date] = []
        for date in dates.reversed() {
            reversedArray.append(date)
        }
        let lastWashed = reversedArray[indexPath.row]
        let historyCell = tableView.dequeueReusableCell(withIdentifier: "carHistory", for: indexPath) as! HistoryTableViewCell
        historyCell.setHistory(lastWashed: lastWashed)
        return historyCell
    }
    
    // Tillbaka knapp
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Byr bil knapp
    @IBAction func changeCarButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "fromHistoryToChooseCar", sender: self)
    }
    
}
