//
//  StoreTableViewCell.swift
//  Run-It
//
//  Created by t2023-m0039 on 2/26/24.
//

import UIKit
import SnapKit

protocol StoreTableViewCellDelegate: AnyObject {
    func didTapFavoriteButton(in cell: StoreTableViewCell)
}

class StoreTableViewCell: UITableViewCell {
    // MARK: - Properties
    weak var delegate: StoreTableViewCellDelegate?
    lazy var storeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var storeCategoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .right
        return label
    }()
    
    lazy var isOpenLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()
    
    lazy var storeDistanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .right
        return label
    }()
    
    lazy var storeAdressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "StoreCell")
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Button Action
    @objc func toggleFavorite() {
        delegate?.didTapFavoriteButton(in: self)
    }

    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = UIColor.white
        contentView.addSubview(storeLabel)
        contentView.addSubview(isOpenLabel)
        contentView.addSubview(storeCategoryLabel)
        contentView.addSubview(storeDistanceLabel)
        contentView.addSubview(storeAdressLabel)
        contentView.addSubview(favoriteButton)
    }
    // MARK: - Setup Layout
    private func setupLayout() {
        storeLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(15)
            make.leading.equalTo(contentView.snp.leading).offset(18)
            make.height.equalTo(18)
        }
        
        storeCategoryLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(15)
            make.leading.equalTo(storeLabel.snp.trailing).offset(10)
            make.height.equalTo(18)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(15)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
            make.width.height.equalTo(44)
        }
        
        isOpenLabel.snp.makeConstraints { make in
            make.top.equalTo(storeLabel.snp.bottom).offset(10)
            make.leading.equalTo(contentView.snp.leading).offset(18)
            make.height.equalTo(18)
        }
        
        storeDistanceLabel.snp.makeConstraints { make in
            make.top.equalTo(isOpenLabel.snp.bottom).offset(10)
            make.leading.equalTo(contentView.snp.leading).offset(18)
            make.height.equalTo(18)
        }
        
        storeAdressLabel.snp.makeConstraints { make in
            make.top.equalTo(isOpenLabel.snp.bottom).offset(8)
            make.leading.equalTo(storeDistanceLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-18)
//            make.height.equalTo(18)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.systemBackground
        backgroundView.layer.cornerRadius = 10
        backgroundView.layer.masksToBounds = true
        backgroundView.frame = self.bounds.inset(by: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
        self.backgroundView = backgroundView
        self.backgroundColor = .clear
    }
    
    func updateFavoriteButton(isFavorited: Bool) {
        let imageName = isFavorited ? "star.fill" : "star"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        favoriteButton.tintColor = isFavorited ? .systemYellow : .gray
    }
}
