//
//  TaskEntityService.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation
import UIKit
import CoreData
import Combine

// MARK: - Task Entity Service Protocol
protocol TaskEntityServiceProtocol {
    func createTask(title: String, description: String?, dueDate: Date?, priority: TaskEntityPriority) -> Result<TaskEntity, CoreDataError>
    func fetchTasks() -> Result<[TaskEntity], CoreDataError>
    func updateTask(_ task: TaskEntity, title: String?, description: String?, isCompleted: Bool?, dueDate: Date?, priority: TaskEntityPriority?) -> Result<TaskEntity, CoreDataError>
    func deleteTask(_ task: TaskEntity) -> Result<Void, CoreDataError>
    func fetchCompletedTasks() -> Result<[TaskEntity], CoreDataError>
    func fetchPendingTasks() -> Result<[TaskEntity], CoreDataError>
}

enum TaskEntityPriority: Int16, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2
    
    var title: String {
        switch self {
        case .low: return "Baja"
        case .medium: return "Media"
        case .high: return "Alta"
        }
    }
    
    var color: UIColor {
        switch self {
        case .low: return .systemGreen
        case .medium: return .systemOrange
        case .high: return .systemRed
        }
    }
}

// MARK: - Task Entity Service Implementation
final class TaskEntityService: TaskEntityServiceProtocol {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func createTask(title: String, description: String?, dueDate: Date?, priority: TaskEntityPriority) -> Result<TaskEntity, CoreDataError> {
        let task = TaskEntity(context: context)
        task.id = UUID()
        task.title = title
        task.taskDescription = description
        task.isCompleted = false
        task.createdAt = Date()
        task.dueDate = dueDate
        task.priority = priority.rawValue
        
        do {
            try context.save()
            return .success(task)
        } catch {
            return .failure(.saveFailed)
        }
    }
    
    func fetchTasks() -> Result<[TaskEntity], CoreDataError> {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TaskEntity.isCompleted, ascending: true),
            NSSortDescriptor(keyPath: \TaskEntity.priority, ascending: false),
            NSSortDescriptor(keyPath: \TaskEntity.createdAt, ascending: false)
        ]
        
        do {
            let tasks = try context.fetch(request)
            return .success(tasks)
        } catch {
            return .failure(.fetchFailed)
        }
    }
    
    func updateTask(_ task: TaskEntity, title: String?, description: String?, isCompleted: Bool?, dueDate: Date?, priority: TaskEntityPriority?) -> Result<TaskEntity, CoreDataError> {
        if let title = title { task.title = title }
        if let description = description { task.taskDescription = description }
        if let isCompleted = isCompleted { task.isCompleted = isCompleted }
        if let dueDate = dueDate { task.dueDate = dueDate }
        if let priority = priority { task.priority = priority.rawValue }
        
        do {
            try context.save()
            return .success(task)
        } catch {
            return .failure(.saveFailed)
        }
    }
    
    func deleteTask(_ task: TaskEntity) -> Result<Void, CoreDataError> {
        context.delete(task)
        
        do {
            try context.save()
            return .success(())
        } catch {
            return .failure(.deleteFailed)
        }
    }
    
    func fetchCompletedTasks() -> Result<[TaskEntity], CoreDataError> {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isCompleted == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.createdAt, ascending: false)]
        
        do {
            let tasks = try context.fetch(request)
            return .success(tasks)
        } catch {
            return .failure(.fetchFailed)
        }
    }
    
    func fetchPendingTasks() -> Result<[TaskEntity], CoreDataError> {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isCompleted == NO")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TaskEntity.priority, ascending: false),
            NSSortDescriptor(keyPath: \TaskEntity.createdAt, ascending: false)
        ]
        
        do {
            let tasks = try context.fetch(request)
            return .success(tasks)
        } catch {
            return .failure(.fetchFailed)
        }
    }
}
