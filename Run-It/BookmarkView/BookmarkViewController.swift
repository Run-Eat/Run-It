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
    
    var myFavorite: UILabel = {
        let label = UILabel()
        label.text = "즐겨찾기"
        label.font = UIFont.systemFont(ofSize: 25)
        label.textAlignment = .left
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
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
    }
    
    func setupFavoriteListUI() {
        view.addSubview(myFavorite)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(FavoriteViewCell.self, forCellReuseIdentifier: "FavoriteCell")
        tableView.backgroundColor = UIColor.systemGray6
        tableView.isScrollEnabled = true
        
        myFavorite.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(myFavorite.snp.bottom).offset(15)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
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

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
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
