

import UIKit
import SwiftyJSON

class SearchControllerView: UIViewController{
    
    @IBOutlet weak var barBackButton: UIBarButtonItem!
    var songQuery:SongQuery = SongQuery()
    
    var timer:NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //barButtonフォント
        barBackButton.setTitleTextAttributes(NSDictionary(object: UIFont.boldSystemFontOfSize(20), forKey: NSFontAttributeName) as? [String : AnyObject], forState: UIControlState.Normal)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "postSmile:", userInfo: nil, repeats: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func postSmile(timer: NSTimer){
//        let json = JSON(
        //URLの指定
        let url: NSURL! = NSURL(string: "https://vision.googleapis.com/v1alpha1/images:annotate")
        let request = NSMutableURLRequest(URL: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        //POSTを指定
        request.HTTPMethod = "POST"
        //Dataをセット
        request.HTTPBody = xmlData
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: getHttp)
    }
    //レスポンスが帰ってきたら行う関数
    func getHttp(res:NSURLResponse?,data:NSData?,error:NSError?){
        if data != nil{
            let dataString = NSString(data:data!, encoding:NSUTF8StringEncoding) as! String
            print(dataString)
        }
        
    }
}




