//
//  User.swift
//  gb_ui
//
//  Created by Margarita Novokhatskaia on 25.02.2021.
//

import Foundation
import RealmSwift

class User: Object, Decodable {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var surname = ""
    @objc dynamic var city: City? = City()
    @objc dynamic var avatarURL = Constants.vkNonexistentPhotoURL
    
    @objc dynamic private var status = 0
    var isOnline: Bool { return self.status == 1 }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "first_name"
        case surname = "last_name"
        case city
        case avatarURL = "photo_100"
        case status = "online"
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
            return ["name", "surname"]
    }

}
