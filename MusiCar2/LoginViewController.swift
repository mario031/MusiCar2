
import UIKit
import Foundation
import SVProgressHUD
import SwiftyJSON

class LoginViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate{
    
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var makeTextfield: UITextField!
    @IBOutlet weak var joinLabel: UILabel!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var sakusei: UIButton!
    
    var makeGroup: UIButton!
    var joinGroup: UIButton!
    
    var makeBool:Bool = true
    var joinBool:Bool = true
    
    //mysqlのテーブル(グループ名)を格納する
    var tableData:[String] = []
    
    var userDefault: NSUserDefaults = NSUserDefaults()
    
    override func viewDidLoad() {
        let uuid = NSUUID().UUIDString
        print(uuid)
        
        makeLabel.hidden = true
        makeTextfield.hidden = true
        makeTextfield.enabled = false
        joinLabel.hidden = true
        tableview.hidden = true
        sakusei.hidden = true
        sakusei.enabled = false
        
        makeGroup = UIButton(frame: CGRectMake(0,0,self.view.bounds.width, 50))
        makeGroup.setTitle("グループを作成する", forState: .Normal)
        makeGroup.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        makeGroup.setTitleColor(UIColor.cyanColor(), forState: UIControlState.Highlighted)
        makeGroup.titleLabel?.font = UIFont.systemFontOfSize(27.0)
        makeGroup.layer.position = CGPoint(x: self.view.bounds.width/2, y: 390)
        makeGroup.addTarget(self, action: "make:", forControlEvents: .TouchUpInside)
        self.view.addSubview(makeGroup)
        
        joinGroup = UIButton(frame: CGRectMake(0,0,self.view.bounds.width, 50))
        joinGroup.setTitle("グループに参加する", forState: .Normal)
        joinGroup.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        joinGroup.setTitleColor(UIColor.cyanColor(), forState: UIControlState.Highlighted)
        joinGroup.titleLabel?.font = UIFont.systemFontOfSize(27.0)
        joinGroup.layer.position = CGPoint(x: self.view.bounds.width/2, y: 470)
        joinGroup.addTarget(self, action: "join:", forControlEvents: .TouchUpInside)
        self.view.addSubview(joinGroup)
        
        groupLabel.backgroundColor = UIColor.whiteColor()
        groupLabel.layer.borderColor = UIColor.blackColor().CGColor
        groupLabel.layer.borderWidth = 0.5
        groupLabel.layer.masksToBounds = true
        groupLabel.layer.cornerRadius = 5.0
        
        makeTextfield.layer.borderWidth = 0.5
        makeTextfield.layer.masksToBounds = true
        makeTextfield.layer.cornerRadius = 5.0
        
        endButton.layer.borderWidth = 0.5
        endButton.layer.masksToBounds = true
        endButton.layer.cornerRadius = 5.0
        
        
        groupLabel.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func make(sender: UIButton) {
        if(makeBool){
            makeBool = false
            joinGroup.hidden = true
            joinGroup.enabled = false
            endButton.hidden = true
            endButton.enabled = false
            groupLabel.hidden = true
            groupNameLabel.hidden = true

            // アニメーションの時間を2秒に設定.
            UIView.animateWithDuration(0.5,animations: { () -> Void in
        
            self.makeGroup.layer.position = CGPoint(x: self.view.bounds.width/2,y: 60)
            
                // アニメーション完了時の処理
            }) { (Bool) -> Void in
                self.makeLabel.hidden = false
                self.makeTextfield.hidden = false
                self.makeTextfield.enabled = true
                self.sakusei.hidden = false
                self.sakusei.enabled = true
            }
        }else{
            endButton.hidden = false
            endButton.enabled = true
            makeBool = true
            makeLabel.hidden = true
            makeTextfield.hidden = true
            makeTextfield.resignFirstResponder()
            sakusei.hidden = true
            sakusei.enabled = false
            // アニメーションの時間を2秒に設定.
            UIView.animateWithDuration(0.5,animations: { () -> Void in
                    
            self.makeGroup.layer.position = CGPoint(x: self.view.bounds.width/2,y: 390)
                    
                // アニメーション完了時の処理
            }) { (Bool) -> Void in
                self.groupLabel.hidden = false
                self.groupNameLabel.hidden = false
                self.joinGroup.hidden = false
                self.joinGroup.enabled = true
            }
        }
    }
    
    func join(sender: UIButton) {
        if(joinBool){
            //URLの指定
            let url: NSURL! = NSURL(string: "http://life-cloud.ht.sfc.keio.ac.jp/~mario/MusiCar/get.php")
            let request = NSMutableURLRequest(URL: url)
            
            //POSTを指定
            request.HTTPMethod = "POST"
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: self.getData)
            
            endButton.hidden = true
            endButton.enabled = false
            joinBool = false
            makeGroup.hidden = true
            makeGroup.enabled = false
            groupLabel.hidden = true
            groupNameLabel.hidden = true
            // アニメーションの時間を2秒に設定.
            UIView.animateWithDuration(0.5,animations: { () -> Void in
                
                self.joinGroup.layer.position = CGPoint(x: self.view.bounds.width/2,y: 60)
            
                // アニメーション完了時の処理
                }) { (Bool) -> Void in
                    self.joinLabel.hidden = false
                    self.tableview.hidden = false
            }
        }else{
            endButton.hidden = false
            endButton.enabled = true
            joinBool = true
            joinLabel.hidden = true
            tableview.hidden = true
            
            // アニメーションの時間を2秒に設定.
            UIView.animateWithDuration(0.5,animations: { () -> Void in
                
                self.joinGroup.layer.position = CGPoint(x: self.view.bounds.width/2,y: 470)
                
                // アニメーション完了時の処理
                }) { (Bool) -> Void in
                    self.groupLabel.hidden = false
                    self.groupNameLabel.hidden = false
                    self.makeGroup.hidden = false
                    self.makeGroup.enabled = true
            }
        }
    }
    
