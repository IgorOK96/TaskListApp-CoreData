//
//  TaskListViewController.swift
//  TaskListApp CoreData
//
//  Created by user246073 on 10/6/24.
//

import UIKit
final class TaskListViewController: UITableViewController {
    private var taskList: [ToDoTask] = []
    private let cellID = "task"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .systemBackground
        fetchTasks()
        setupNavigationBar()
    }
    
    @objc private func addNewTask() {
        showAlert()
    }
    
    private func fetchTasks() {
        StorageManager.shared.fetchTasks { [weak self] result in
            switch result {
            case .success(let tasks):
                self?.taskList = tasks
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Errr fetching tasks: \(error.localizedDescription)")
            }
        }
    }
    
    private func save(_ taskName: String) {
        let task = StorageManager.shared.createTask(title: taskName)
        taskList.append(task)
        
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - Alert Controller
extension TaskListViewController {
    private func showAlert(task: ToDoTask? = nil, completion: (() -> Void)? = nil) {
        let userAction: UserAction = task != nil ? .editTask : .newTask
        let alertFactory = AlertControllerFactory(
            userAction: userAction,
            taskTitle: task?.title
        )
        
        let alert = alertFactory.createAlert { [unowned self] taskName in
            if let task {
                StorageManager.shared.updateTask(task, withTitle: taskName)
                completion?()
            } else {
                self.save(taskName)
            }
        }
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let toDoTask = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = toDoTask.title
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
    forRowAt indexPath:  IndexPath) {
        if editingStyle == .delete {
            let task = taskList.remove(at: indexPath.row)
            StorageManager.shared.deleteTask(task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = taskList[indexPath.row]
        showAlert(task: task) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor.systemBlue
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
}


