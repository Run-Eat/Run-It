//
//  RunningTimerViewController.swift
//  Running&Eat
//
//  Created by Jason Yang on 2/21/24.
//

import UIKit


class RunningTimerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 여기에 프로필에 관련된 코드를 추가합니다.
        view.backgroundColor = .white // 예시로 배경색을 지정합니다.
        
        let label = UILabel()
        label.text = "RunningTimerVC"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
}
