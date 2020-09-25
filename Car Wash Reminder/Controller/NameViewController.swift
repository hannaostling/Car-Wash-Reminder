import UIKit

class NameViewController: UIViewController {

    @IBOutlet weak var nameCarTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    let logic = Logic.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameCarTextField.style()
        hideKeyboardWhenTappedAround()
        nextButton.isEnabled = false
        logic.askForNotificationPermission()
        logic.readUserDefaults()
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        next()
    }
    
    @IBAction func textFieldDidBeginEditing(_ sender: Any) {
        updateUI()
    }
    
    @IBAction func textFieldShouldReturn(_ sender: Any) {
        nameCarTextField.resignFirstResponder()
        next()
    }
    
    @IBAction func textFieldEditingChanged(_ sender: Any) {
        updateUI()
    }
    
    private func updateUI() {
        guard let name = nameCarTextField.text else {return}
        nextButton.isEnabled = !name.isEmpty
        nextButton.alpha = !name.isEmpty ? 1 : 0
    }
    
    // Vad som ska häna när användaren klickar på nästa, ovsett om det är från return button i textfield eller om det är knappen "nextButton".
    private func next() {
        logic.readUserDefaults()
        let carName = nameCarTextField.text!
        nameTheCar(carName: carName)
    }
    
    // Alert: fråga om användaren om
    private func nameTheCar(carName: String) {
        var title = ""
        var message = ""
        if carName.count == 0 {
            title = "För kort namn"
            message = "Bilens namn måste bestå av minst 1 bokstav"
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if carName.count > 0 && carName.count < 9 {
            var cars = [Car]()
            for dataDictionary in logic.user.carObject.carDataDictionaryArray {
                let car = Car(dataDictionary: dataDictionary)
                cars.append(car)
            }
            let car = Car()
            car.name = "\(carName)"
            car.isDirtyBool = true
            cars.append(car)
            logic.user.chosenCarIndex = cars.count-1
            logic.defaults.set(self.logic.user.chosenCarIndex, forKey:self.logic.defaultsUserChosenCarIndex)
            var carsDataArray = [[String:Any]]()
            for car in cars {
                let carDictionaryFromObject = car.dataDictionaryFromObject()
                carsDataArray.append(carDictionaryFromObject)
            }
            logic.defaults.set(carsDataArray, forKey: logic.defaultsCarDataDictionaryArray)
            performSegue(withIdentifier: "fromNameCarToTime", sender: self)
        } else {
            title = "För långt namn"
            message = "Bilens namn måste bestå av max 8 bokstäver"
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
