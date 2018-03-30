//
//  Task.swift
//  Syncat_Example
//
//  Created by Layman on 2018/3/29.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import Foundation
import RealmSwift

class Todo: Object {
    
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var createdAt = Date()
    @objc dynamic var notes = ""
    @objc dynamic var isCompleted = false
    
    @objc dynamic var list: TodoList?
    
    let attachments = List<Attachment>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
