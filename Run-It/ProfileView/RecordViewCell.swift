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
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .left
        label.textColor = UIColor.label
        return label
    }()
    
    lazy var userLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .left
        return label
    }()
    
    var recordDistance: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textAlignment = .left
        label.textColor = UIColor.label
        return label
    }()
    
    lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "킬로미터"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .left
        return label
    }()
    
    lazy var recordTime: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textAlignment = .left
        label.textColor = UIColor.label
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "시간"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .left
        return label
    }()
    
    lazy var userPace: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textAlignment = .left
        label.textColor = UIColor.label
        return label
    }()
    
    lazy var paceLabel: UILabel = {
        let label = UILabel()
        label.text = "평균 페이스"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .left
        return label
    }()
    
    lazy var routeImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.systemBackground
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16.0
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "RecordCell")
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 레이블과 이미지뷰를 초기화
        dateLabel.text = nil
        userLabel.text = nil
        recordDistance.text = nil
        distanceLabel.text = "킬로미터"
        recordTime.text = nil
        timeLabel.text = "시간"
        userPace.text = nil
        paceLabel.text = "평균 페이스"
        routeImage.image = nil
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.systemGray6
        contentView.addSubview(dateLabel)
        contentView.addSubview(userLabel)
        contentView.addSubview(routeImage)
        contentView.addSubview(stackView)
        setupRecordStackView()
    }
    
    private func setupRecordStackView() {
        let distanceStackView = UIStackView(arrangedSubviews: [recordDistance, distanceLabel])
        distanceStackView.axis = .vertical
        
        let paceStackView = UIStackView(arrangedSubviews: [userPace, paceLabel])
        paceStackView.axis = .vertical
        
        let timeStackView = UIStackView(arrangedSubviews: [recordTime, timeLabel])
        timeStackView.axis = .vertical
        
        stackView.addArrangedSubview(distanceStackView)
        stackView.addArrangedSubview(paceStackView)
        stackView.addArrangedSubview(timeStackView)

        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(routeImage.snp.bottom).offset(16)
            make.leading.equalTo(contentView.snp.leading).offset(16)
            make.trailing.equalTo(contentView.snp.trailing).offset(-16)
            make.bottom.lessThanOrEqualTo(contentView.snp.bottom).offset(-16)
        }
        
        routeImage.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(16)
            make.leading.equalTo(contentView.snp.leading).offset(16)
            make.width.height.equalTo(60)
            make.bottom.equalTo(stackView.snp.top).offset(-16)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(20)
            make.leading.equalTo(routeImage.snp.trailing).offset(16)
            make.height.equalTo(18)
        }
        
        userLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
            make.leading.equalTo(routeImage.snp.trailing).offset(16)
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
        if dateLabel.text != viewModel.dateText {
            dateLabel.text = viewModel.dateText
        }
        if userLabel.text != viewModel.labelText {
            userLabel.text = viewModel.labelText
        }
        if recordDistance.text != viewModel.distanceText {
            recordDistance.text = viewModel.distanceText
        }
        if recordTime.text != viewModel.timeText {
            recordTime.text = viewModel.timeText
        }
        if userPace.text != viewModel.paceText {
            userPace.text = viewModel.paceText
        }
        if let imageData = viewModel.routeImageData {
            DispatchQueue.global(qos: .userInitiated).async {
                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    self.routeImage.image = image
                }
            }
        }
        
    }
}
