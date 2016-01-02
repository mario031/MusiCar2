

import UIKit
import MediaPlayer
import AVFoundation
import RealmSwift

class MusicControllerView: UIViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var musicTitle: UILabel!
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var musicSelect: UIButton!
    @IBOutlet weak var musicArtist: UILabel!
    @IBOutlet weak var changeVolume: UIView!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    
    
    //外部から受け取る変数たち
    var mtitle:String? = ""
    var martist:String? = ""
    var artistNum:Int = 0
    var songNum:Int = 0
    var audio: AVAudioPlayer! = nil
    var artists: [ArtistInfo] = []
    var songQuery: SongQuery = SongQuery()
    
    //modeセレクト
    var mode:Int = 1
    let segueIdentifiers = ["goMusicSelecter2", "goMusicSelecter","goMusicSelecter"]
    
    var sTime:Int = 0
    var eTime:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        artists = songQuery.get()
        let url: NSURL = artists[0].songs[0].songUrl
        if(audio == nil){
            audio = try? AVAudioPlayer(contentsOfURL: url)
        }
        
        
        //playボタンを隠す
        playButton.hidden = true
        playButton.enabled = false
        
        
        //segmentフォント
        segmentControl.setTitleTextAttributes(NSDictionary(object: UIFont.boldSystemFontOfSize(18), forKey: NSFontAttributeName) as [NSObject : AnyObject], forState: UIControlState.Normal)
        
        //barButtonフォント
        barButton.setTitleTextAttributes(NSDictionary(object: UIFont.boldSystemFontOfSize(20), forKey: NSFontAttributeName) as? [String : AnyObject], forState: UIControlState.Normal)
        
        musicTitle.font = UIFont(name: "Helvetica-BoldOblique", size:24)
        musicSelect.titleLabel!.font = UIFont(name: "ArialRoundedMTBold", size: 38)
