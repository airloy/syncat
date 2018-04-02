//
//  RealmTracker.swift
//  Pods-Syncat_Example
//
//  Created by Layman on 2018/3/30.
//

import Foundation
import RealmSwift

public class RealmTracker {
    
    // DB to be synced
    let targetRealm: Realm
    // DB to save tracking info
    let helperRealm: Realm
    
    var observers = [String: RealmObjectObserver?]()
    
    
    public init(_ realm: Realm, _ tracker: Realm? = nil) {
        targetRealm = realm
        if let tracker = tracker {
            helperRealm = tracker
        } else {
            helperRealm = realm
        }
    }
    
    deinit {
        print("deinit tracker, removing observers ... ")
        observers.removeAll()
    }
    
    public func register(_ objectTypes: [Object.Type]? = nil) {
        if let types = objectTypes {
            types.forEach { type in
                register(type)
            }
        } else {
            // register all current record type
            targetRealm.schema.objectSchema.forEach { objectSchema in
                let typeName = objectSchema.className
                print("Auto register for type: \(typeName)")
//                guard typeName != "PermissionUser" &&
//                    typeName != "PermissionRole" &&
//                    typeName != "Permission" &&
//                    typeName != "ClassPermission" &&
//                    typeName != "RealmPermission" &&
//                    !typeName.starts(with: "RLM") &&
//                    typeName != "SCRegisterEntity" &&
//                    typeName != "SCTrackingEntity" &&
//                    typeName != "SCDeletedStatsEntity" else {return}
                if let type = objectType(forName: typeName) {
                    register(type)
                } else {
                    print("Register skip object: \(typeName)")
                }
            }
        }
    }
    
    public func register(_ objectType: Object.Type, forceFullScan trackDeep: Bool = false, trackDeletion: Bool = false) {
        guard objectType != SCRegisterEntity.self &&
            objectType != SCTrackingEntity.self &&
            objectType != SCDeletedStatsEntity.self else {
            return
        }
        var toScan = false
        let typeName = objectType.typeName
        if helperRealm.objects(SCRegisterEntity.self).filter("objectType == %@", typeName).count == 0 {
            let registerEntity = SCRegisterEntity()
            registerEntity.objectType = typeName
            try? helperRealm.write {
                helperRealm.add(registerEntity)
            }
            toScan = true
        } else {
            toScan = trackDeep
        }
        // Scan and track all objects if necessary
        // Only support object with primary key
        if toScan, let primaryKey = objectType.primaryKey() {
            let builtIDs = Array(helperRealm.objects(SCTrackingEntity.self).filter("objectType == %@", typeName).map { $0.objectID })
            // TODO TEST INT primary key
            let newObjects = targetRealm.objects(objectType.self).filter("NOT \(primaryKey) IN %@", builtIDs)
            helperRealm.beginWrite()
            newObjects.forEach { object in
                let trackingEntity = SCTrackingEntity()
                trackingEntity.changeOperation = .insert
                trackingEntity.objectID = object.primaryValue(forKey: primaryKey)
                trackingEntity.objectType = typeName
                helperRealm.add(trackingEntity)
            }
            try? helperRealm.commitWrite()
        }
        // Subscribe to object collection
        if observers.keys.contains(typeName) {
            observers[typeName] = nil
        }
        observers[typeName] = RealmObjectObserver(self, objectType, trackDeletion: trackDeletion)
    }
    
    public func retire(_ recordType: Object.Type, cleanAll force: Bool = false) {
        // TODO
    }
    
    
    public func remove(object: Object) {
        if let observer = observers[object.objectSchema.className],
            let trackingInfo = observer?.updateTrackingEntity(forObject: object, withOperation: .delete) {
            helperRealm.add(trackingInfo, update: true)
        }
    }
    
    public func remove<S: Sequence>(objects: S) where S.Iterator.Element: Object{
        for object in objects {
            remove(object: object)
        }
    }
}

