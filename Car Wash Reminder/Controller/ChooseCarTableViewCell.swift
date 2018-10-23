//
//  ChooseCarTableViewCell.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-23.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit

class ChooseCarTableViewCell: UITableViewCell {
    
    let logic = StartViewController.logic
    
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var carLastWashedDaysAgoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setHistory(lastWashed: Date) {
        let dateInString = getDateInString(date: lastWashed)
        carNameLabel.text = dateInString
        let daysAgoInt = logic.user.carObject.howManyDaysAgo(date: lastWashed)
        let daysAgoString = "\(daysAgoInt) dagar sedan"
        carLastWashedDaysAgoLabel.text = daysAgoString
    }
    
    func getDateInString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "sv")
        formatter.dateFormat = "d MMMM yyyy"
        let dateString = formatter.string(from: date)
        let dateCapitalized = dateString.capitalized
        return dateCapitalized
    }
    
}


