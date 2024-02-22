//
//  RunningViewController.swift
//  Running&Eat
//
//  Created by Jason Yang on 2/21/24.
//

import UIKit

class RunningMapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

 
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "runningMapVC"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

    }
}

