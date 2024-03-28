//
//  ActivityViewController.swift
//  Running&Eat
//
//  Created by Jason Yang on 2/21/24.
//

import UIKit
import SnapKit

class BookmarkViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    var favoritesViewModel = FavoritesViewModel()
    var favoriteRecords: [Favorite] = []
    
    lazy var favoriteLabel: UILabel = {
        let label = UILabel()
        label.text = "즐겨찾기"
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        label.textColor = .label
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var imageBar: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.systemGray6
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        favoritesViewModel.delegate = self
        setupFavoriteUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favoritesViewModel.fetchFavorites()
    }

    // MARK: - UI Setup
    func setupFavoriteUI() {
        setupFavoriteListUI()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func setupFavoriteListUI() {
        view.addSubview(favoriteLabel)
        view.addSubview(imageBar)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(FavoriteViewCell.self, forCellReuseIdentifier: "FavoriteCell")
        tableView.backgroundColor = UIColor.systemBackground
        tableView.isScrollEnabled = true
        
        favoriteLabel.snp.makeConstraints{ make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        imageBar.snp.makeConstraints { make in
            make.top.equalTo(favoriteLabel.snp.bottom).offset(8)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(8)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(imageBar.snp.bottom)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor.systemBackground
//
//        let label = UILabel()
//        label.text = "즐겨찾기"
//        label.font = UIFont.systemFont(ofSize: 25)
//        label.textColor = UIColor.label
//        label.textAlignment = .left
//        headerView.addSubview(label)
//
//        label.snp.makeConstraints { make in
//            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 20))
//        }
//
//        return headerView
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favoriteRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as? FavoriteViewCell else {
            return UITableViewCell()
        }
        let favoriteRecord = favoriteRecords[indexPath.row]

        let viewModel = FavoritesViewModel(favoriteRecord: favoriteRecord)
        cell.configure(with: viewModel)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite = favoriteRecords[indexPath.row]
        print("Selected Favorite: \(favorite)")
        print("Latitude: \(favorite.latitude), Longitude: \(favorite.longitude)")
        print("BookmarkViewController: didSelectRowAt 호출됨, favorite: \(String(describing: favorite.storeName))")

        if let navigationController = tabBarController?.viewControllers?[0] as? UINavigationController,
           let runningMapVC = navigationController.viewControllers.first as? RunningMapViewController {
            
            runningMapVC.didSelectFavorite(favorite)

            tabBarController?.selectedViewController = navigationController
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 122
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            favoritesViewModel.removeFavorite(at: indexPath)
        }
    }
}
extension BookmarkViewController: FavoritesViewModelDelegate {
    func favoritesDidUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.favoriteRecords = self?.favoritesViewModel.favorites ?? []
            self?.tableView.reloadData()
        }
    }
}
