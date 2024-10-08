//
//  StorageManager.swift
//  TaskListApp CoreData
//
//  Created by user246073 on 10/6/24.
//

import CoreData

final class StorageManager {
    static let shared = StorageManager()
    
    // MARK: - Core Data Stack
    private let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "TaskListApp_CoreData")
        persistentContainer.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    // MARK: - Context Core Data
   private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Save context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Failed to save the context \(error), \(error.userInfo)")
            }
        }
    }

    // MARK: - Method CRUD
    func createTask(title: String) -> ToDoTask {
        let task = ToDoTask(context: context)
        task.title = title
        saveContext()
        return task
    }

    func fetchTasks(completion: @escaping (Result<[ToDoTask], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<ToDoTask> = ToDoTask.fetchRequest()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            do {
                let tasks = try self.context.fetch(fetchRequest)
                DispatchQueue.main.async {
                    completion(.success(tasks))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updateTask(_ task: ToDoTask, withTitle title: String) {
        task.title = title
        saveContext()
    }

    func deleteTask(_ task: ToDoTask) {
        context.delete(task)
        saveContext()
    }
}
