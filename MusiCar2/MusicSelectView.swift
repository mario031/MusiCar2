import UIKit
import MediaPlayer
import AVFoundation

class MusicSelectView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var navigationItemLabel:UINavigationItem!
    
    var artists: [ArtistInfo] = []
    var songQuery: SongQuery = SongQuery()
    var audio: AVAudioPlayer! = nil
    
    var musicTitle:String!
    var musicArtist:String!
    var artistNum:Int!
    var songNum:Int!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        artists = songQuery.get()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    
    // sectionの数を返す
    func numberOfSectionsInTableView( tableView: UITableView ) -> Int {
        
        return artists.count
    }
    
    // 各sectionのitem数を返す
    func tableView( tableView: UITableView, numberOfRowsInSection section: Int ) -> Int  {
        
        return artists[section].songs.count
    }
    
    func tableView( tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath ) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell( style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell" )
        
        cell.textLabel!.text = artists[indexPath.section].songs[indexPath.row].songTitle
        cell.detailTextLabel!.text = artists[indexPath.section].songs[indexPath.row].albumTitle
        
        return cell;
    }
    
    // sectionのタイトル
    func tableView( tableView: UITableView, titleForHeaderInSection section: Int ) -> String? {
        
        return artists[section].artistName
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
        
        let url: NSURL = artists[indexPath.section].songs[indexPath.row].songUrl
        
        // 再生
        audio = try! AVAudioPlayer(contentsOfURL: url)
        audio.play()
        
        musicTitle = artists[indexPath.section].songs[indexPath.row].songTitle
        musicArtist = artists[indexPath.section].songs[indexPath.row].artistName
        artistNum = indexPath.section
        songNum = indexPath.row
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyArtist : "\(artists[artistNum].songs[songNum].artistName)",  MPMediaItemPropertyTitle : "\(artists[artistNum].songs[songNum].songTitle)", MPMediaItemPropertyPlaybackDuration: audio.duration, MPNowPlayingInfoPropertyElapsedPlaybackTime: audio.currentTime]
        performSegueWithIdentifier("backMusicController", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "backMusicController") {
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