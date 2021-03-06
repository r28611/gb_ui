//
//  Group.swift
//  gb_ui
//
//  Created by Margarita Novokhatskaia on 04.01.2021.
//

import UIKit
import RealmSwift

class Group: Object, Decodable {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var isMember: Int = 0
    @objc dynamic var avatarURL: String = Constants.vkNonexistentGroupPhotoURL
    
    var members: Int {
        get { return membersCount.value ?? 0 }
        set(newValue) { self.membersCount.value = newValue }
    }
    var membersCount = RealmOptional<Int>()
    
    override init() {}
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        isMember = try container.decode(Int.self, forKey: .isMember)
        if let members = try? container.decode(Int.self, forKey: .members) {
            self.members = members
        }
        avatarURL = try container.decode(String.self, forKey: .avatarURL)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case isMember = "is_member"
        case avatarURL = "photo_100"
        case members = "members_count"
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
