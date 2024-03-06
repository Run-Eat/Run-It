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
        
        let currentDate = Date()
        let calender = Calendar.current
        
        let month = calender.component(.month, from: currentDate)    // 현재 월
        let weekOfYear = calender.component(.weekOfYear, from: currentDate)      // 현재 연 중의 주차

        let record = RunningRecord(entity: entity, insertInto: context)
//        record.recordId = UUID()
        record.id =  UUID()
        record.time = Int32(time)
        record.distance = distance
        record.pace = pace
        record.date = Date()
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
    
    func generateDummyRunningRecords() {
        // 더미 데이터 배열
        let dummyData = [
            (time: 3600, distance: 10.0, pace: 6.0), // 1시간, 10km, 페이스 6분/km
            (time: 1800, distance: 5.0, pace: 6.0),  // 30분, 5km, 페이스 6분/km
            (time: 5400, distance: 15.0, pace: 6.0) // 1시간 30분, 15km, 페이스 6분/km
        ]
        
        // 각 더미 데이터에 대해 RunningRecord 인스턴스 생성
        for data in dummyData {
            _ = createRunningRecord(time: data.time, distance: data.distance, pace: data.pace)
        }
        
        // 변경 사항 저장
        saveContext()
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
