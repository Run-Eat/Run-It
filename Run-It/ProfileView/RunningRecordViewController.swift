//
//  RunningRecordViewController.swift
//  Run-It
//
//  Created by t2023-m0024 on 2/29/24.
//

import UIKit
import SnapKit

class RunningRecordViewController: UIViewController, UITextFieldDelegate {
    // MARK: - Properties
    var viewModel: RunningRecordViewModel! {
        didSet {
            updateUI()
        }
    }
    
    var userDate: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .left
        return label
    }()
    
    lazy var recordTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.textAlignment = .left
        
        textField.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
        
        let editButton = UIButton(type: .system)
        editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        editButton.contentMode = .scaleAspectFit
        editButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        editButton.addTarget(self, action: #selector(editButtonTapped(sender:)), for: .touchUpInside)
        
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 24))
        rightView.addSubview(editButton)
        editButton.center = rightView.center
        
        textField.rightView = rightView
        textField.rightViewMode = .always
        
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        
        let underlineView = UIView()
        underlineView.backgroundColor = .gray
        textField.addSubview(underlineView)
        underlineView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        return textField
    }()
    
    var recordDistance: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 85)
        label.textAlignment = .left
        return label
    }()
    
    var distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "킬로미터"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .left
        return label
    }()
    
    var recordTime: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 45)
        label.textAlignment = .left
        return label
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "시간"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .left
        return label
    }()
    
    var userPace: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 45)
        label.textAlignment = .left
        return label
    }()
    
    var paceLabel: UILabel = {
        let label = UILabel()
        label.text = "평균 페이스"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .left
        return label
    }()
    
    var routeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.systemGreen
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        recordTextField.text = viewModel.labelText
        recordTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidBeginEditing), name: UITextField.textDidBeginEditingNotification, object: nil)
    }
    
    @objc func backButtonTapped() {
        self.dismiss(animated: true)
    }
    // MARK: - UI Setup
    private func setupView() {
        view.backgroundColor = .white
        navigationItem.title = "Run it"
        setupRecordStackView()
    }
    func setupRecordStackView(){
        let userInfoStackView = UIStackView(arrangedSubviews: [userDate, recordTextField])
        userInfoStackView.axis = .vertical
        userInfoStackView.spacing = 5.0
        
        let distanceStackView = UIStackView(arrangedSubviews: [recordDistance, distanceLabel])
        distanceStackView.axis = .vertical
        
        let timeStackView = UIStackView(arrangedSubviews: [recordTime, timeLabel])
        timeStackView.axis = .vertical
        
        let paceStackView = UIStackView(arrangedSubviews: [userPace, paceLabel])
        paceStackView.axis = .vertical
        
        let stackView = UIStackView(arrangedSubviews: [userInfoStackView, distanceStackView,timeStackView,paceStackView])
        stackView.axis = .vertical
        stackView.spacing = 16.0
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        view.addSubview(routeImageView)
        
        routeImageView.snp.makeConstraints{ make in
            make.top.equalTo(stackView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(202)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }
    // MARK: - UI업데이트
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        userDate.text = viewModel.dateText
        recordDistance.text = viewModel.distanceText
        recordTime.text = viewModel.timeText
        userPace.text = viewModel.paceText
        if let imageData = viewModel.routeImageData {
            routeImageView.image = UIImage(data: imageData)
        } else {
            routeImageView.image = nil // Or set a placeholder image
        }
    }
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let newText = textField.text, !newText.isEmpty {
            viewModel.updateLabelText(newLabelText: newText)
            print("라벨 저장")
        }
        
        textField.resignFirstResponder()
        
        if let rightButton = textField.rightView?.subviews.compactMap({ $0 as? UIButton }).first {
            rightButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        }
        return true
    }
    // MARK: - @objc
    @objc func editButtonTapped(sender: UIButton) {
        print("editButtonTapped called")
        DispatchQueue.main.async {
            if self.recordTextField.isFirstResponder {
                self.recordTextField.text = ""
                sender.setImage(UIImage(systemName: "pencil"), for: .normal)
            } else {
                self.recordTextField.becomeFirstResponder() // Set text field to editing mode
                sender.setImage(UIImage(systemName: "xmark"), for: .normal)
            }
        }
    }
    
    @objc private func textFieldDidBeginEditing(notification: NSNotification) {
        // 텍스트 필드가 편집 모드일 때 X 아이콘으로 변경
        if let textField = notification.object as? UITextField, textField == recordTextField {
            let rightButton = textField.rightView?.subviews.compactMap { $0 as? UIButton }.first
            rightButton?.setImage(UIImage(systemName: "xmark"), for: .normal)
        }
    }
}
