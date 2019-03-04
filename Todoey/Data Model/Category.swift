//
//  Category.swift
//  Todoey
//
//  Created by 黄苏渝 on 2019/2/4.
//  Copyright © 2019 suyu. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>()
}
