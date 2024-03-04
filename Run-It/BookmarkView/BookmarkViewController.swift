//
//  ActivityViewController.swift
//  Running&Eat
//
//  Created by Jason Yang on 2/21/24.
//
#if DEBUG
import SwiftUI
struct FPreview: UIViewControllerRepresentable {

    // 여기 ViewController를 변경해주세요
    func makeUIViewController(context: Context) -> UIViewController {
        BookmarkViewController()
    }

    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
}

struct ViewController_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            FPreview()
                .edgesIgnoringSafeArea(.all)
                .previewDisplayName("Preview")
                .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
        }
    }
}
#endif
import UIKit

class BookmarkViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tableView = UITableView()
    
    var myFavorite: UILabel = {
        let label = UILabel()
        label.text = "즐겨찾기"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .left
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupFavoriteUI()

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
        tableView.backgroundColor = UIColor.white
        tableView.isScrollEnabled = false
        
        myFavorite.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(20)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(myFavorite.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(3 * 120)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as? FavoriteViewCell else {
            return UITableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

