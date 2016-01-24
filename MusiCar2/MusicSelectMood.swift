import UIKit
import MediaPlayer
import AVFoundation
import RealmSwift

//盛り上がる曲たち
struct GoodMusic {
    var albumTitle: String
    var artistName: String
    var songTitle:  String
    var songUrl:String
    
    // UInt64だとうまくいかなかった。バグ？
    var songId   :  NSNumber
}
//落ち着いた曲たち
struct BadMusic {
    var albumTitle: String
    var artistName: String
    var songTitle:  String
    var songUrl:String
    
    // UInt64だとうまくいかなかった。バグ？
    var songId   :  NSNumber
}

class MusicSelectMood: UIViewController, UITableViewDelegate, UITableViewDataSource, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var audio: AVAudioPlayer! = nil
    
    var musicTitle:String!
    var musicArtist:String!
    var artistNum:Int!
    var songNum:Int!
    
    
    
    var goodSongs: [GoodMusic] = []
    var badSongs: [BadMusic] = []
    var itemCount:Int!
    var sectionTitle:String = ""
    
    override func viewDidLoad() {
        
        let realm = try! Realm()
        let goods = realm.objects(Music).filter("mood = 'Excited' && id != 0 OR mood = 'Fiery' && id != 0 OR mood = 'UrgentDefiant' && id != 0 OR mood = 'Aggressive' && id != 0 OR mood = 'Rowdy' && id != 0 OR mood = 'Energizing' && id != 0 OR mood = 'Stirring' && id != 0 OR mood = 'Lively' && id != 0 OR mood = 'Upbeat' && id != 0 ")
        
        for good in goods{
            let goodMusic: GoodMusic = GoodMusic(
                albumTitle: good.album,
                artistName: good.artist,
                songTitle:  good.title,
                songUrl:    good.url,
                songId:     good.id
            )
            goodSongs.append(goodMusic)
        }
        let bads = realm.objects(Music).filter("mood = 'Peaceful' && id != 0 OR mood = 'Romantic' && id != 0 OR mood = 'Empowering' && id != 0 OR mood = 'Sentimental' && id != 0 OR mood = 'Tender' && id != 0 OR mood = 'Easygoing' && id != 0 OR mood = 'Yearning' && id != 0 OR mood = 'Sophisticated' && id != 0 OR mood = 'Sensual' && id != 0 OR mood = 'Cool' && id != 0 OR mood = 'Gritty' && id != 0 OR mood = 'Somber' && id != 0 OR mood = 'Melancholy' && id != 0 OR mood = 'Serious' && id != 0 OR mood = 'Brooding' AND id != 0 ")
        for bad in bads{
            let badMusic: BadMusic = BadMusic(
                albumTitle: bad.album,
                artistName: bad.artist,
                songTitle:  bad.title,
                songUrl:    bad.url,
                songId:     bad.id
            )
            badSongs.append(badMusic)
        }
        
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
            artistNum = 0
            songNum = indexPath.row
        }else if(indexPath.section == 1){
            let url: NSURL = NSURL(string: "\(badSongs[indexPath.row].songUrl)")!
            // 再生
            audio = try! AVAudioPlayer(contentsOfURL: url)
            audio.play()
            musicTitle = badSongs[indexPath.row].songTitle
            musicArtist = badSongs[indexPath.row].artistName
            artistNum = 1
            songNum = indexPath.row
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
            backVC.goodNum = artistNum
            backVC.badNum = songNum
            backVC.audio = audio
            
        }
    }
    
    
}