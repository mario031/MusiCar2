import UIKit
import SwiftyJSON
import AVFoundation

class SearchControllerView: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
    
    @IBOutlet weak var barBackButton: UIBarButtonItem!
    
    var mySession : AVCaptureSession!
    var myDevice : AVCaptureDevice!
    var myOutput : AVCaptureVideoDataOutput!
    
    var songQuery:SongQuery = SongQuery()
    
    var timer:NSTimer!
    
    var userDefault: NSUserDefaults = NSUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //barButtonフォント
        barBackButton.setTitleTextAttributes(NSDictionary(object: UIFont.boldSystemFontOfSize(20), forKey: NSFontAttributeName) as? [String : AnyObject], forState: UIControlState.Normal)
        
        if initCamera(){
            mySession.startRunning()
        }
    }
    override func viewDidDisappear(animated: Bool) {
        mySession.stopRunning()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            myDevice.activeVideoMinFrameDuration = CMTimeMake(1,2)
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
            // アルバムに追加.
//            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            CloudVisionRequest().smileRequest(image)
            
        })
    }
    
}




