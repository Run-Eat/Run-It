//
//  CoreDataManager.swift
//  Run-It
//
//  Created by t2023-m0024 on 2/29/24.
//

import Foundation
import CoreData
import KakaoSDKUser

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Run_It")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
                // Handle the error appropriately
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - User Operations
    func createUser(email: String, name: String, profilePhoto: Data) -> User? {
        let context = persistentContainer.viewContext
        // Correct way to create a new User entity
        guard let entity = NSEntityDescription.entity(forEntityName: "User", in: context) else {
            print("Failed to create entity description for User")
            return nil
        }

        let user = User(entity: entity, insertInto: context)
        user.userId = UUID()
        user.email = email
        user.name = name
        user.createdAt = Date()
        // Assume profilePhoto is stored as Data
        user.profilePhoto = profilePhoto
        
        do {
            try context.save()
            return user
        } catch {
            print("Failed to create user: \(error)")
            return nil
        }
    }

    
    // Add similar functions for other CRUD operations on User and other entities
    // For example: fetchUsers(), updateUser(), deleteUser(), etc.
    
    // MARK: - Destination Operations
    // Add functions for creating, reading, updating, and deleting destinations
    
    // MARK: - Favorite Operations
    // Add functions for managing favorites
    
    // MARK: - PlaceInfo Operations
    // Add functions for managing place information
    
    // MARK: - RunningRecord Operations
    func createRunningRecord(time: Int, distance: Double, pace: Double) -> RunningRecord? {
        let context = persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "RunningRecord", in: context) else {
            print("Failed to create entity description for RunningRecord")
            return nil
        }

        let record = RunningRecord(entity: entity, insertInto: context)
//        record.recordId = UUID()
        record.id =  UUID()
        record.time = Int32(time)
        record.distance = distance
        record.pace = pace
//        record.createdAt = Date()
        print("CoreData id: \(String(describing: record.id)) Time: \(record.time), Distance: \(record.distance), Pace: \(record.pace)")
        
        do {
            try context.save()
            return record
        } catch {
            print("Failed to create running record: \(error)")
            return nil
        }
    }

    
    // MARK: - RunningRecord Operations
    func fetchRunningRecords() -> [RunningRecord] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<RunningRecord> = RunningRecord.fetchRequest()

        do {
            let records = try context.fetch(fetchRequest)
            return records
        } catch {
            print("Failed to fetch running records: \(error)")
            return []
        }
    }
}
