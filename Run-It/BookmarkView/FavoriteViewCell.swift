//
//  FavoriteViewCell.swift
//  Run-It
//
//  Created by t2023-m0024 on 3/4/24.
//

import UIKit
import SnapKit

class FavoriteViewCell: UITableViewCell {
    // MARK: - Properties
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var adressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .right
        return label
    }()
    
    lazy var storeImage: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "FavoriteCell")
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Cell Configuration
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupUI() {
        backgroundColor = UIColor.systemGray6
        contentView.addSubview(nameLabel)
        contentView.addSubview(adressLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(storeImage)
    }
    
    func configure(with viewModel: FavoritesViewModel) {
        nameLabel.text = viewModel.storeText
        adressLabel.text = viewModel.addressText
        categoryLabel.text = viewModel.categoryText
        let imageName = viewModel.imageForCategory()
        storeImage.image = UIImage(named: imageName)
    }
    private func setupLayout() {
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(15)
            make.leading.equalTo(contentView.snp.leading).offset(16)
            make.trailing.equalTo(storeImage.snp.leading).offset(-16)
            make.height.equalTo(18)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalTo(contentView.snp.leading).offset(16)
            make.height.equalTo(18)
        }
        
        adressLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(4)
            make.leading.equalTo(contentView.snp.leading).offset(16)
            make.trailing.equalTo(storeImage.snp.leading).offset(-16)
            make.height.equalTo(60)
        }
        
        storeImage.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(16)
            make.trailing.equalTo(contentView.snp.trailing).offset(-16)
            make.width.height.equalTo(90)
        }

        
    }
    // MARK: - Layout & Drawing
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.systemBackground
        backgroundView.layer.cornerRadius = 10
        backgroundView.layer.masksToBounds = true
        backgroundView.frame = self.bounds.inset(by: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
        self.backgroundView = backgroundView
    }
}
