//
//  TodoListViewController.swift
//  Syncat_Example
//
//  Created by Layman on 2018/3/29.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var currentCreateAction: UIAlertAction?
    
    var list: TodoList?
    var notificationToken: NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.delegate = self
        // Do any additional setup after loading the view.
        title = "Todo List Detail"
        guard let list = list else { return }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveChanges))
        nameTextField.text = list.name
        notificationToken = list.tags.observe {[weak self] (changes: RealmCollectionChange) in
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
    
    @objc func saveChanges(_ sender: UIBarButtonItem) {
        try? list?.realm?.write {
            if let name = self.nameTextField.text, !name.isEmpty {
                list?.name = name
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addTag(_ sender: Any) {
        let alertController = UIAlertController(title: "New Tag", message: "Write the name of your tag.", preferredStyle: UIAlertControllerStyle.alert)
        
        let createAction = UIAlertAction(title: "Create", style: UIAlertActionStyle.default) { (action) -> Void in
            if let tagName = alertController.textFields?.first?.text {
                try? self.list?.realm?.write{
                    self.list?.tags.append(tagName)
                }
            }
        }
        
        alertController.addAction(createAction)
        createAction.isEnabled = false
        self.currentCreateAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Tag Name"
            textField.addTarget(self, action: #selector(self.tagNameFieldDidChange) , for: UIControlEvents.editingChanged)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func tagNameFieldDidChange(_ textField:UITextField) {
        if let text = textField.text {
            self.currentCreateAction?.isEnabled = !text.isEmpty
        }
    }
}

extension TodoListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.tags.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = list?.tags[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath) -> Void in
            //Deletion will go here
            try? self.list?.realm?.write {
                self.list?.tags.remove(at: indexPath.row)
            }
        }
        return [deleteAction]
    }
}
