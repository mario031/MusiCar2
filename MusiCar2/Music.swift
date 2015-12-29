//
//  MusicDatabase.swift
//  MusiCar
//
//  Created by 石川伶 on 2015/12/29.
//  Copyright © 2015年 石川伶. All rights reserved.
//

import Foundation
import Realm

class Music: RLMObject {
//    dynamic var id:NSNumber!
    dynamic var album = ""
    dynamic var artist = ""
    dynamic var title = ""
    dynamic var country = ""
    dynamic var date = ""
    dynamic var sex = ""
    dynamic var mood = ""
    dynamic var image = ""
//    dynamic var url:NSURL!
    
    override class func primaryKey() -> String? {
        return "title"
    }
    
}

