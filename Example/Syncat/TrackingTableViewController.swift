//
//  TrackingTableViewController.swift
//  Syncat_Example
//
//  Created by Layman on 2018/3/29.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import Syncat
import RealmSwift

class TrackingTableViewController: UITableViewController {

    var entities: Results<SCTrackingEntity>!
    var notificationToken: NotificationToken? = nil
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Tracking Entities"
        entities = syncatRealm?.objects(SCTrackingEntity.self)
        notificationToken = entities?.observe {[weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                print("init")
            case .update:
                // Query results have changed, so apply them to the UITableView
                tableView.reloadData()
            case .error(let error):
                print("\(error)")
            }
        }
    }

    @IBAction func toRemoveAll(_ sender: Any) {
        try? syncatRealm?.write {
            syncatRealm?.delete(entities)
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entities?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = entities?[indexPath.row].objectType
        cell.detailTextLabel?.text = "\(String(describing: entities?[indexPath.row].changeOperation))"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print
        guard let entity = entities?[indexPath.row],
            let object = realm.object(forTrackingEntity: entity) else {
            return
        }
        print("tracking info:\n\(entity)\nand object:\n\(object)")
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath) -> Void in
            //Deletion will go here
            guard let entityToBeDeleted = self.entities?[indexPath.row] else {return}
            syncatRealm?.beginWrite()
            syncatRealm?.delete(entityToBeDeleted)
            try? syncatRealm?.commitWrite(withoutNotifying: [self.notificationToken!])
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        return [deleteAction]
    }
}
