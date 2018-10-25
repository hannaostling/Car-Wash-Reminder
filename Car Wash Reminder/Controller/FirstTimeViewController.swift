//
//  FirstTimeViewController.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-17.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit

class FirstTimeViewController: UIViewController {
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    var index = 0
    let logic = Logic.sharedInstance
    let messages = ["Wash Me är en app för dig som vill ha hjälp att hitta ett bra läge att tvätta din bil.",
                    "Appen kommer ge dig en notis så fort vädret är bra, så minimerar du risken att hamna i långa biltvättsköer.",
                    "Du kan markera din bil som tvättad så pausar appens sökande i ett tidsintervall som du själv väljer i nästa steg.",
                    "För att appen ska fungera måste du alltså tillåta notiser."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        pageControl.numberOfPages = messages.count
        label.text = messages[0]
        messageView.layer.cornerRadius = messageView.frame.height/5
        setText()
    }
  
    // Sätt texten till samma sida som pageControll
    @IBAction func pageControl(_ sender: Any) {
        setText()
    }
    
    // Gå tillbaka en sida.
    @IBAction func leftButtonPressed(_ sender: Any) {
        pageControl.currentPage -= 1
        setText()
    }
    
    // Gå fram en sida.
    @IBAction func rightButtonPressed(_ sender: Any) {
        pageControl.currentPage += 1
        setText()
    }
    
    // När användaren klickar på "Okej" så sätts logic.user.hasOpenedAppBefore till sant.
    @IBAction func okButtonPressed(_ sender: Any) {
        logic.user.hasOpenedAppBefore = true
        logic.defaults.set(logic.user.hasOpenedAppBefore, forKey:logic.defaultsUserOpenedAppBefore)
    }
    
    // Sätt texten till pageControl.currentPage. Gör knappen enabled när användaren läst allt.
    func setText() {
        label.text = messages[pageControl.currentPage]
        var userHasReadEverything = false
        if pageControl.currentPage == 0 {
            leftButton.isEnabled = false
            leftButton.alpha = 0.5
        } else if pageControl.currentPage == messages.count-1 {
            userHasReadEverything = true
            rightButton.isEnabled = false
            rightButton.alpha = 0.5
        } else {
            rightButton.isEnabled = true
            leftButton.isEnabled = true
            leftButton.alpha = 1.0
            rightButton.alpha = 1.0
        }
        if userHasReadEverything == true {
            okButton.isEnabled = true
            okButton.alpha = 1.0
        }
    }
 
}
