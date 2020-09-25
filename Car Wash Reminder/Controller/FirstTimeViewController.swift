import UIKit

class FirstTimeViewController: UIViewController {
    
    let logic = Logic.sharedInstance
  
    @IBAction func okButtonPressed(_ sender: Any) {
        logic.user.hasOpenedAppBefore = true
        logic.defaults.set(logic.user.hasOpenedAppBefore, forKey:logic.defaultsUserOpenedAppBefore)
        performSegue(withIdentifier: "fromFirstToPermission", sender: nil)
    }
 
}
