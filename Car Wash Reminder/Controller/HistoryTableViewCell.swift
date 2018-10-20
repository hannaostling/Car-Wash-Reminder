//
//  HistoryTableViewCell.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-19.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    let logic = StartViewController.logic
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setHistory(lastWashed: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "sv")
        formatter.dateFormat = "d MMMM yyyy"
        let date = formatter.string(from: lastWashed)
        let dateCapitalized = date.capitalized
        dateLabel.text = dateCapitalized
    }

}
