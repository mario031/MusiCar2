
import UIKit
import AVFoundation
import SVProgressHUD
import SwiftyJSON
import SpriteKit

class LoginViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate{
    
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var makeTextfield: UITextField!
    @IBOutlet weak var joinLabel: UILabel!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var sakusei: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addScroll: UIScrollView!
    @IBOutlet weak var takePictureButton: UIButton!
    
    var txtActiveField: UITextField!
    
    // セッション.
    var mySession : AVCaptureSession!
    // デバイス.
    var myDevice : AVCaptureDevice!
    // 画像のアウトプット.
    var myImageOutput : AVCaptureStillImageOutput!
    var myVideoLayer : AVCaptureVideoPreviewLayer!
    
    var makeGroup: UIButton!
    var joinGroup: UIButton!
    
    var makeBool:Bool = true
    var joinBool:Bool = true
    
    //mysqlのテーブル(グループ名)を格納する
    var tableDataName:[String] = []
    var tableDataDate:[String] = []
    
    var timer:NSTimer!
    
    
    var userDefault: NSUserDefaults = NSUserDefaults()
    
    override func viewDidLoad() {
        
        makeLabel.hidden = true
        makeTextfield.hidden = true
        makeTextfield.enabled = false
        joinLabel.hidden = true
        tableview.hidden = true
        sakusei.hidden = true
        sakusei.enabled = false
        takePictureButton.hidden = true
        takePictureButton.enabled = false

        
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
        
        takePictureButton.layer.borderColor = UIColor.whiteColor().CGColor
        takePictureButton.layer.borderWidth = 3.0
        takePictureButton.layer.masksToBounds = true
        takePictureButton.layer.cornerRadius = 30
        
        if(userDefault.objectForKey("team") != nil){
            groupLabel.text = userDefault.objectForKey("team") as? String
        }
        
    }
    override func viewWillAppear(animated: Bool) {
        userDefault.setObject("", forKey: "number")
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    // Viewが非表示になるたびに呼び出されるメソッド
    override func viewDidDisappear(animated: Bool) {
//        mySession.stopRunning()
//        timer.invalidate()
        super.viewDidDisappear(animated)
        
        // NSNotificationCenterの解除処理
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    //NSTimerIntervalで指定された秒数毎に呼び出されるメソッド.
    func onUpdate(timer : NSTimer){
        if(userDefault.objectForKey("number") != nil){
            self.makeTextfield.text = userDefault.objectForKey("number") as! String
            userDefault.removeObjectForKey("number")
        }
    }
    
    @IBAction func takePicture(sender: UIButton) {
        // ビデオ出力に接続.
        let myVideoConnection = myImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        
        // 接続から画像を取得.
        self.myImageOutput.captureStillImageAsynchronouslyFromConnection(myVideoConnection, completionHandler: { (imageDataBuffer, error) -> Void in
            
            // 取得したImageのDataBufferをJpegに変換.
            let myImageData : NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
            
            // JpegからUIIMageを作成.
            let image : UIImage = UIImage(data: myImageData)!
            CloudVisionRequest().textRequest(image)
            //タイマーを作る.
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "onUpdate:", userInfo: nil, repeats: true)
            
        })
        takePictureButton.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 255)
    }
    @IBAction func buttonHilighted(sender: UIButton) {
        takePictureButton.backgroundColor = UIColor.grayColor()
    }
    
    //画面がタップされた際にキーボードを閉じる処理
    func tapGesture(sender: UITapGestureRecognizer) {
        makeTextfield.resignFirstResponder()
    }
    
