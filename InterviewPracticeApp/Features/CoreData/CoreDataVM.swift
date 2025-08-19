//
//  CoreDataVM.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation
import Combine

// MARK: - ViewModel Protocol
protocol CoreDataVMProtocol: AnyObject {
    var tasksPublisher: Published<[TaskEntity]>.Publisher { get }
    var errorPublisher: PassthroughSubject<CoreDataError, Never> { get }
    
    func loadTasks()
    func createTask(title: String, description: String?, dueDate: Date?, priority: TaskEntityPriority)
    func toggleTaskCompletion(_ task: TaskEntity)
    func deleteTask(_ task: TaskEntity)
    func updateTask(_ task: TaskEntity, title: String, description: String?, dueDate: Date?, priority: TaskEntityPriority)
    func numberOfTasks() -> Int
    func task(at index: Int) -> TaskEntity
}

// MARK: - ViewModel Implementation
final class CoreDataVM: CoreDataVMProtocol {
    
    @Published private var tasks: [TaskEntity] = []
    var tasksPublisher: Published<[TaskEntity]>.Publisher { $tasks }
    var errorPublisher = PassthroughSubject<CoreDataError, Never>()
    
    private let taskService: TaskEntityServiceProtocol
    
    init(taskService: TaskEntityServiceProtocol = TaskEntityService()) {
        self.taskService = taskService
    }
    
    func loadTasks() {
        let result = taskService.fetchTasks()
        
        switch result {
        case .success(let tasks):
            self.tasks = tasks
        case .failure(let error):
            errorPublisher.send(error)
        }
    }
    
    func createTask(title: String, description: String?, dueDate: Date?, priority: TaskEntityPriority) {
        let result = taskService.createTask(title: title, description: description, dueDate: dueDate, priority: priority)
        
        switch result {
        case .success:
            loadTasks() // Refresh the list
        case .failure(let error):
            errorPublisher.send(error)
        }
    }
    
    func toggleTaskCompletion(_ task: TaskEntity) {
        let result = taskService.updateTask(task, title: nil, description: nil, isCompleted: !task.isCompleted, dueDate: nil, priority: nil)
        
        switch result {
        case .success:
            loadTasks()
        case .failure(let error):
            errorPublisher.send(error)
        }
    }
    
    func deleteTask(_ task: TaskEntity) {
        let result = taskService.deleteTask(task)
        
        switch result {
        case .success:
            loadTasks()
        case .failure(let error):
            errorPublisher.send(error)
        }
    }
    
    func updateTask(_ task: TaskEntity, title: String, description: String?, dueDate: Date?, priority: TaskEntityPriority) {
        let result = taskService.updateTask(task, title: title, description: description, isCompleted: nil, dueDate: dueDate, priority: priority)
        
        switch result {
        case .success:
            loadTasks()
        case .failure(let error):
            errorPublisher.send(error)
        }
    }
    
    func numberOfTasks() -> Int {
        return tasks.count
    }
    
    func task(at index: Int) -> TaskEntity {
        return tasks[index]
    }
}
