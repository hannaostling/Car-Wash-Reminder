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
    
    var index = 0
    let logic = Logic.sharedInstance
    let messages = ["Det här är en app för dig som vill slippa tänka på när du behöver tvätta din bil.","Appen kommer ge dig en notis varje gång vädret är bra samma dag och dagen efter.","Du kan markera din bil som tvättad så pausar appens sökande i ett tidsintervall som du själv väljer i nästa steg.", "För att appen ska fungera måste du alltså tillåta notiser, är det okej?"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        pageControl.numberOfPages = messages.count
        label.text = messages[0]
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
        if pageControl.currentPage == messages.count-1 {
            userHasReadEverything = true
        }
        if userHasReadEverything == true {
            okButton.isEnabled = true
            okButton.alpha = 1.0
        }
    }
 
}
