//
//  Attachment.swift
//  Syncat_Example
//
//  Created by Layman on 2018/3/29.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import Foundation
import RealmSwift

class Attachment: Object {
    
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var createdAt = Date()
    @objc dynamic var data: Data?
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
