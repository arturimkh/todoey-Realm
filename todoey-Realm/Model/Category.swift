//
//  Category.swift
//  todoey-Realm
//
//  Created by Artur Imanbaev on 24.03.2023.
//

import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>()
}
