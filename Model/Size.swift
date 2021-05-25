//
//  Size.swift
//  gb_ui
//
//  Created by Margarita Novokhatskaia on 24.05.2021.
//

import RealmSwift

class Size: Object, Decodable {
    @objc dynamic var height: Int = 0
    @objc dynamic var width: Int = 0
    @objc dynamic var url: String = ""
}
