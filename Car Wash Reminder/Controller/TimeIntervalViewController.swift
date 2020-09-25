import UIKit
import UserNotifications

class TimeIntervalViewController: UIViewController {

    @IBOutlet weak var weeksPickerView: UIPickerView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    
    let logic = Logic.sharedInstance
    var timeIntervals = ["Inget tidsintervall valt", "Varje vecka", "Varannan vecka"]
    var timeIntervalChoise = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logic.readUserDefaults()
        let carName = logic.getCarName(withCarIndex: logic.user.chosenCarIndex)
        title = "Välj tidsintervall för \(carName)"
        titleLabel.text = title
        let carTimeInterval = logic.getCarTimeInterval(withCarIndex: logic.user.chosenCarIndex)
        setDoneButtonProperties(int: carTimeInterval)
        addTimeIntervals()
        weeksPickerView.dataSource = self
        weeksPickerView.delegate = self
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if timeIntervalChoise != 0 {
            performSegue(withIdentifier: "fromTimeToHome", sender: self)
            var cars = [Car]()
            for carDictionary in self.logic.user.carObject.carDataDictionaryArray {
                let car = Car(dataDictionary: carDictionary)
                cars.append(car)
            }
            cars.remove(at: logic.user.chosenCarIndex)
            let carArray = self.logic.getCarArray()
            let car = carArray[logic.user.chosenCarIndex]
            car.timeIntervalInWeeks = timeIntervalChoise
            cars.append(car)
            var carsDataArray = [[String:Any]]()
            for car in cars {
                let carDictionaryFromObject = car.dataDictionaryFromObject()
                carsDataArray.append(carDictionaryFromObject)
            }
            logic.defaults.set(carsDataArray, forKey: logic.defaultsCarDataDictionaryArray)
            logic.user.chosenCarIndex = carsDataArray.count-1
            logic.defaults.set(logic.user.chosenCarIndex, forKey: logic.defaultsUserChosenCarIndex)
        }
    }
    
    // Lägger till fler element i timeIntervals.
    func addTimeIntervals() {
        for i in 3...12 {
            let timeInterval = "Var \(i):e vecka"
            timeIntervals.append(timeInterval)
        }
    }
    
    // Alert med information till användaren.
    func giveInformationAlert() {
        let title = "Information"
        let message = "Appen söker efter en bra dag att tvätta din bil med bakgrundsdata och du får en notis när det är bra läge att tvätta bilen. \n \n När du sedan tvättat din bil kan du markera din bil som tvättad. Då kommer appen ta en paus från att söka efter en bra dag att tvätta bilen. \n \n Hur lång paus vill du att appen ska låta bli att leta efter en bra dag att tvätta bilen? Det tidsintervallet väljer du här."
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Okej", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Sätter egenskaper på klar-knapp beroende på om val är gjort
    func setDoneButtonProperties(int: Int) {
        if int == 0 {
            doneButton.isEnabled = false
            doneButton.alpha = 0.5
        } else {
            doneButton.isEnabled = true
            doneButton.alpha = 1.0
        }
    }
//    let choiseIsMadeBool = choiseIsMade()
//    if choiseIsMadeBool == true {
//
//    // Kollar om användaren har valt tidsintervall för sista bilen i arrayen
//    func choiseIsMade() -> Bool {
//        let carArray = logic.getCarArray()
//        let amountOfCars = carArray.count
//        if amountOfCars != 0 {
//            let lastIndex = carArray.count-1
//            let lastCarInCarArrayTimeInterval = logic.getCarTimeInterval(withCarIndex: lastIndex)
//            if lastCarInCarArrayTimeInterval == 0 {
//                return false
//            } else {
//                return true
//            }
//        }
//        return false
//    }

}

extension TimeIntervalViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeIntervals.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setDoneButtonProperties(int: row)
        timeIntervalChoise = row
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeIntervals[row]
    }
    
}
