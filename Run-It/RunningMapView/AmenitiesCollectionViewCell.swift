//
//  AmenitiesCollectionViewCell.swift
//  Run-It
//
//  Created by t2023-m0039 on 2/27/24.
//

import UIKit

class AmenitiesCollectionViewCell: UICollectionViewCell {
    static var id: String { NSStringFromClass(Self.self).components(separatedBy: ".").last ?? "" }
    var convenienceName: UILabel = {
        let label = UILabel()
        label.text = "음식점 이름"
        return label
    }()
    var salesType: UILabel = {
        let label = UILabel()
        label.text = "영업중"
        return label
    }()
    var salesInfo: UILabel = {
        let label = UILabel()
        label.text = "00시에 영업종료"
        return label
    }()
    var distanceInfo: UILabel = {
        let label = UILabel()
        label.text = "거리 : 000m"
        return label
    }()
    var bookmarkButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemGray5
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "star")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.configuration = config
        button.backgroundColor = .clear
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
        addSubview(bookmarkButton)
        addSubview(convenienceName)
        addSubview(salesType)
        addSubview(salesInfo)
        addSubview(distanceInfo)
    }

    private func configure() {
        bookmarkButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.equalTo(20)
            $0.height.equalTo(20)
        }
        convenienceName.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(30)
            $0.width.equalTo(150)
            $0.height.equalTo(50)
        }
        salesType.snp.makeConstraints {
            $0.top.equalTo(convenienceName.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(30)
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
        salesInfo.snp.makeConstraints {
            $0.top.equalTo(convenienceName.snp.bottom).offset(10)
            $0.leading.equalTo(salesType.snp.trailing).offset(20)
            $0.width.equalTo(150)
            $0.height.equalTo(50)
        }
        distanceInfo.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-90)
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
    }
}
