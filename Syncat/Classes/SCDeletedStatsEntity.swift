//
//  SCDeletedStatsEntity.swift
//  Pods-Syncat_Example
//
//  Created by Layman on 2018/3/30.
//

import Foundation
import RealmSwift

public class SCDeletedStatsEntity: Object {
    
    @objc dynamic public var statsID = UUID().uuidString
    @objc dynamic public var objectType: String = ""
    @objc dynamic public var count: Int = 0
    
    override public static func primaryKey() -> String? {
        return "statsID"
    }
}
