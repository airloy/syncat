//
//  AttachmentTableViewController.swift
//  Syncat_Example
//
//  Created by Layman on 2018/3/30.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import RealmSwift

class AttachmentTableViewController: UITableViewController {

    var todo: Todo?
    var notificationToken: NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let todo = todo else { return }
        title = "\(todo.name)'s Attachments"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAttachment))
        notificationToken = todo.attachments.observe {[weak self] (changes: RealmCollectionChange) in
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

    @objc func addAttachment(_ sender: UIBarButtonItem) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("can't open photo library")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todo?.attachments.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard let attachment = todo?.attachments[indexPath.row], let data = attachment.data else {
            return cell
        }
        cell.textLabel?.text = attachment.name
        cell.imageView?.image = UIImage(data: data)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            guard let realm = todo?.realm else {return}
            realm.beginWrite()
            todo?.attachments.remove(at: indexPath.row)
            try? realm.commitWrite(withoutNotifying: [notificationToken!])
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}

extension AttachmentTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        
        print(info)
        // get the image
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        // do something with it
        let attachment = Attachment()
//        if let imageUrl = info["UIImagePickerControllerImageURL"] as? URL {
//            print("file name = \(imageUrl) , ,,,, \(imageUrl.lastPathComponent)")
//            attachment.name = imageUrl.lastPathComponent
//        } else {
//            
//        }
        attachment.name = attachment.id
        attachment.data = image.jpegData(compressionQuality: 0.2)
        try? todo?.realm?.write {
            todo?.attachments.append(attachment)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        defer {
            picker.dismiss(animated: true)
        }
        
        print("did cancel")
    }
}
