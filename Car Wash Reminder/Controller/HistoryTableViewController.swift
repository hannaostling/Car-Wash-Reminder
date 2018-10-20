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
        return logic.user.car.history.count
    }
    
    // Konfiguera call.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reversedArray: [Date] = []
        for date in logic.user.car.history.reversed() {
            reversedArray.append(date)
        }
        let lastWashed = reversedArray[indexPath.row]
        
        let washedCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HistoryTableViewCell
        washedCell.setHistory(lastWashed: lastWashed)
        return washedCell
    }
    
}
