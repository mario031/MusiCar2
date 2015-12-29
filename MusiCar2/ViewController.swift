

import UIKit
import AVFoundation
import Realm

class ViewController: UIViewController,NSXMLParserDelegate{
    
    @IBOutlet weak var musiCar: UILabel!
    
    //xmlパース
    var isArtist:Bool = false
    var isTitle:Bool = false
    var isMood:Bool = false
    var isUrl:Bool = false
    var isCountry:Bool = false
    var isSex:Bool = false
    var isDate:Bool = false
    var xmlTag:String! = ""
    var type:String! = ""
    
    //xmlにぶちこむデータ
    var album:String = ""
    var artist:String = ""
    var name:String = ""
    
    //音楽取得
    var artists: [ArtistInfo] = []
    var songQuery: SongQuery = SongQuery()
    
    //realmにぶちこむ
    var country:String = ""
    var date:String = ""
    var sex:String = ""
    var mood:String = ""
    var image:String = ""
    var ngo:String = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        musiCar.font = UIFont(name: "Helvetica-BoldOblique", size:60)
        
        artists = songQuery.get()
        
        for(var i:Int = 0;i < artists.count;i++){
            for(var n:Int = 0;n < artists[i].songs.count;n++){
                
                artist = artists[i].songs[n].artistName
                album = artists[i].songs[n].albumTitle
                name = artists[i].songs[n].songTitle
                
                let realm  = RLMRealm.defaultRealm()
                let music:Music = Music()
                music.artist = artist
                music.album = album
                music.title = name
                //                music.id = 10
                //                music.url = artists[0].songs[0].songUrl
                realm.beginWriteTransaction()
                realm.addObject(music)
                try! realm.commitWriteTransaction()
                
                let str = "<QUERIES><AUTH><CLIENT>8760576-35C7285E7ECF1188D37D0D1A197FB2C3</CLIENT><USER>280444153869047731-F7A5B36A03AE2212ED530D68033AF62F</USER></AUTH><QUERY CMD='ALBUM_SEARCH'><MODE>SINGLE_BEST_COVER</MODE><TEXT TYPE='ARTIST'>\(artist)</TEXT><TEXT TYPE='ALBUM_TITLE'>\(album)</TEXT><TEXT TYPE='TRACK_TITLE'>\(name)</TEXT><OPTION><PARAMETER>SELECT_EXTENDED</PARAMETER><VALUE>ARTIST_IMAGE,ARTIST_OET,MOOD</VALUE></OPTION><OPTION><PARAMETER>SELECT_DETAIL</PARAMETER><VALUE>MOOD:1LEVEL,ARTIST_ORIGIN:2LEVEL,ARTIST_TYPE:1LEVEL</VALUE></OPTION></QUERY></QUERIES>"
                
                let xmlData = str.dataUsingEncoding(NSUTF8StringEncoding)
                
                //URLの指定
                let url: NSURL! = NSURL(string: "https://c8760576.web.cddbp.net/webapi/xml/1.0/")
                let request = NSMutableURLRequest(URL: url)
                
                //XMLヘッダーの指定
                request.setValue("application/xml", forHTTPHeaderField: "Content-type")
                
                //POSTを指定
                request.HTTPMethod = "POST"
                //Dataをセット
                request.HTTPBody = xmlData
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: getHttp)
            }
        }
        
    }
    //レスポンスが帰ってきたら行う関数
    func getHttp(res:NSURLResponse?,data:NSData?,error:NSError?){
        //        if data != nil{
        //            let dataString = NSString(data:data!, encoding:NSUTF8StringEncoding) as! String
        //            print(dataString)
        //        }
        //XMLに変換
        let parser : NSXMLParser? = NSXMLParser(data: data!)
        if parser != nil {
            parser!.delegate = self
            parser!.parse()
        } else {
            // パースに失敗した時
            print("failed to parse XML")
        }
    }
    //取得したXMLをエレメント毎に取得
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        //        print(elementName)
        if(elementName == "TRACK"){
            xmlTag = "TRACK"
        }
        
        if(elementName == "ARTIST"){
            isArtist = true
        }else if(elementName == "ARTIST_ORIGIN"){
            isCountry = true
        }else if(elementName == "ARTIST_TYPE"){
            isSex = true
        }else if(elementName == "TITLE"){
            isTitle = true
        }else if(elementName == "DATE"){
            isDate = true
        }else if(elementName == "MOOD"){
            isMood = true
        }else if(elementName == "URL"){
            isUrl = true
            type = attributeDict["TYPE"]! as String
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if(elementName == "TRACK"){
            xmlTag = ""
        }
        if(elementName == "ARTIST"){
            isArtist = false
        }else if(elementName == "ARTIST_ORIGIN"){
            isCountry = false
        }else if(elementName == "ARTIST_TYPE"){
            isSex = false
        }else if(elementName == "TITLE"){
            isTitle = false
        }else if(elementName == "DATE"){
            isDate = false
        }else if(elementName == "MOOD"){
            isMood = false
        }else if(elementName == "URL"){
            isUrl = false
            type = ""
        }
    }
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        if(isArtist){
            //            music.artist = string
//            print("\nアーティスト=\(string)")
        }else if(isTitle && xmlTag != "TRACK"){
            //            music.album = string
//            print("アルバム=\(string)")
        }else if(isTitle && xmlTag == "TRACK"){
            //            music.title = string
            ngo = string
//            print("タイトル=\(string)")
        }else if(isCountry){
            country = string
//            print("国=\(string)")
        }else if(isSex){
            sex = string
//            print("性別=\(string)")
        }else if(isDate){
            date = string
//            print("発売日=\(string)")
        }else if(isMood){
            mood = string
//            print("ムード=\(string)")
        }else if(isUrl && type == "COVERART"){
            image = string
//            print("url=\(string)")
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        
//        let music = Music()
//        music.country = country
//        music.sex = sex
//        music.date = date
//        music.mood = mood
//        music.image = image
//        music.title = ngo
//        
//        let realm = RLMRealm.defaultRealm()
//        realm.beginWriteTransaction()
//        realm.addOrUpdateObject(music)
//        try! realm.commitWriteTransaction()
//        country = ""
//        date = ""
//        sex = ""
//        mood = ""
//        image = ""
//        ngo = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}




