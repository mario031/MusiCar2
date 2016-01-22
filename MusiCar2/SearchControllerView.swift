import UIKit
import SwiftyJSON
import AVFoundation

class SearchControllerView: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
    
    @IBOutlet weak var barBackButton: UIBarButtonItem!
    
    var mySession : AVCaptureSession!
    var myDevice : AVCaptureDevice!
    var myOutput : AVCaptureVideoDataOutput!
    
    var data_mood:[String] = []
    
    var songQuery:SongQuery = SongQuery()
    
    var timer:NSTimer!
    
    var userDefault: NSUserDefaults = NSUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //barButtonフォント
        barBackButton.setTitleTextAttributes(NSDictionary(object: UIFont.boldSystemFontOfSize(20), forKey: NSFontAttributeName) as? [String : AnyObject], forState: UIControlState.Normal)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "postSmile:", userInfo: nil, repeats: true)
    }
    override func viewDidDisappear(animated: Bool) {
        timer.invalidate()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func postSmile(timer: NSTimer){
        if initCamera(){
            mySession.startRunning()
        }
    }
    
    func initCamera() -> Bool {
        mySession = AVCaptureSession()
        mySession.sessionPreset = AVCaptureSessionPresetMedium
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if(device.position == AVCaptureDevicePosition.Front){
                myDevice = device as! AVCaptureDevice
            }
        }
        if myDevice == nil {
            return false
        }
        let myInput = try! AVCaptureDeviceInput(device: myDevice)
        if mySession.canAddInput(myInput) {
            mySession.addInput(myInput)
        } else {
            return false
        }
        myOutput = AVCaptureVideoDataOutput()
        myOutput.videoSettings = [ kCVPixelBufferPixelFormatTypeKey: Int(kCVPixelFormatType_32BGRA) ]
        do {
            try myDevice.lockForConfiguration()
            myDevice.activeVideoMinFrameDuration = CMTimeMake(1, 15)
            myDevice.unlockForConfiguration()
        } catch {
            print("lock error")
        }
        let queue: dispatch_queue_t = dispatch_queue_create("myqueue",  nil)
        myOutput.setSampleBufferDelegate(self, queue: queue)
        myOutput.alwaysDiscardsLateVideoFrames = false
        if mySession.canAddOutput(myOutput) {
            mySession.addOutput(myOutput)
        } else {
            return false
        }
        for connection in myOutput.connections {
            if let conn = connection as? AVCaptureConnection {
                if conn.supportsVideoOrientation {
                    conn.videoOrientation = AVCaptureVideoOrientation.Portrait
                }
            }
        }
        
        return true
    }
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!)
    {
        dispatch_sync(dispatch_get_main_queue(), {
            
            let image:UIImage = CameraUtil.imageFromSampleBuffer(sampleBuffer)
            let pngImage = UIImagePNGRepresentation(image)
            let base64String:String = pngImage!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            //            print(base64String)
            let obj:[String:AnyObject] = [
                "requests":[
                    "image":[
                        "content":"\(base64String)"
                    ],
                    "features":[
                        "type":"FACE_DETECTION",
                        "maxResults":1
                    ]
                ]
            ]
            let data = try! NSJSONSerialization.dataWithJSONObject(obj, options: NSJSONWritingOptions.PrettyPrinted)
            //URLの指定
            let url: NSURL! = NSURL(string: "https://vision.googleapis.com/v1alpha1/images:annotate?key=AIzaSyD1Fs8tbnNqBpKijuGrPqF9Ldpdt4uPlfo")
            let request = NSMutableURLRequest(URL: url)
            
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            
            //POSTを指定
            request.HTTPMethod = "POST"
            //Dataをセット
            request.HTTPBody = data
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: self.getHttp)
            
             self.mySession.stopRunning()
        })
    }
    //レスポンスが帰ってきたら行う関数
    func getHttp(res:NSURLResponse?,data:NSData?,error:NSError?){
        if data != nil{
            let dataString = NSString(data:data!, encoding:NSUTF8StringEncoding) as! String
            let json = JSON(data:data!)
            let happyFace = json["responses"][0]["faceAnnotations"][0]["joyLikelihood"]
            
            if(happyFace.string != nil){
                data_mood.append(happyFace.stringValue)
                print(happyFace.stringValue)
            }else if(happyFace.string == nil){
                data_mood.append("no_face")
                print("no face")
            }
            let data:NSString = "data=\(data_mood)&team=\(userDefault.objectForKey("team") as! String)&name=\(userDefault.objectForKey("name") as! String)"
            let myData:NSData = data.dataUsingEncoding(NSUTF8StringEncoding)!
            //URLの指定
            let url: NSURL! = NSURL(string: "http://life-cloud.ht.sfc.keio.ac.jp/~mario/MusiCar/insert.php")
            let request = NSMutableURLRequest(URL: url)
            
            //POSTを指定
            request.HTTPMethod = "POST"
            //Dataをセット
            request.HTTPBody = myData
            if(data_mood.count == 10){
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: self.postMood)
                data_mood.removeAll()
            }
            
        }
        
    }
    func postMood(res:NSURLResponse?,data:NSData?,error:NSError?){
        if data != nil{
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
//            print(dataString)
        }
    }
}




