//
//  Object+Syncat.swift
//  Pods-Syncat_Example
//
//  Created by Layman on 2018/3/30.
//

import Foundation
import RealmSwift

extension Object {
    
    func primaryValue(forKey key: String) -> String {
        if let stringID = value(forKey: key) as? String {
            return stringID
        } else if let intID = value(forKey: key) as? Int{
            return "syncat-int:\(intID)"
        } else {
            fatalError("Not a primary key")
        }
    }
    
    var primaryKey: String? {
        get {
            guard let primaryKey = self.objectSchema.primaryKeyProperty?.name else {
                return nil
            }
            return primaryKey
        }
    }
    
    var typeName: String {
        get {
            return objectSchema.className
        }
    }
    
    static var typeName: String {
        get {
            if let schema = self.sharedSchema() {
                return schema.className
            } else {
                return NSStringFromClass(self)
            }
        }
    }
    
    public static func type(forName name: String) -> Object.Type? {
        return objectType(forName: name)
    }
}

extension Realm {
    
    public func object(forTrackingEntity entity: SCTrackingEntity) -> Object? {
        guard let type = objectType(forName: entity.objectType) else {
            return nil
        }
        if entity.objectID.starts(with: "syncat-int:") {
            let intId = Int(substring(entity.objectID, offset: 11))
            return object(ofType: type, forPrimaryKey: intId)
        } else {
            return object(ofType: type, forPrimaryKey: entity.objectID)
        }
    }
}
