//
//  TodoListTableViewController.swift
//  Syncat_Example
//
//  Created by Layman on 2018/3/29.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListTableViewController: UITableViewController {

    var currentCreateAction: UIAlertAction?
    
    let realm = try! Realm()
    var lists: Results<TodoList>!
    var notificationToken: NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Todo Lists"
        self.clearsSelectionOnViewWillAppear = true
        
        lists = realm.objects(TodoList.self)
        notificationToken = lists.observe {[weak self] (changes: RealmCollectionChange) in
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

    @IBAction func addList(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New List", message: "Write the name of your list.", preferredStyle: UIAlertController.Style.alert)
        
        let createAction = UIAlertAction(title: "Create", style: UIAlertAction.Style.default) { (action) -> Void in
            if let taskName = alertController.textFields?.first?.text {
                let newList = TodoList()
                newList.id = self.lists.count
                newList.name = taskName
                try? self.realm.write{
                    self.realm.add(newList)
                }
            }
        }
        
        alertController.addAction(createAction)
        createAction.isEnabled = false
        self.currentCreateAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "List Name"
            textField.addTarget(self, action: #selector(self.taskNameFieldDidChange) , for: UIControl.Event.editingChanged)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func taskNameFieldDidChange(_ textField:UITextField) {
        if let text = textField.text {
            self.currentCreateAction?.isEnabled = !text.isEmpty
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = lists[indexPath.row].name
        cell.detailTextLabel?.text = "\(lists[indexPath.row].todos.count)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TodoTableViewController") as! TodoTableViewController
        vc.list = lists[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath) -> Void in
            //Deletion will go here
            let listToBeDeleted = self.lists[indexPath.row]
            try? self.realm.write {
                self.realm.delete(listToBeDeleted)
            }
        }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (editAction, indexPath) -> Void in
            // Editing will go here
            let listToBeUpdated = self.lists[indexPath.row]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TodoListViewController") as! TodoListViewController
            vc.list = listToBeUpdated
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return [deleteAction, editAction]
    }
}
