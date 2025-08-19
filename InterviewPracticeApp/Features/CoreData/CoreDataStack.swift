//
//  CoreDataStack.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import Foundation
import CoreData

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
}

// MARK: - Core Data Entity (Task)
/*
 extension Task {
 //@NSManaged public var id: UUID
 //@NSManaged public var title: String
 //@NSManaged public var taskDescription: String?
 //@NSManaged public var isCompleted: Bool
 //@NSManaged public var createdAt: Date
 //@NSManaged public var dueDate: Date?
 //@NSManaged public var priority: Int16
 }
 */

