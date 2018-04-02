//
//  SCRegisterEntity.swift
//  Pods-Syncat_Example
//
//  Created by Layman on 2018/3/30.
//

import Foundation
import RealmSwift

public class SCRegisterEntity: Object {
    
    @objc dynamic public var registerID = UUID().uuidString
    @objc dynamic public var objectType: String = ""
    
    override public static func primaryKey() -> String? {
        return "registerID"
    }
}
