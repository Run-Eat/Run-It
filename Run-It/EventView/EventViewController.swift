//
//  RunningTimerViewController.swift
//  Running&Eat
//
//  Created by Jason Yang on 2/21/24.
//

import UIKit
import SnapKit

struct EventSection {
    let title: String
    let imageURLs: [String]
}

class EventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Properties
    var tableView = UITableView()
    
    let sections: [EventSection] = [
        EventSection(title: "업데이트", imageURLs: [
            "https://picsum.photos/353/130",
            "https://picsum.photos/353/130"
        ]),
        EventSection(title: "이벤트", imageURLs: [
            "https://picsum.photos/353/130",
            "https://picsum.photos/353/130"
        ])
    ]
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    // MARK: - UI Setup
    func setupUI() {
        view.backgroundColor = UIColor.white

        navigationItem.title = "Event"
        
        tableView.register(EventViewCell.self, forCellReuseIdentifier: "EventCell")
        tableView.backgroundColor = UIColor.white
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
    }
    // MARK: - UITableView Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].imageURLs.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        if section == 0 {
            headerView.backgroundColor = UIColor.white
        } else {
            headerView.backgroundColor = UIColor.white
        }
        
        let label = UILabel()
        label.text = sections[section].title
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.systemIndigo
        headerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 15))
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    // MARK: - UITableView DataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventViewCell
        let urlString = sections[indexPath.section].imageURLs[indexPath.row]
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    cell.cellImageView.image = UIImage(data: data)
                }
            }.resume()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 이벤트 상세 화면 페이지로 이동 (추후 구현)
    }
}
