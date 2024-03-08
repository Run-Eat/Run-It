//
//  FavoritesViewModel.swift
//  Run-It
//
//  Created by t2023-m0024 on 3/7/24.
//

import Foundation
import CoreData

protocol FavoritesViewModelDelegate: AnyObject {
    func favoritesDidUpdate()
}

class FavoritesViewModel {
    // 뷰에 표시될 속성들
    var storeText: String
    var categoryText: String
    var addressText : String
    
    private let coreDataManager: CoreDataManager
    weak var delegate: FavoritesViewModelDelegate?

    init(favoriteRecord: Favorite) {
        self.storeText = favoriteRecord.storeName ?? ""
        self.categoryText = favoriteRecord.category ?? ""
        self.addressText = favoriteRecord.address ?? ""
        self.coreDataManager = CoreDataManager.shared
    }
    
    var favorites: [Favorite] = []
    
    init(coreDataManager: CoreDataManager = .shared) {
        self.storeText = ""
        self.categoryText = ""
        self.addressText = ""
        self.coreDataManager = coreDataManager
    }
    
    // Fetch favorites from Core Data
    func fetchFavorites() {
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        do {
            favorites = try coreDataManager.persistentContainer.viewContext.fetch(fetchRequest)
            delegate?.favoritesDidUpdate()
        } catch {
            print("Error fetching favorites: \(error)")
        }
    }
    
    // Add a favorite store
    func addFavorite(storeName: String, address: String, category: String, distance: Double, latitude: Double, longitude: Double) {
        let success = coreDataManager.addFavorite(storeName: storeName, address: address, category: category, distance: distance, latitude: latitude, longitude: longitude)
        if success {
            fetchFavorites()
        }
    }
    
    // Remove a favorite store
    func removeFavorite(at indexPath: IndexPath) {
        let favorite = favorites[indexPath.row]
        coreDataManager.deleteFavorite(withId: favorite.objectID) { [weak self] success in
            if success {
                self?.favorites.remove(at: indexPath.row)
                self?.delegate?.favoritesDidUpdate()
            }
        }
    }
    
    // Toggle favorite status for a store
    func toggleFavorite(for storeName: String, address: String, category: String, distance: Double, latitude: Double, longitude: Double) {
        if let index = favorites.firstIndex(where: { $0.storeName == storeName }) {
            removeFavorite(at: IndexPath(row: index, section: 0))
        } else {
            addFavorite(storeName: storeName, address: address, category: category, distance: distance, latitude: latitude, longitude: longitude)
        }
    }
    
    // Get the number of favorites
    func numberOfFavorites() -> Int {
        return favorites.count
    }
    
    // Get a specific favorite for display
    func favorite(at indexPath: IndexPath) -> Favorite {
        return favorites[indexPath.row]
    }
}

extension FavoritesViewModel {
    // Method to check if a store is a favorite
    func isFavorite(storeName: String, latitude: Double, longitude: Double) -> Bool {
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "storeName == %@ AND latitude == %lf AND longitude == %lf", storeName, latitude, longitude)
        
        do {
            let results = try coreDataManager.persistentContainer.viewContext.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            print("Error checking if store is favorite: \(error)")
            return false
        }
    }
    
    func isStoreFavorited(storeName: String, completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "storeName == %@", storeName)
        
        do {
            let results = try coreDataManager.persistentContainer.viewContext.fetch(fetchRequest)
            completion(!results.isEmpty)
        } catch {
            print("Error fetching favorite status: \(error)")
            completion(false)
        }
    }
    
    func isStoreFavoritedByCoordinates(latitude: Double, longitude: Double, completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "latitude == %lf AND longitude == %lf", latitude, longitude)
        
        do {
            let results = try coreDataManager.persistentContainer.viewContext.fetch(fetchRequest)
            completion(!results.isEmpty) // 결과가 있으면 즐겨찾기된 것으로 판단
        } catch {
            print("Error fetching favorite by coordinates: \(error)")
            completion(false)
        }
    }

}

