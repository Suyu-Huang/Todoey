//
//  Item.swift
//  Todoey
//
//  Created by 黄苏渝 on 2019/2/4.
//  Copyright © 2019 suyu. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated:Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
