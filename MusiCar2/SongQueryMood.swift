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

class SongQueryMood {
    
    // iPhoneに入ってる曲を全部返す
    func getGood() -> [GoodMusic] {
        
        var goodSongs: [GoodMusic] = []
        
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
        
        return goodSongs
        
    }
    // iPhoneに入ってる曲を全部返す
    func getBad() -> [BadMusic] {
        
        var badSongs: [BadMusic] = []
        
        let realm = try! Realm()
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
        
        return badSongs
        
    }    
    
}