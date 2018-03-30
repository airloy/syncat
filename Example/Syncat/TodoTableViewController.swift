//
//  TodoTableViewController.swift
//  Syncat_Example
//
//  Created by Layman on 2018/3/29.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import RealmSwift

class TodoTableViewController: UITableViewController {

    var currentCreateAction: UIAlertAction?
    
    var list: TodoList?
    let realm = try! Realm()
    var todos: Results<Todo>!
    var dones: Results<Todo>!
    var notificationToken: NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let list = list else { return }
        title = "\(list.name)'s Todos"

        self.clearsSelectionOnViewWillAppear = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
        
        todos = realm.objects(Todo.self).filter("list == %@ and isCompleted == false", list)
        dones = realm.objects(Todo.self).filter("list == %@ and isCompleted == true", list)
        notificationToken = realm.objects(Todo.self).filter("list == %@", list).observe {[weak self] (changes: RealmCollectionChange) in
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

    @objc func addTask(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Todo", message: "Write the name of your todo.", preferredStyle: UIAlertControllerStyle.alert)
        
        let createAction = UIAlertAction(title: "Create", style: UIAlertActionStyle.default) { (action) -> Void in
            if let todoName = alertController.textFields?.first?.text {
                let newTodo = Todo()
                newTodo.name = todoName
                newTodo.list = self.list
                try? self.realm.write{
                    self.realm.add(newTodo)
                }
            }
        }
        
        alertController.addAction(createAction)
        createAction.isEnabled = false
        self.currentCreateAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Todo Name"
            textField.addTarget(self, action: #selector(self.todoNameFieldDidChange) , for: UIControlEvents.editingChanged)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func todoNameFieldDidChange(_ textField:UITextField) {
        if let text = textField.text {
            self.currentCreateAction?.isEnabled = !text.isEmpty
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Todos" : "Completeds"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return todos.count
        } else {
            return dones.count
        }
    }
    
    func todoObject(forRowAt indexPath: IndexPath) -> Todo {
        return indexPath.section == 0 ? todos[indexPath.row] : dones[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let todo = todoObject(forRowAt: indexPath)
        cell.textLabel?.text = todo.name
        cell.detailTextLabel?.text = todo.notes
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = indexPath.section == 0 ? "Finish it" : "UnFinish it"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
            let todo = self.todoObject(forRowAt: indexPath)
            try? self.realm.write {
                todo.isCompleted = !todo.isCompleted
            }
        })
        self.present(alert, animated: true)
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath) -> Void in
            //Deletion will go here
            let todoToBeDeleted = self.todoObject(forRowAt: indexPath)
            try? self.realm.write {
                self.realm.delete(todoToBeDeleted)
            }
        }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (editAction, indexPath) -> Void in
            // Editing will go here
            let todoToBeUpdated = self.todos[indexPath.row]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TodoViewController") as! TodoViewController
            vc.todo = todoToBeUpdated
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return indexPath.section == 0 ? [deleteAction, editAction] : [deleteAction]
    }
}
