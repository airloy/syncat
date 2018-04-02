//
//  RealmObjectObserver.swift
//  Pods-Syncat_Example
//
//  Created by Layman on 2018/3/30.
//

import Foundation
import RealmSwift

class RealmObjectObserver {
    
    let targetRealm: Realm
    let helperRealm: Realm
    var notificationToken: NotificationToken? = nil
    var trackDeletion: Bool = false
    
    init(_ realmTracker: RealmTracker, _ objectType: Object.Type, trackDeletion toTrackDeletion: Bool) {
        targetRealm = realmTracker.targetRealm
        helperRealm = realmTracker.helperRealm
        trackDeletion = toTrackDeletion
        notificationToken = targetRealm.objects(objectType).observe {[unowned self] changes in
            switch changes {
            case .initial:
                print("Observe \(objectType) changes")
            case .update(let results, let deletions, let insertions, let modifications):
                self.helperRealm.beginWrite()
                var fullInsertions = insertions
                // Stats deletion info
                if self.trackDeletion {
                    for _ in deletions {
                        let deletedStats = self.deletedStatsEntity(ofObjectType: objectType)
                        deletedStats.count = deletedStats.count + 1
                        print("Delete object [\(objectType)]")
                    }
                }
                // Track modification
                for index in modifications {
                    if let trackingEntity = self.trackingEntity(forObject: results[index]) {
                        trackingEntity.changeOperation = .update
                        print("Update object [\(trackingEntity.objectType)] id [\(trackingEntity.objectID)]")
                    } else {
                        // Can't find tracking info, try to add
                        fullInsertions.append(index)
                    }
                }
                // Track insertion
                for index in fullInsertions {
                    if let trackingEntity = self.createTrackingEntity(forObject: results[index]) {
                        self.helperRealm.add(trackingEntity)
                        print("Add tracking entity for object: \(trackingEntity.objectType)] id [\(trackingEntity.objectID)]")
                    }
                }
                try? self.helperRealm.commitWrite()
            case .error(let error):
                print("\(error)")
            }
        }
    }
    
    func deletedStatsEntity(ofObjectType objectType: Object.Type) -> SCDeletedStatsEntity {
        let typeName = objectType.typeName
        if let deletedStatsEntity = helperRealm.objects(SCDeletedStatsEntity.self).filter("objectType == %@", typeName).first {
            return deletedStatsEntity
        } else {
            let deletedStatsEntity = SCDeletedStatsEntity()
            deletedStatsEntity.objectType = typeName
            helperRealm.add(deletedStatsEntity)
            return deletedStatsEntity
        }
    }
    
    func trackingEntity(forObject object: Object) -> SCTrackingEntity? {
        guard let primaryKey = object.primaryKey else {
            return nil
        }
        let stringID = object.primaryValue(forKey: primaryKey)
        let trackingEntity = helperRealm.objects(SCTrackingEntity.self).filter("objectID == %@ AND objectType == %@", stringID, object.typeName).first
        return trackingEntity
    }
    
    func createTrackingEntity(forObject object: Object) -> SCTrackingEntity? {
        print("Create tracking entity for object: \(object)")
        guard let primaryKey = object.primaryKey else {
            return nil
        }
        let trackingEntity = SCTrackingEntity()
        trackingEntity.changeOperation = .insert
        trackingEntity.objectID = object.primaryValue(forKey: primaryKey)
        trackingEntity.objectType = object.typeName
        return trackingEntity
    }
    
    func updateTrackingEntity(forObject object: Object, withOperation oper: SCTrackingEntity.ChangeOperation) -> SCTrackingEntity?{
        if let entity = trackingEntity(forObject: object) {
            entity.changeOperation = oper
            return entity
        } else {
            let newEntity = createTrackingEntity(forObject: object)
            newEntity?.changeOperation = oper
            return newEntity
        }
    }
    
    deinit {
        print("Remove realm object observer")
        notificationToken?.invalidate()
    }
}
