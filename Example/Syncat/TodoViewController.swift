//
//  TodoViewController.swift
//  Syncat_Example
//
//  Created by Layman on 2018/3/29.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

class TodoViewController: UIViewController {
    
    var todo: Todo?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.delegate = self
        // Do any additional setup after loading the view.
        title = "Todo Detail"
        guard let todo = todo else { return }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveChanges))
        nameTextField.text = todo.name
        notesTextView.text = todo.notes
    }

    @objc func saveChanges(_ sender: UIBarButtonItem) {
        try? todo?.realm?.write {
            if let name = self.nameTextField.text, !name.isEmpty {
                todo?.name = name
            }
            todo?.notes = notesTextView.text
        }
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func showTaskList(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: "Select List", preferredStyle: UIAlertControllerStyle.actionSheet)
        todo?.realm?.objects(TodoList.self).forEach { todoList in
            let listAction = UIAlertAction(title: todoList.name, style: UIAlertActionStyle.default) { (action) -> Void in
                try? self.todo?.realm?.write {
                    self.todo?.list = todoList
                }
            }
            alertController.addAction(listAction)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func showAttachments(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AttachmentTableViewController") as! AttachmentTableViewController
        vc.todo = todo
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension TodoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
