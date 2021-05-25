//
//  Like.swift
//  gb_ui
//
//  Created by Margarita Novokhatskaia on 24.05.2021.
//

import RealmSwift

class Like: Object, Decodable {
    @objc dynamic var isLiked: Int = 0
    @objc dynamic var count: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case isLiked = "user_likes"
        case count
    }
}
