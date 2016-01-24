

import UIKit
import SVProgressHUD

class RegisterViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
     var userDefault: NSUserDefaults = NSUserDefaults()
    
    override func viewDidLoad() {
        let uid = NSUUID().UUIDString
        userDefault.setObject(uid, forKey: "uid")
        
        super.viewDidLoad()
        
        nameTextField.layer.borderWidth = 0.5
        nameTextField.layer.masksToBounds = true
        nameTextField.layer.cornerRadius = 5.0
        loginButton.layer.borderWidth = 0.5
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 5.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        nameTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        
        textField.resignFirstResponder()
        
        return true
    }
    
    @IBAction func login(sender: UIButton) {
        if(nameTextField.text == ""){
            SVProgressHUD.showErrorWithStatus("名前が入力されていません")
        }else{
            let alertController = UIAlertController(title: "\(nameTextField.text! as String)でよろしいですか？", message: "", preferredStyle: .Alert)
            let otherAction = UIAlertAction(title: "OK", style: .Default) {
                action in
                
                let data:NSString = "name=\(self.nameTextField.text! as String)&uid=\(self.userDefault.objectForKey("uid") as! String)"
                let myData:NSData = data.dataUsingEncoding(NSUTF8StringEncoding)!
                let url: NSURL! = NSURL(string: "http://life-cloud.ht.sfc.keio.ac.jp/~mario/MusiCar/register.php")
                let request = NSMutableURLRequest(URL: url)
                
                //POSTを指定
                request.HTTPMethod = "POST"
                //Dataをセット
                request.HTTPBody = myData
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: self.postLoginData)
               
                
                let name = self.nameTextField.text!
                self.userDefault.setObject(name, forKey: "name")
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let firstViewController = storyBoard.instantiateViewControllerWithIdentifier("FirstViewController")
                self.presentViewController(firstViewController, animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "CANCEL", style: .Cancel) {
                action in
                
            }
            
            alertController.addAction(otherAction)
            alertController.addAction(cancelAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func postLoginData(res:NSURLResponse?,data:NSData?,error:NSError?){
        if data != nil{
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            print(dataString)
        }
    }
}




