import UIKit
import MediaPlayer
import AVFoundation
import RealmSwift


class MusicSelectMood: UIViewController, UITableViewDelegate, UITableViewDataSource, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var audio: AVAudioPlayer! = nil
    
    var musicTitle:String!
    var musicArtist:String!    
    
    
    var goodSongs: [GoodMusic] = []
    var badSongs: [BadMusic] = []
    var songQueryMood:SongQueryMood = SongQueryMood()
    
    var itemCount:Int!
    var sectionTitle:String = ""
    
    override func viewDidLoad() {
        goodSongs = songQueryMood.getGood()
        badSongs = songQueryMood.getBad()
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    
    // sectionの数を返す
    func numberOfSectionsInTableView( tableView: UITableView ) -> Int {
        
        return 2
    }
    
    // 各sectionのitem数を返す
    func tableView( tableView: UITableView, numberOfRowsInSection section: Int ) -> Int  {
        if(section == 0){
            itemCount = goodSongs.count
        }else if(section == 1){
            itemCount = badSongs.count
        }
        
        return itemCount
    }
    
    func tableView( tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath ) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell( style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell2" )
        if(indexPath.section == 0){
            cell.textLabel!.text = goodSongs[indexPath.row].songTitle
            cell.detailTextLabel!.text = goodSongs[indexPath.row].artistName
        }else if(indexPath.section == 1){
            cell.textLabel!.text = badSongs[indexPath.row].songTitle
            cell.detailTextLabel!.text = badSongs[indexPath.row].artistName
        }
        
        
        return cell;
    }
    
    // sectionのタイトル
    func tableView( tableView: UITableView, titleForHeaderInSection section: Int ) -> String? {
        if(section == 0){
            sectionTitle = "Fun Songs"
        }else if(section == 1){
            sectionTitle = "Calm Songs"
        }
        return sectionTitle
    }
    
    // 選択した音楽を再生
    func tableView( tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath ) {
        
        if audio.playing{
            audio.stop()
        }
        // soundIdからMediaItemを取得
        //        let songId: NSNumber = artists[indexPath.section].songs[indexPath.row].songId
        //        let item: MPMediaItem = songQuery.getItem( songId )
        //
        //        let url: NSURL = item.valueForProperty( MPMediaItemPropertyAssetURL ) as! NSURL
        if(indexPath.section == 0){
            let url: NSURL = NSURL(string: "\(goodSongs[indexPath.row].songUrl)")!
            // 再生
            audio = try! AVAudioPlayer(contentsOfURL: url)
            audio.play()
            musicTitle = goodSongs[indexPath.row].songTitle
            musicArtist = goodSongs[indexPath.row].artistName
        }else if(indexPath.section == 1){
            let url: NSURL = NSURL(string: "\(badSongs[indexPath.row].songUrl)")!
            // 再生
            audio = try! AVAudioPlayer(contentsOfURL: url)
            audio.play()
            musicTitle = badSongs[indexPath.row].songTitle
            musicArtist = badSongs[indexPath.row].artistName
        }
    
        let realm = try! Realm()
        let images = realm.objects(Music).filter("title = '\(musicTitle)'")
        for image in images{
            if(image.image != ""){
                let url1 = NSURL(string: "\(image.image)")
                let imageData :NSData = try! NSData(contentsOfURL: url1!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                let image: UIImage = UIImage(data:imageData)!
                let artwork = MPMediaItemArtwork(image: image)
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyArtist : "\(musicArtist)",  MPMediaItemPropertyTitle : "\(musicTitle)", MPMediaItemPropertyArtwork: artwork ,MPMediaItemPropertyPlaybackDuration: audio.duration, MPNowPlayingInfoPropertyElapsedPlaybackTime: audio.currentTime]
            }else{
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyArtist : "\(musicArtist)",  MPMediaItemPropertyTitle : "\(musicTitle)", MPMediaItemPropertyPlaybackDuration: audio.duration, MPNowPlayingInfoPropertyElapsedPlaybackTime: audio.currentTime]
            }
        }
        performSegueWithIdentifier("backMusicController2", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "backMusicController2") {
            let backVC: MusicControllerView = (segue.destinationViewController as? MusicControllerView)!
            
            // 11. SecondViewControllerのtextに選択した文字列を設定する
            backVC.mtitle = musicTitle
            backVC.martist = musicArtist
            backVC.audio = audio
            
        }
    }
    
    
}