//
//  City.swift
//  gb_ui
//
//  Created by Margarita Novokhatskaia on 24.05.2021.
//

import Foundation
import RealmSwift

class City: Object, Decodable {
    @objc dynamic var title = ""
    
    override static func primaryKey() -> String? {
        return "title"
    }
}
