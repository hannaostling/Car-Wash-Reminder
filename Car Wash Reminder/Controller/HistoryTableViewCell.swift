//
//  HistoryTableViewCell.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-19.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    let logic = Logic.sharedInstance
    
    @IBOutlet weak var daysAgoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setHistory(lastWashed: Date) {
        let dateInString = logic.getDateInString(date: lastWashed)
        dateLabel.text = dateInString
        let daysAgoInt = logic.user.carObject.howManyDaysAgo(date: lastWashed)
        let daysAgoString = "\(daysAgoInt) dagar sedan"
        daysAgoLabel.text = daysAgoString
    }
    
}
