import Foundation
import MediaPlayer

// 曲情報
struct SongInfo {
    var albumTitle: String
    var artistName: String
    var songTitle:  String
    var songUrl:NSURL
    
    // UInt64だとうまくいかなかった。バグ？
    var songId   :  NSNumber
}

struct ArtistInfo{
    var artistName: String
    var songs:[SongInfo]
}

class SongQuery {
    
    // iPhoneに入ってる曲を全部返す
    func get() -> [ArtistInfo] {
        
        var artists: [ArtistInfo] = []
        
        // アーティスト情報から曲を取り出す
        let artistQuery: MPMediaQuery = MPMediaQuery.artistsQuery()
        let artistItems: [MPMediaItemCollection] = artistQuery.collections! as [MPMediaItemCollection]
        var artist: MPMediaItemCollection
        
        for artist in artistItems {
            
            let artistItems: [MPMediaItem] = artist.items as [MPMediaItem]
            var _: MPMediaItem
            
            var songs: [SongInfo] = []
            
            var artistName: String = ""
            
            for song in artistItems {
                
                artistName = song.valueForProperty( MPMediaItemPropertyArtist ) as! String
                let songInfo: SongInfo = SongInfo(
                    albumTitle: song.valueForProperty( MPMediaItemPropertyAlbumTitle ) as! String,
                    artistName: song.valueForProperty( MPMediaItemPropertyArtist )as! String,
                    songTitle:  song.valueForProperty( MPMediaItemPropertyTitle )as! String,
                    songUrl:    song.valueForProperty( MPMediaItemPropertyAssetURL)as! NSURL,
                    songId:     song.valueForProperty( MPMediaItemPropertyPersistentID ) as! NSNumber
                )
                
                songs.append(songInfo)
            }
            
            let artistInfo: ArtistInfo = ArtistInfo(
                
                artistName: artistName,
                songs: songs
            )
            
            artists.append(artistInfo)
        }
        
        return artists
        
    }
    
    // songIdからMediaItemを取り出す
    func getItem( songId: NSNumber ) -> MPMediaItem {
        
        let property: MPMediaPropertyPredicate = MPMediaPropertyPredicate( value: songId, forProperty: MPMediaItemPropertyPersistentID )
        
        let query: MPMediaQuery = MPMediaQuery()
        query.addFilterPredicate( property )
        
        var items: [MPMediaItem] = query.items! as [MPMediaItem]
        
        return items[items.count - 1]
        
    }
    
    
}