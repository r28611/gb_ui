//
//  Photo.swift
//  gb_ui
//
//  Created by Margarita Novokhatskaia on 19.02.2021.
//

import Foundation
import RealmSwift

class Photo: Object, Decodable {
    @objc dynamic var id: Int = 0
    @objc dynamic var ownerId: Int = 0
    var sizes = List<Size>()
    @objc dynamic var likes: Like? = Like()
    @objc dynamic var isLiked: Bool { return self.likes?.isLiked == 1 }
    
    enum CodingKeys: String, CodingKey {
        case id
        case ownerId = "owner_id"
        case sizes
        case likes
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
