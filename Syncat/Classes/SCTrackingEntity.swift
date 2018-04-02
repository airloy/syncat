//
//  SCTrackingEntity.swift
//  Pods-Syncat_Example
//
//  Created by Layman on 2018/3/30.
//

import Foundation
import RealmSwift

public class SCTrackingEntity: Object {
    
    @objc dynamic public var trackID = UUID().uuidString
    @objc dynamic public var objectType: String = ""
    @objc dynamic public var objectID: String = ""
    @objc dynamic public var changeOperation: ChangeOperation = .noop
    @objc dynamic public var changeTag = "0"
    @objc dynamic public var cloudRecordID: String?
    @objc dynamic public var cloudRecordMetadata: Data?
    
    @objc public enum ChangeOperation: Int {
        case insert = 1
        case update = 2
        case delete = 3
        case uploading = 8
        case noop = 9
    }
    
    override public static func primaryKey() -> String? {
        return "trackID"
    }
}
