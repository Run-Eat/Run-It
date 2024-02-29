//
//  EventViewCell.swift
//  Run-It
//
//  Created by t2023-m0024 on 2/25/24.
//

import UIKit
import SnapKit

class EventViewCell: UITableViewCell {
    
    // MARK: - Properties
    var cellImageView = UIImageView()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "EventCell")
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        backgroundColor = UIColor.white
        contentView.addSubview(cellImageView)
    }
    
    private func setupLayout() {
        cellImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(0)
            make.bottom.equalTo(contentView.snp.bottom).offset(0)
            make.left.equalTo(contentView.snp.left).offset(0)
            make.right.equalTo(contentView.snp.right).offset(0)
        }
        cellImageView.clipsToBounds = true
        cellImageView.contentMode = .scaleAspectFill
    }
    
    // MARK: - Layout & Drawing
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let cellSpacing: CGFloat = 8
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: cellSpacing, left: 0, bottom: cellSpacing, right: 0))
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
}
