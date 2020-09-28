import UIKit

class HomeeViewController: UIViewController {

    @IBOutlet var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let attributedString = NSMutableAttributedString(string: "")
        
        let boldText = "Idag är en "
        let attrs = [NSAttributedString.Key.font : Font.medium(size: 25)]
        let attributedString1 = NSMutableAttributedString(string:boldText, attributes:attrs)

        let normalText = "bra "
        let a2 = [NSAttributedString.Key.font : Font.bold(size: 25)]
        let attributedString2 = NSMutableAttributedString(string:normalText, attributes:a2)
        
        
        let tre = "dag att tvätta Bettan"
        let a3 = [NSAttributedString.Key.font : Font.medium(size: 25)]
        let attributedString3 = NSMutableAttributedString(string:tre, attributes:a3)

        attributedString.append(attributedString1)
        attributedString.append(attributedString2)
        attributedString.append(attributedString3)
        label.attributedText = attributedString
    }
    
}
