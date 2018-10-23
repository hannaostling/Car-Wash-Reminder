//
//  HistoryTableViewController.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-19.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    
    @IBOutlet weak var sortButton: UIBarButtonItem!

    let logic = StartViewController.logic
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logic.readUserDefaults()
        tableView.reloadData()
    }
    
    // Antal rader.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Antal kolumner.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logic.user.cars[logic.user.chosenCarIndex].washedDates.count
    }
    
    // Konfiguera call.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.rowHeight = 100
        var reversedArray: [Date] = []
        for date in logic.user.cars[logic.user.chosenCarIndex].washedDates.reversed() {
            reversedArray.append(date)
        }
        let lastWashed = reversedArray[indexPath.row]
        let historyCell = tableView.dequeueReusableCell(withIdentifier: "carHistory", for: indexPath) as! HistoryTableViewCell
        historyCell.setHistory(lastWashed: lastWashed)
        
//        let car = logic.user.cars[indexPath.row]
//        let carHistoryCell = tableView.dequeueReusableCell(withIdentifier: "carHistory", for: indexPath) as! HistoryTableViewCell
//        carHistoryCell.serCarHistory(car: car)
        return historyCell
    }
    
    // Tillbaka knapp
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
