

import UIKit
import MediaPlayer
import AVFoundation

class MusicControllerView: UIViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var musicTitle: UILabel!
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var musicSelect: UIButton!
    @IBOutlet weak var musicArtist: UILabel!
    @IBOutlet weak var changeVolume: UIView!
    
    var mtitle:String? = ""
    var martist:String? = ""
    var audio: AVAudioPlayer! = nil
    var artists: [ArtistInfo] = []
    var songQuery: SongQuery = SongQuery()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        artists = songQuery.get()
        let url: NSURL = artists[0].songs[0].songUrl
        if(audio == nil){
            audio = try? AVAudioPlayer(contentsOfURL: url)
        }
        
        /// バックグラウンドでも再生できるカテゴリに設定する
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch  {
            // エラー処理
            fatalError("カテゴリ設定失敗")
        }
        
        // sessionのアクティブ化
        do {
            try session.setActive(true)
        } catch {
            // audio session有効化失敗時の処理
            // (ここではエラーとして停止している）
            fatalError("session有効化失敗")
        }
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
        //playボタンを隠す
        playButton.hidden = true
        playButton.enabled = false
        
        
        //segmentフォント
        segmentControl.setTitleTextAttributes(NSDictionary(object: UIFont.boldSystemFontOfSize(18), forKey: NSFontAttributeName) as [NSObject : AnyObject], forState: UIControlState.Normal)
        
        //barButtonフォント
        barButton.setTitleTextAttributes(NSDictionary(object: UIFont.boldSystemFontOfSize(20), forKey: NSFontAttributeName) as? [String : AnyObject], forState: UIControlState.Normal)
        
        musicTitle.font = UIFont(name: "Helvetica-BoldOblique", size:24)
        musicSelect.titleLabel!.font = UIFont(name: "ArialRoundedMTBold", size: 38)
        
        performSegueWithIdentifier("goMusicSelecter", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "goMusicSelecter") {
            let backVC: MusicSelectView = (segue.destinationViewController as? MusicSelectView)!
            
            backVC.audio = audio
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        changeVolume.backgroundColor = UIColor.clearColor()
        let myVolumeView:MPVolumeView = MPVolumeView(frame: self.changeVolume.bounds)
        changeVolume.addSubview(myVolumeView)
        musicTitle.text = mtitle
        musicArtist.text = martist
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //segmentの値が変わったら呼び出される
    @IBAction func valueChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("セグメント0")
        case 1:
            print("セグメント1")
        case 2:
            print("セグメント2")
        default:
            print("Error")
        }
    }
    
    //音楽再生
    @IBAction func pushPlay(sender: AnyObject) {
        if(audio.playing == false){
            audio.play()
            playButton.hidden = true
            playButton.enabled = false
            stopButton.hidden = false
            stopButton.enabled = true
        }
    }
    
    //音楽停止
    @IBAction func pushPause(sender: AnyObject) {
        if(audio.playing == true){
            audio.pause()
            stopButton.hidden = true
            stopButton.enabled = false
            playButton.hidden = false
            playButton.enabled = true
        }
    }
    
    //曲スキップ
    @IBAction func pushNext(sender: AnyObject) {
        
    }
    //曲を戻す
    @IBAction func pushBack(sender: AnyObject) {
        
    }
    
    //backボタンを押した時音楽を止めて前画面に戻る
    @IBAction func pushBackButton(sender: UIBarButtonItem) {
        if(audio.playing == true){
            audio.pause()
        }
        let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier( "target" ) as! UIViewController
        targetViewController.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        self.presentViewController( targetViewController, animated: true, completion: nil)
    }
    
}