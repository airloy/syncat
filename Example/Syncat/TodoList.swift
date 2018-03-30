//
//  TaskList.swift
//  Syncat_Example
//
//  Created by Layman on 2018/3/29.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import Foundation
import RealmSwift

class TodoList: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var name = ""
    @objc dynamic var createdAt = Date()
    
    let todos = LinkingObjects(fromType: Todo.self, property: "list")
    
    let tags = List<String>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
