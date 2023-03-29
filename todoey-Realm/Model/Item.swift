//
//  Item.swift
//  todoey-Realm
//
//  Created by Artur Imanbaev on 24.03.2023.
//

import Foundation
import RealmSwift

class Item: Object{
    @objc dynamic var title: String = ""
    @objc dynamic var dateCreated = 0.0
    @objc dynamic var done: Bool = false
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
