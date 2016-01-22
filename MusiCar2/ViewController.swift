

import UIKit
import AVFoundation
import RealmSwift

class ViewController: UIViewController{
    
    @IBOutlet weak var musiCar: UILabel!
    
    override func viewDidLoad() {
        

        super.viewDidLoad()
        musiCar.font = UIFont(name: "Helvetica-BoldOblique", size:60)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}