//        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "onUpdate:", userInfo: nil, repeats: true)
        
        performSegueWithIdentifier("goMusicSelecter", sender: nil)
        performSegueWithIdentifier("goMusicSelecter2", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "goMusicSelecter") {
            let backVC: MusicSelectView = (segue.destinationViewController as? MusicSelectView)!
            
            backVC.audio = audio
            backVC.artistNum = artistNum
            backVC.songNum = songNum
            
        }else if (segue.identifier == "goMusicSelecter2") {
            let backVC: MusicSelectMood = (segue.destinationViewController as? MusicSelectMood)!
            
            backVC.audio = audio
            backVC.artistNum = artistNum
            backVC.songNum = songNum
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
        changeVolume.backgroundColor = UIColor.clearColor()
        let myVolumeView:MPVolumeView = MPVolumeView(frame: self.changeVolume.bounds)
        changeVolume.addSubview(myVolumeView)
        musicTitle.text = mtitle
        musicArtist.text = martist
    }
    @IBAction func goMusicSelect(sender: UIButton) {
        // 選択されているSegment Controlのindexから、"sheep"か"goat"を取得する
        let next = segueIdentifiers[segmentControl.selectedSegmentIndex]
        
        // 上記の情報をもとに、実際にidentifiewを指定して遷移する
        performSegueWithIdentifier(next, sender: sender)
    }
    
    //segmentの値が変わったら呼び出される
    @IBAction func valueChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mode = 0
            print("セグメント0")
        case 1:
            mode = 1
            print("セグメント1")
        case 2:
            mode = 2
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
        audio.stop()
        if(audio.playing == false){
            playButton.hidden = true
            playButton.enabled = false
            stopButton.hidden = false
            stopButton.enabled = true
        }else if(audio.playing == true){
            stopButton.hidden = true
            stopButton.enabled = false
            playButton.hidden = false
            playButton.enabled = true
        }
        if(audio != nil){
            //normalもーどの場合
            if(mode == 1){
                if(songNum == artists[artistNum].songs.count - 1 && artistNum != artists.count - 1){
                    artistNum++
                    songNum = 0
                    let url: NSURL = artists[artistNum].songs[songNum].songUrl
                    audio = try? AVAudioPlayer(contentsOfURL: url)
                    audio.play()
                }else if(songNum == artists[artistNum].songs.count - 1 && artistNum == artists.count - 1){
                    artistNum = 0
                    songNum = 0
                    let url: NSURL = artists[artistNum].songs[songNum].songUrl
                    audio = try? AVAudioPlayer(contentsOfURL: url)
                    audio.play()
                }else{
                    songNum++
                    let url: NSURL = artists[artistNum].songs[songNum].songUrl
                    audio = try? AVAudioPlayer(contentsOfURL: url)
                    audio.play()
                }
                //シャッフルモードの場合
            }else if(mode == 2){
                artistNum = Int(arc4random_uniform(UInt32(artists.count)))
                songNum = Int(arc4random_uniform(UInt32(artists[artistNum].songs.count)))
                let url: NSURL = artists[artistNum].songs[songNum].songUrl
                audio = try? AVAudioPlayer(contentsOfURL: url)
                audio.play()
            }
            musicTitle.text = artists[artistNum].songs[songNum].songTitle
            musicArtist.text = artists[artistNum].songs[songNum].artistName
        }
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyArtist : "\(artists[artistNum].songs[songNum].artistName)",  MPMediaItemPropertyTitle : "\(artists[artistNum].songs[songNum].songTitle)", MPMediaItemPropertyPlaybackDuration: audio.duration, MPNowPlayingInfoPropertyElapsedPlaybackTime: audio.currentTime]
    }
    //曲を戻す
    @IBAction func pushBack(sender: AnyObject) {
        audio.stop()
        if(audio.playing == false){
            playButton.hidden = true
            playButton.enabled = false
            stopButton.hidden = false
            stopButton.enabled = true
        }else if(audio.playing == true){
            stopButton.hidden = true
            stopButton.enabled = false
            playButton.hidden = false
            playButton.enabled = true
        }
        if(audio != nil){
            if(songNum == 0 && artistNum != 0){
                artistNum--
                songNum = artists[artistNum].songs.count - 1
                let url: NSURL = artists[artistNum].songs[songNum].songUrl
                audio = try? AVAudioPlayer(contentsOfURL: url)
                audio.play()
            }else if(songNum == 0 && artistNum == 0){
                artistNum = artists.count - 1
                songNum = artists[artistNum].songs.count - 1
                let url: NSURL = artists[artistNum].songs[songNum].songUrl
                audio = try? AVAudioPlayer(contentsOfURL: url)
                audio.play()
            }else{
                songNum--
                let url: NSURL = artists[artistNum].songs[songNum].songUrl
                audio = try? AVAudioPlayer(contentsOfURL: url)
                audio.play()
            }
            musicTitle.text = artists[artistNum].songs[songNum].songTitle
            musicArtist.text = artists[artistNum].songs[songNum].artistName
        }
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyArtist : "\(artists[artistNum].songs[songNum].artistName)",  MPMediaItemPropertyTitle : "\(artists[artistNum].songs[songNum].songTitle)", MPMediaItemPropertyPlaybackDuration: audio.duration, MPNowPlayingInfoPropertyElapsedPlaybackTime: audio.currentTime]
    }
    //曲が終わったら次の曲を流す
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        if(flag == true){
            if(songNum == artists[artistNum].songs.count ){
                artistNum++
                songNum = 0
                let url: NSURL = artists[artistNum].songs[songNum].songUrl
                audio = try? AVAudioPlayer(contentsOfURL: url)
                audio.play()
            }else{
                songNum++
                let url: NSURL = artists[artistNum].songs[songNum].songUrl
                audio = try? AVAudioPlayer(contentsOfURL: url)
                audio.play()
            }
            musicTitle.text = artists[artistNum].songs[songNum].songTitle
            musicArtist.text = artists[artistNum].songs[songNum].artistName
        }
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if(event?.type == UIEventType.RemoteControl){
            if(event?.subtype == UIEventSubtype.RemoteControlPlay){
                audio.play()
                playButton.hidden = true
                playButton.enabled = false
                stopButton.hidden = false
                stopButton.enabled = true
            }else if(event?.subtype == UIEventSubtype.RemoteControlPause){
                audio.pause()
                stopButton.hidden = true
                stopButton.enabled = false
                playButton.hidden = false
                playButton.enabled = true
            }else if(event?.subtype == UIEventSubtype.RemoteControlNextTrack){
                audio.stop()
                if(audio != nil){
                    //normalもーどの場合
                    if(mode == 1){
                        if(songNum == artists[artistNum].songs.count - 1 ){
                            artistNum++
                            songNum = 0
                            let url: NSURL = artists[artistNum].songs[songNum].songUrl
                            audio = try? AVAudioPlayer(contentsOfURL: url)
                            audio.play()
                        }else{
                            songNum++
                            let url: NSURL = artists[artistNum].songs[songNum].songUrl
                            audio = try? AVAudioPlayer(contentsOfURL: url)
                            audio.play()
                        }
                        //シャッフルモードの場合
                    }else if(mode == 2){
                        artistNum = Int(arc4random_uniform(UInt32(artists.count)))
                        songNum = Int(arc4random_uniform(UInt32(artists[artistNum].songs.count)))
                        let url: NSURL = artists[artistNum].songs[songNum].songUrl
                        audio = try? AVAudioPlayer(contentsOfURL: url)
                        audio.play()
                    }
                    musicTitle.text = artists[artistNum].songs[songNum].songTitle
                    musicArtist.text = artists[artistNum].songs[songNum].artistName
                }
            }else if(event?.subtype == UIEventSubtype.RemoteControlPreviousTrack){
                audio.stop()
                if(audio != nil){
                    if(songNum == 0 ){
                        artistNum--
                        songNum = artists[artistNum].songs.count - 1
                        let url: NSURL = artists[artistNum].songs[songNum].songUrl
                        audio = try? AVAudioPlayer(contentsOfURL: url)
                        audio.play()
                    }else{
                        songNum--
                        let url: NSURL = artists[artistNum].songs[songNum].songUrl
                        audio = try? AVAudioPlayer(contentsOfURL: url)
                        audio.play()
                    }
                    musicTitle.text = artists[artistNum].songs[songNum].songTitle
                    musicArtist.text = artists[artistNum].songs[songNum].artistName
                }
            }else{
                print("error")
            }
        }
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyArtist : "\(artists[artistNum].songs[songNum].artistName)",  MPMediaItemPropertyTitle : "\(artists[artistNum].songs[songNum].songTitle)", MPMediaItemPropertyPlaybackDuration: audio.duration, MPNowPlayingInfoPropertyElapsedPlaybackTime: audio.currentTime]
    }

//    func onUpdate(timer : NSTimer){
//        sTime = Int(audio.currentTime)
//        eTime = Int(audio.duration)
//        if(audio != nil){
//            startTime.text = "\(sTime)"
//            endTime.text   = String(audio.duration - audio.currentTime)
//        }
//    }
    
    //backボタンを押した時音楽を止めて前画面に戻る
    @IBAction func pushBackButton(sender: UIBarButtonItem) {
        if(audio.playing == true){
            audio.pause()
        }
        let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier( "target" ) as! UIViewController
        targetViewController.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        self.presentViewController( targetViewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}