import UIKit
import MediaPlayer
import AVFoundation
import RealmSwift


class MusicSelectMood: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var artists: [ArtistInfo] = []
    var songQuery: SongQuery = SongQuery()
    var audio: AVAudioPlayer! = nil
    
    var musicTitle:String!
    var musicArtist:String!
    var artistNum:Int!
    var songNum:Int!
    
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
    var goodSongs: [GoodMusic] = []
    var badSongs: [BadMusic] = []
    var itemCount:Int!
    var sectionTitle:String = ""
    
    override func viewDidLoad() {
        
        let realm = try! Realm()
        let goods = realm.objects(Music).filter("mood = 'Excited' OR mood = 'Fiery' OR mood = 'UrgentDefiant' OR mood = 'Aggressive' OR mood = 'Rowdy' OR mood = 'Energizing' OR mood = 'Empowering' OR mood = 'Stirring' OR mood = 'Lively' OR mood = 'Upbeat'")
        
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
        let bads = realm.objects(Music).filter("mood = 'Peaceful' OR mood = 'Romantic' OR mood = 'Sentimental' OR mood = 'Tender' OR mood = 'Easygoing' OR mood = 'Yearning' OR mood = 'Sophisticated' OR mood = 'Sensual' OR mood = 'Cool' OR mood = 'Gritty' OR mood = 'Somber' OR mood = 'Melancholy' OR mood = 'Serious' OR mood = 'Brooding'")
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
    
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyArtist : "\(musicArtist)",  MPMediaItemPropertyTitle : "\(musicTitle)", MPMediaItemPropertyPlaybackDuration: audio.duration, MPNowPlayingInfoPropertyElapsedPlaybackTime: audio.currentTime]
        performSegueWithIdentifier("backMusicController2", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "backMusicController2") {
            let backVC: MusicControllerView = (segue.destinationViewController as? MusicControllerView)!
            
            // 11. SecondViewControllerのtextに選択した文字列を設定する
            backVC.mtitle = musicTitle
            backVC.martist = musicArtist
            backVC.artistNum = artistNum
            backVC.songNum = songNum
            backVC.audio = audio
            
        }
    }
    
    
}