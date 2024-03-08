//
//  CoreDataManager.swift
//  Run-It
//
//  Created by t2023-m0024 on 2/29/24.
//

import Foundation
import CoreData
import CoreLocation
import KakaoSDKUser
import UIKit

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
    
    func loadFavorites(completion: @escaping (Bool, [Favorite]?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        
        context.perform {
            do {
                let favorites = try context.fetch(fetchRequest)
                completion(true, favorites)
            } catch {
                print("Failed to load favorites: \(error)")
                completion(false, nil)
            }
        }
    }
    
    func addFavorite(storeName: String, address: String, category: String, distance: Double, latitude: Double, longitude: Double) -> Bool {
        let context = persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Favorite", in: context) else {
            print("Failed to create entity description for Favorite")
            return false
        }
        
        let favorite = NSManagedObject(entity: entity, insertInto: context)
        favorite.setValue(storeName, forKey: "storeName")
        favorite.setValue(address, forKey: "address")
        favorite.setValue(category, forKey: "category")
        favorite.setValue(distance, forKey: "distance")
        favorite.setValue(Date(), forKey: "addedDate")
        
        do {
            try context.save()
            return true
        } catch {
            print("Failed to add favorite: \(error)")
            return false
        }
    }
    
    func deleteFavorite(withId id: NSManagedObjectID, completion: (Bool) -> Void) {
        let context = persistentContainer.viewContext
        let objectToDelete = context.object(with: id)
        context.delete(objectToDelete)
        
        do {
            try context.save()
            completion(true)
        } catch {
            print("Failed to delete favorite: \(error)")
            completion(false)
        }
    }
    
    
    // MARK: - PlaceInfo Operations
    // Add functions for managing place information
    
    // MARK: - RunningRecord Operations
    func createRunningRecord(time: Int, distance: Double, pace: Double, routeImage: Data) -> UUID? {
        let context = persistentContainer.viewContext
        let newRecord = RunningRecord(context: context)
        newRecord.id = UUID()
        newRecord.time = Int32(time)
        newRecord.distance = distance
        newRecord.pace = pace
        newRecord.date = Date()
        newRecord.routeImage = routeImage
        
        do {
            try context.save()
            return newRecord.id
        } catch {
            print("Failed to save running record: \(error)")
            return nil
        }
    }

    
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
    
    // Data 객체로부터 [CLLocation] 배열을 로드하는 함수
    func loadRoute(from data: Data) -> [CLLocation]? {
        do {
            // 'requiringSecureCoding' 옵션을 true로 설정하여 NSSecureCoding을 준수하는 객체만 역직렬화 허용
            let locations = try NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: CLLocation.self, from: data)
            return locations
        } catch {
            print("Failed to unarchive locations: \(error)")
            return nil
        }
    }
    
    func updateRunningRecordWithImage(recordId: UUID, routeImage: UIImage, completion: @escaping (Bool) -> Void) {
        // `persistentContainer` 및 `context` 설정을 가정
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<RunningRecord> = RunningRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", recordId as CVarArg)

        do {
            let records = try context.fetch(fetchRequest)
            if let recordToUpdate = records.first {
                if let imageData = routeImage.pngData() {
                    recordToUpdate.routeImage = imageData
                    try context.save()
                    completion(true)
                    return
                }
            }
        } catch {
            print("Error updating record: \(error)")
        }
        completion(false)
    }
    
    // MARK: - Delete RunningRecord in CoreDataManager
    func deleteRunningRecord(withId id: UUID, completion: (Bool) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<RunningRecord> = RunningRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let records = try context.fetch(fetchRequest)
            if let recordToDelete = records.first {
                context.delete(recordToDelete)
                try context.save()
                completion(true)
            } else {
                print("No record found with the specified ID.")
                completion(false)
            }
        } catch {
            print("Failed to delete running record: \(error)")
            completion(false)
        }
    }
    
}
