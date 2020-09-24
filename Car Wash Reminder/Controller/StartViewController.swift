import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet var activityIndicator: UIImageView!
    
    let logic = Logic.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        logic.readUserDefaults()
        performSegueBasedOnUserStatus()
        activityIndicator.spin(true)
    }

    func performSegueBasedOnUserStatus() {
        let userStatus = logic.user.checkUserStatus()
        switch userStatus {
        case .firstTime:
            performSegue(withIdentifier: "fromStartToFirst", sender: self)
        case .nameFirstCar:
            performSegue(withIdentifier: "fromStartToNewCar", sender: self)
        case .setTimeIntervalForFirstCar:
            performSegue(withIdentifier: "fromStartToTime", sender: self)
        case .userHasAtLeastOneCar:
            performSegue(withIdentifier: "fromStartToHome", sender: self)
        }
    }
}
