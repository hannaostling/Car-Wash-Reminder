import UIKit
import MapKit

class PermissionViewController: UIViewController {
    
    @IBOutlet var notificationsButton: UIButton!
    @IBOutlet var positionButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    
    let locationManager = CLLocationManager()
    let logic = Logic.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        setupUI()
    }
    
    @IBAction func notificationsPressed(_ sender: Any) {
        vibrate(.light)
        notificationsDenied { denied in
            DispatchQueue.main.async {
                if denied {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                } else {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { allow, error in
                        self.setupUI()
                    }
                }
            }
        }
    }
    
    @IBAction func positionPressed(_ sender: Any) {
        vibrate(.light)
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
            locationManager.delegate = self
        } else {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        vibrate(.medium)
        print("Next pressed")
        performSegue(withIdentifier: "fromPermissionToName", sender: nil)
    }
    
    private func setupUI() {
        notificationsEnabled { notificationsEnabled in
            DispatchQueue.main.async {
                self.notificationsButton.alpha = notificationsEnabled ? 0.5 : 1
                self.notificationsButton.isEnabled = !notificationsEnabled
                self.positionButton.alpha = self.positionEnabled ? 0.5 : 1
                self.positionButton.isEnabled = !self.positionEnabled
                self.nextButton.alpha = notificationsEnabled && self.positionEnabled ? 1 : 0.5
                self.nextButton.isEnabled = notificationsEnabled && self.positionEnabled
            }
        }
    }
    
    typealias BoolClosure = (Bool) -> Void
    private func notificationsEnabled(completion: @escaping BoolClosure)  {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            switch settings.authorizationStatus {
            case .authorized:
                completion(true)
            default:
                completion(false)
            }
        })
    }
    
    private func notificationsDenied(completion: @escaping BoolClosure)  {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            switch settings.authorizationStatus {
            case .denied:
                completion(true)
            default:
                completion(false)
            }
        })
    }
    
    private var positionEnabled: Bool {
        if CLLocationManager.locationServicesEnabled() {
             switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    return false
                case .authorizedAlways, .authorizedWhenInUse:
                    return true
                }
            } else {
                return false
        }
    }
    
    private func addObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appEnteredForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc func appEnteredForeground() {
        setupUI()
    }
    
    typealias AlertActionClosure = (UIAlertAction) -> Void
    private func showAlertWithAction(title: String, message: String, onAction: @escaping AlertActionClosure) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: onAction))
        present(alert, animated: true)
    }
    
}


extension PermissionViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            logic.user.positionParams = ["lat": latitude, "lon": longitude, "appid": logic.APP_ID]
            logic.defaults.set(logic.user.positionParams, forKey: logic.defaultsPositionParams)
            setupUI()
        }
    }
    
}

func vibrate(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
}
