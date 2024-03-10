//
//  AmenitiesViewController.swift
//  Run-It
//
//  Created by t2023-m0039 on 2/26/24.
//

import UIKit
import SnapKit
import CoreData

struct AnnotationInfo {
    let name: String
    let category: String
    let address: String
    let url: String
    let latitude: Double
    let longitude: Double
    let isOpenNow: Bool
    let distance: Int
    var isFavorite: Bool
}

protocol StoreViewControllerDelegate: AnyObject {
    func didCloseStoreViewController()
}

class StoreViewController: UIViewController {
    weak var delegate: StoreViewControllerDelegate?
    
    
    var RecommandatedLocation: UILabel = {
        let label = UILabel()
        label.text = "추천장소"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .left
        return label
    }()
    
    var tableView = UITableView()
    var stores: [AnnotationInfo] = []
    var displayMode: DisplayMode = .allStores
    var favoritesViewModel = FavoritesViewModel()
    
    enum DisplayMode {
        case allStores
        case singleStore
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemGray6
        setupStoreListUI()
        tableView.reloadData()
        view.isUserInteractionEnabled = true
//        setupCloseButton()
        setGesture()
    }
    private func setGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDismissGesture))
        self.view.addGestureRecognizer(panGesture)
    }
    
    @objc func handleDismissGesture(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .ended {
            let translation = gesture.translation(in: view)
            let velocity = gesture.velocity(in: view)
            
            if translation.y > 100 || velocity.y > 1000 {
                // 드래그가 일정 거리 이상이거나 속도가 충분히 빠를 경우 모달 닫기
                dismiss(animated: true, completion: nil)
            }
//            delegate?.didCloseStoreViewController()
        }
    }
    
//    func setupCloseButton() {
//        let closeButton = UIButton(type: .system)
//        closeButton.setTitle("닫기", for: .normal)
//        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
//        view.addSubview(closeButton)
//        closeButton.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(5)
//            make.trailing.equalToSuperview().offset(-20)
//        }
//    }
//    
    @objc func closeAction() {
        delegate?.didCloseStoreViewController()
        dismiss(animated: true, completion: nil)
    }
    
    func setupStoreListUI() {
        view.addSubview(RecommandatedLocation)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(StoreTableViewCell.self, forCellReuseIdentifier: "StoreCell")
        tableView.backgroundColor = UIColor.systemGray6
        tableView.isScrollEnabled = true
        
        RecommandatedLocation.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalToSuperview().offset(10)
//            make.right.equalToSuperview().offset(-20)
        }
        
        tableView.snp.makeConstraints { make in
//            make.top.equalTo(RecommandatedLocation.snp.bottom).offset(5)
//            make.edges.equalToSuperview()
            make.top.equalTo(RecommandatedLocation.snp.bottom).offset(2)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let parentView = self.presentingViewController?.view {
            let halfHeight = parentView.frame.height
            self.view.frame = CGRect(x: 0, y: parentView.frame.height - halfHeight, width: parentView.frame.width, height: halfHeight)
        }
    }
    
    func updateTableView(for mode: DisplayMode, with stores: [AnnotationInfo]) {
        self.displayMode = mode
        self.stores = stores
        tableView.reloadData()
    }

}
extension StoreViewController: UITableViewDelegate, UITableViewDataSource{
    // MARK: - 데이터 로딩
    
    private func updateUI() {
        // 근처의 데이터로 UI 업데이트
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StoreCell", for: indexPath) as? StoreTableViewCell else {
            return UITableViewCell()
        }
        
        let store = stores[indexPath.row]
        
        cell.storeLabel.text = store.name
        cell.storeCategoryLabel.text = store.category
        cell.isOpenLabel.text = store.isOpenNow ? "영업 중" : "24시간 영업"
        cell.storeDistanceLabel.text = "\(store.distance) m"
        cell.storeAdressLabel.text = store.address
        cell.delegate = self
        
        // 상점의 즐겨찾기 상태를 위/경도로 조회
        favoritesViewModel.isStoreFavoritedByCoordinates(latitude: store.latitude, longitude: store.longitude) { isFavorited in
            DispatchQueue.main.async {
                cell.updateFavoriteButton(isFavorited: isFavorited)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let store = stores[indexPath.row]
        // 해당 레코드의 어노테이션으로 이동
    }
}

extension StoreViewController: StoreTableViewCellDelegate {
    func didTapFavoriteButton(in cell: StoreTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        var store = stores[indexPath.row]
        
        store.isFavorite.toggle() // 토글
        handleFavorite(for: store) { isFavoriteNow in
            cell.updateFavoriteButton(isFavorited: isFavoriteNow)
        }
        stores[indexPath.row].isFavorite = store.isFavorite // 중요: 모델 업데이트
    }
    
    // Adjusted to accept the entire store information
    func handleFavorite(for store: AnnotationInfo, completion: @escaping (Bool) -> Void) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        // 상점을 고유하게 식별하기 위해 storeName, latitude, longitude를 모두 사용
        fetchRequest.predicate = NSPredicate(format: "storeName == %@ AND latitude == %lf AND longitude == %lf", store.name, store.latitude, store.longitude)

        do {
            let favorites = try context.fetch(fetchRequest)
            if let favorite = favorites.first {
                // If it's already a favorite, delete it
                print("Attempting to delete favorite: \(store.name)")
                CoreDataManager.shared.deleteFavorite(withId: favorite.objectID) { success in
                    if success {
                        print("Successfully deleted favorite: \(store.name)")
                    } else {
                        print("Failed to delete favorite: \(store.name)")
                    }
                    completion(!success) // If deletion was successful, isFavoriteNow should be false.
                }
            } else {
                // If it's not a favorite, add it
                print("Attempting to add favorite: \(store.name)")
                let isSuccess = CoreDataManager.shared.addFavorite(storeName: store.name, address: store.address, category: store.category, distance: Double(store.distance), latitude: store.latitude, longitude: store.longitude)
                if isSuccess {
                    print("Successfully added favorite: \(store.name)")
                } else {
                    print("Failed to add favorite: \(store.name)")
                }
                completion(isSuccess) // isFavoriteNow should be true after adding.
            }
        } catch {
            print("Failed to fetch favorites: \(error)")
            completion(false) // If there was an error, we assume isFavoriteNow is false.
        }
    }
}
