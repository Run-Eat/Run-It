//
//  DistanceCollectionViewCell.swift
//  Run-It
//
//  Created by t2023-m0039 on 2/27/24.
//

import UIKit
import SnapKit

class DistanceCollectionViewCell: UICollectionViewCell {
    static var id: String { NSStringFromClass(Self.self).components(separatedBy: ".").last ?? "" }
    var timeButton: UIButton = {
       let button = UIButton()
        button.setTitle("dp", for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func addSubviews() {
        addSubview(timeButton)
    }

    private func configure() {
        timeButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(95)
            $0.height.equalTo(50)
        }
    }
}
