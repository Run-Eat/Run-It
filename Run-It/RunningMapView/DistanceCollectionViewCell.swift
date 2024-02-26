//
//  DistanceCollectionViewCell.swift
//  Run-It
//
//  Created by t2023-m0039 on 2/26/24.
//

import UIKit

class DistanceCollectionViewCell: UICollectionViewCell {
    
    var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private func addSubviews() {
        addSubview(titleLabel)
    }

    private func configure() {
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        backgroundColor = .placeholderText
    }
}
