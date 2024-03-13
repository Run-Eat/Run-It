//
//  RecordViewCell.swift
//  Run-It
//
//  Created by t2023-m0024 on 2/26/24.
//

import UIKit
import SnapKit

class RecordViewCell: UITableViewCell {
    
    // MARK: - Properties
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "RecordCell")
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.systemGray6
        contentView.addSubview(dateLabel)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(timeLabel)
    }
    
    private func setupLayout() {
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(15)
            make.leading.equalTo(contentView.snp.leading).offset(18)
            make.trailing.equalTo(contentView.snp.trailing).offset(-18)
            make.height.equalTo(18)
        }

        distanceLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(10)
            make.trailing.equalTo(contentView.snp.trailing).offset(-18)
            make.height.equalTo(18)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel.snp.bottom).offset(5)
            make.trailing.equalTo(contentView.snp.trailing).offset(-18)
            make.height.equalTo(18)
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
        self.backgroundColor = .clear
    }
}

extension RecordViewCell {
    func configure(with viewModel: RunningRecordViewModel) {
        dateLabel.text = viewModel.labelText
        distanceLabel.text = String("\(viewModel.distanceText) km")
        timeLabel.text = String("\(viewModel.timeText) 분")
    }
}
