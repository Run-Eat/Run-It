//
//  RunningTimerViewController.swift
//  Running&Eat
//
//  Created by Jason Yang on 2/21/24.
//

import UIKit


class RunningTimerViewController: UIViewController {
    
    
    //MARK: - properties
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        view.backgroundColor = .white // 예시로 배경색을 지정합니다.
        
        let timetextLabel = UILabel()
        timetextLabel.text = "RunningTimerVC"
        timetextLabel.textAlignment = .center
        timetextLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timetextLabel)
        
        NSLayoutConstraint.activate([
            timetextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timetextLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
}

extension RunningTimerViewController {
    
    private func addSubview() {
        
    }
    
    private func setUI() {
        
    }
}
