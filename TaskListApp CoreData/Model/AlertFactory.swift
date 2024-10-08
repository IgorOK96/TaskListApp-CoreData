//
//  AlertFactory.swift
//  TaskListApp CoreData
//
//  Created by user246073 on 10/8/24.
//

import UIKit
enum UserAction {
    case newTask
    case editTask
}

final class AlertControllerFactory {
    private let userAction: UserAction
    private let taskTitle: String?
    
    init(userAction: UserAction, taskTitle: String? = nil) {
        self.userAction = userAction
        self.taskTitle = taskTitle
    }
    
    func createAlert(completion: @escaping (String) -> Void) -> UIAlertController {
        let title: String
        let message: String
        
        switch userAction {
        case .newTask:
            title = "New Task"
            message = "What do want to do?"
        case .editTask:
            title = "Edit task"
            message = "Edit your task"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveActionTitle = userAction == .newTask ? "Save" : "Update"
        let saveAction = UIAlertAction(title: saveActionTitle, style: .default) { _ in
            guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
            completion(taskName)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { [unowned self] textField in
            textField.placeholder = "Task name"
            textField.text = self.taskTitle
        }
        
        return alert
    }
}
