//
//  ViewController.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-08.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var thumbsUp: Bool = false
    
    @IBOutlet weak var thumb: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func testButton(_ sender: Any) {
        if thumbsUp == true {
            thumb.image = UIImage(named: "thumbs-up")
            thumbsUp = false
        } else {
            thumb.image = UIImage(named: "thumbs-down")
            thumbsUp = true
        }
        
    }
    
}