    func initCamera() -> Bool {
        // セッションの作成.
        mySession = AVCaptureSession()
        
        // デバイス一覧の取得.
        let devices = AVCaptureDevice.devices()
        
        // バックカメラをmyDeviceに格納.
        for device in devices{
            if(device.position == AVCaptureDevicePosition.Back){
                myDevice = device as! AVCaptureDevice
            }
        }
        
        do{
        // バックカメラからVideoInputを取得.
        let videoInput = try AVCaptureDeviceInput.init(device: myDevice)
            // セッションに追加.
            mySession.addInput(videoInput)
        }
        catch let error as NSError {
            print(error)
        }
        // 出力先を生成.
        myImageOutput = AVCaptureStillImageOutput()
        
        // セッションに追加.
        mySession.addOutput(myImageOutput)
        
        // 画像を表示するレイヤーを生成.
        myVideoLayer = AVCaptureVideoPreviewLayer.init(session: mySession)
        myVideoLayer.frame = imageView.frame
        myVideoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        myVideoLayer.zPosition = -10
        
        // Viewに追加.
        self.view.layer.addSublayer(myVideoLayer)
        
        // セッション開始.
        mySession.startRunning()
        
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
                if self.initCamera(){
                    self.mySession.startRunning()
                }
                self.takePictureButton.hidden = false
                self.takePictureButton.enabled = true
                self.myVideoLayer.hidden = false
                self.view.bringSubviewToFront(self.addScroll)
                self.view.bringSubviewToFront(self.makeTextfield)
                self.view.bringSubviewToFront(self.takePictureButton)
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
            myVideoLayer.hidden = false
            self.view.sendSubviewToBack(addScroll)
            self.view.sendSubviewToBack(makeTextfield)
            self.view.sendSubviewToBack(takePictureButton)
            takePictureButton.hidden = true
            takePictureButton.enabled = false
            myVideoLayer.hidden = true
            mySession.stopRunning()
            
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
            let url1: NSURL! = NSURL(string: "http://life-cloud.ht.sfc.keio.ac.jp/~mario/MusiCar/get_name.php")
            let request1 = NSMutableURLRequest(URL: url1)
            
            //POSTを指定
            request1.HTTPMethod = "POST"
            NSURLConnection.sendAsynchronousRequest(request1, queue: NSOperationQueue.mainQueue(), completionHandler: self.getNameData)
            //URLの指定
            let url2: NSURL! = NSURL(string: "http://life-cloud.ht.sfc.keio.ac.jp/~mario/MusiCar/get_date.php")
            let request2 = NSMutableURLRequest(URL: url2)
            
            //POSTを指定
            request2.HTTPMethod = "POST"
            NSURLConnection.sendAsynchronousRequest(request2, queue: NSOperationQueue.mainQueue(), completionHandler: self.getDateData)

            
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
        if(makeTextfield.text == ""){
            SVProgressHUD.showErrorWithStatus("ナンバーが入力されて\nいません")
        }
        else{
            let alertController = UIAlertController(title: "\(makeTextfield.text! as String) でよろしいですか？", message: "", preferredStyle: .Alert)
            let otherAction = UIAlertAction(title: "OK", style: .Default) {
                action in
                self.mySession.stopRunning()
                let data:NSString = "uid=\(self.userDefault.objectForKey("uid") as! String)&number=\(self.makeTextfield.text! as String)&name=\(self.userDefault.objectForKey("name") as! String) Car&make=yes"
                let myData:NSData = data.dataUsingEncoding(NSUTF8StringEncoding)!
                //URLの指定
                let url: NSURL! = NSURL(string: "http://life-cloud.ht.sfc.keio.ac.jp/~mario/MusiCar/login_make.php")
                let request = NSMutableURLRequest(URL: url)
                
                //POSTを指定
                request.HTTPMethod = "POST"
                //Dataをセット
                request.HTTPBody = myData
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: self.postTeam1)
            }
            let cancelAction = UIAlertAction(title: "CANCEL", style: .Cancel) {
                action in
                
            }
            
            alertController.addAction(otherAction)
            alertController.addAction(cancelAction)
            presentViewController(alertController, animated: true, completion: nil)
            
        }
    }
    
    //team名をPOSTして帰ってきたときに実行される
    func postTeam1(res:NSURLResponse?,data:NSData?,error:NSError?){
        if data != nil{
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            print(dataString)
            if(dataString == "lose"){
                SVProgressHUD.showErrorWithStatus("グループの作成に失敗しました")
            }else{
                SVProgressHUD.showSuccessWithStatus("グループの作成に成功しました")
                groupLabel.text = dataString
            }
        }
    }
    func postTeam2(res:NSURLResponse?,data:NSData?,error:NSError?){
        if data != nil{
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            print(dataString)
        }
    }
    
    //cellにtableを格納する
    func getNameData(res:NSURLResponse?,data:NSData?,error:NSError?){
        if data != nil{
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
//            print(dataString)
            let dataSeparate = dataString.componentsSeparatedByString(",")
            tableDataName.removeAll()
            
            for(var i:Int = 0; i < dataSeparate.count; i++){
                tableDataName.append(dataSeparate[i])
//                print(tableData[i])
            }
//            tableview.reloadData()
//            print(tableData.count)
        }
    }
    //cellにtableを格納する
    func getDateData(res:NSURLResponse?,data:NSData?,error:NSError?){
        if data != nil{
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            //            print(dataString)
            let dataSeparate = dataString.componentsSeparatedByString(",")
            tableDataDate.removeAll()
            
            for(var i:Int = 0; i < dataSeparate.count; i++){
                tableDataDate.append(dataSeparate[i])
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
        return tableDataDate.count
    }
    
    func tableView( tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath ) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell( style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cellngo" )
        
        cell.textLabel!.text = tableDataName[indexPath.row]
        cell.detailTextLabel!.text = tableDataDate[indexPath.row]
//        let cell = tableview.dequeueReusableCellWithIdentifier("Cellngo", forIndexPath: indexPath)
        
//        // Tag番号 1 で UILabel インスタンスの生成
//        let label = tableview.viewWithTag(1) as! UILabel
//        label.text = tableData[indexPath.row]
        
        return cell
    }
    // sectionのタイトル
    func tableView( tableView: UITableView, titleForHeaderInSection section: Int ) -> String? {
        return "Group Name"
    }
    
    // 選択したグループ名を表示
    func tableView( tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath ) {
        let alertController = UIAlertController(title: "\(tableDataName[indexPath.row])に参加してよろしいですか？", message: "", preferredStyle: .Alert)
        let otherAction = UIAlertAction(title: "OK", style: .Default) {
            action in
            
            self.groupLabel.text = self.tableDataName[indexPath.row]
            
            let data:NSString = "uid=\(self.userDefault.objectForKey("uid") as! String)&name=\(self.tableDataName[indexPath.row])&date=\(self.tableDataDate[indexPath.row])&make=no"
            let myData:NSData = data.dataUsingEncoding(NSUTF8StringEncoding)!
            //URLの指定
            let url: NSURL! = NSURL(string: "http://life-cloud.ht.sfc.keio.ac.jp/~mario/MusiCar/login_join.php")
            let request = NSMutableURLRequest(URL: url)
            
            //POSTを指定
            request.HTTPMethod = "POST"
            //Dataをセット
            request.HTTPBody = myData
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: self.postTeam2)
            
            self.endButton.hidden = false
            self.endButton.enabled = true
            self.joinBool = true
            self.joinLabel.hidden = true
            self.tableview.hidden = true
            
            
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
        let cancelAction = UIAlertAction(title: "CANCEL", style: .Cancel) {
            action in
            
        }
        
        alertController.addAction(otherAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    //textFieldを編集する際に行われる処理
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        txtActiveField = textField //　編集しているtextFieldを新しいtextField型の変数に代入する
        return true
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        
        return true
    }
    //キーボードが表示された時
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        //郵便入れみたいなもの
        let userInfo = notification.userInfo!
        //キーボードの大きさを取得
        let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        // 画面のサイズを取得
        let myBoundSize: CGSize = UIScreen.mainScreen().bounds.size
        //　ViewControllerを基準にtextFieldの下辺までの距離を取得
        let txtLimit = txtActiveField.frame.origin.y + txtActiveField.frame.height + 8.0
        // ViewControllerの高さからキーボードの高さを引いた差分を取得
        let kbdLimit = myBoundSize.height - keyboardRect.size.height
        
        //スクロールビューの移動距離設定
        if txtLimit >= kbdLimit {
            addScroll.contentOffset.y = txtLimit - kbdLimit + 150
        }
    }
    
    //ずらした分を戻す処理
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        addScroll.contentOffset.y = 0
    }

    @IBAction func end(sender: UIButton) {
        let team = groupLabel.text!
        // ログイン情報をUserDefaultsに格納
        self.userDefault.setObject(team, forKey: "team")
    }
    
}