//
//  MusicDatabase.swift
//  MusiCar
//
//  Created by 石川伶 on 2015/12/29.
//  Copyright © 2015年 石川伶. All rights reserved.
//

import Foundation
import RealmSwift

class Music: Object {
    dynamic var title = ""
    dynamic var id = 0
    dynamic var album = ""
    dynamic var artist = ""
    dynamic var country = ""
    dynamic var date = ""
    dynamic var sex = ""
    dynamic var mood = ""
    dynamic var image = ""
    dynamic var url = ""
    
    override static func primaryKey() -> String? {
        return "title"
    }
}

