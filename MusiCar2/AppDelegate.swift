//
//  AppDelegate.swift
//  MusiCar2
//
//  Created by 石川伶 on 2015/12/29.
//  Copyright © 2015年 石川伶. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,NSXMLParserDelegate {

    var window: UIWindow?
    
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
    var id:Int = 0
    var uri:String = ""
    
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


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        /// バックグラウンドでも再生できるand Bluetooth対応カテゴリに設定する
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
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
//        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
        
        let config = Realm.Configuration(
            // 新しいスキーマバージョンを設定します。以前のバージョンより大きくなければなりません。
            // （スキーマバージョンを設定したことがなければ、最初は0が設定されています）
            schemaVersion: 3,
            
            // マイグレーション処理を記述します。古いスキーマバージョンのRealmを開こうとすると
            // 自動的にマイグレーションが実行されます。
            migrationBlock: { migration, oldSchemaVersion in
                // 最初のマイグレーションの場合、`oldSchemaVersion`は0です
                if (oldSchemaVersion < 3) {
                    // 何もする必要はありません！
                    // Realmは自動的に新しく追加されたプロパティと、削除されたプロパティを認識します。
                    // そしてディスク上のスキーマを自動的にアップデートします。
                }
        })
        
        // デフォルトRealmに新しい設定を適用します
        Realm.Configuration.defaultConfiguration = config
        
        // Realmファイルを開こうとしたときスキーマバージョンが異なれば、
        // 自動的にマイグレーションが実行されます
        
        //dataを全部削除
        let realm = try! Realm()
        try! realm.write{
            realm.deleteAll()
        }
        
        artists = songQuery.get()
        
        for(var i:Int = 0;i < artists.count;i++){
            for(var n:Int = 0;n < artists[i].songs.count;n++){
                
                artist = artists[i].songs[n].artistName
                album = artists[i].songs[n].albumTitle
                name = artists[i].songs[n].songTitle
                id = artists[i].songs[n].songId as Int
                uri = String(artists[i].songs[n].songUrl)
                
                let music:Music = Music()
                music.title = name
                music.artist = artist
                music.album = album
                music.id = id
                music.url = uri
                let realm = try! Realm()
                try! realm.write {
                    realm.add(music, update: true)
                }
                
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
        return true
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
        
        let realm = try! Realm()
        try! realm.write {
            realm.create(Music.self, value: ["title":ngo,"country": country, "sex": sex,"date": date, "mood":mood,"image":image], update: true)
        }
        country = ""
        date = ""
        sex = ""
        mood = ""
        image = ""
        ngo = ""
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