    @IBAction func sakusei(sender: UIButton) {
        let data:NSString = "team=\(makeTextfield.text! as String)"
        let myData:NSData = data.dataUsingEncoding(NSUTF8StringEncoding)!
        //URLの指定
        let url: NSURL! = NSURL(string: "http://life-cloud.ht.sfc.keio.ac.jp/~mario/MusiCar/login.php")
        let request = NSMutableURLRequest(URL: url)
        
        //POSTを指定
        request.HTTPMethod = "POST"
        //Dataをセット
        request.HTTPBody = myData
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: self.postTeam)
        
        groupLabel.text = makeTextfield.text
    }
    //team名をPOSTして帰ってきたときに実行される
    func postTeam(res:NSURLResponse?,data:NSData?,error:NSError?){
        if data != nil{
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            print(dataString)
            if(dataString == "success"){
                SVProgressHUD.showSuccessWithStatus("グループを作成しました")
            }else if(dataString == "lose"){
                SVProgressHUD.showErrorWithStatus("グループの作成に失敗しました")
            }else if(dataString == "this table is already exist"){
                SVProgressHUD.showErrorWithStatus("このグループ名はすでに存在します")
            }
        }
    }
    //cellにtableを格納する
    func getData(res:NSURLResponse?,data:NSData?,error:NSError?){
        if data != nil{
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            let dataSeparate = dataString.componentsSeparatedByString(",")
            tableData.removeAll()
            
            for(var i:Int = 0; i < dataSeparate.count; i++){
                tableData.append(dataSeparate[i])
//                print(tableData[i])
            }
            tableview.reloadData()
//            print(tableData.count)
        }
    }
    
    // sectionの数を返す
    func numberOfSectionsInTableView( tableView: UITableView ) -> Int {
        
        return 1
    }
    
    // セクションの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView( tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath ) -> UITableViewCell {
        
        let cell = tableview.dequeueReusableCellWithIdentifier("Cellngo", forIndexPath: indexPath)
        
        // Tag番号 1 で UILabel インスタンスの生成
        let label = tableview.viewWithTag(1) as! UILabel
        label.text = tableData[indexPath.row]
        
        return cell
    }
    // sectionのタイトル
    func tableView( tableView: UITableView, titleForHeaderInSection section: Int ) -> String? {
        return "Group Name"
    }
    
    // 選択したグループ名を表示
    func tableView( tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath ) {
        groupLabel.text = tableData[indexPath.row]
        
        endButton.hidden = false
        endButton.enabled = true
        joinBool = true
        joinLabel.hidden = true
        tableview.hidden = true
        
        
        // アニメーションの時間を2秒に設定.
        UIView.animateWithDuration(0.5,animations: { () -> Void in
            
            self.joinGroup.layer.position = CGPoint(x: self.view.bounds.width/2,y: 470)
            
            // アニメーション完了時の処理
            }) { (Bool) -> Void in
                self.groupLabel.hidden = false
                self.groupNameLabel.hidden = false
                self.makeGroup.hidden = false
                self.makeGroup.enabled = true
        }
        
    }

    @IBAction func end(sender: UIButton) {
        let team = groupLabel.text!
        // ログイン情報をUserDefaultsに格納
        self.userDefault.setObject(team, forKey: "team")
    }
    
}