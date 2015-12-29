

import UIKit

class SearchControllerView: UIViewController{
    
    @IBOutlet weak var barBackButton: UIBarButtonItem!
    var songQuery:SongQuery = SongQuery()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //barButtonフォント
        barBackButton.setTitleTextAttributes(NSDictionary(object: UIFont.boldSystemFontOfSize(20), forKey: NSFontAttributeName) as? [String : AnyObject], forState: UIControlState.Normal)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}




