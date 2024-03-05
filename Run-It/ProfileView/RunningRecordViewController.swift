//
//  RunningRecordViewController.swift
//  Run-It
//
//  Created by t2023-m0024 on 2/29/24.
//

import UIKit
import SnapKit

#if DEBUG
import SwiftUI
struct RPreview: UIViewControllerRepresentable {
    
    // 여기 ViewController를 변경해주세요
    func makeUIViewController(context: Context) -> UIViewController {
        RunningRecordViewController()
    }
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
}

struct RunningRecordViewController_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            RPreview()
                .edgesIgnoringSafeArea(.all)
                .previewDisplayName("Preview")
                .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
        }
    }
}
#endif

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
    
    var recordTextField: UITextField = {
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
        
        editButton.addTarget(RunningRecordViewController.self, action: #selector(editButtonTapped), for: .touchUpInside)
        
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 24)) // 오른쪽 뷰 크기 설정
        rightView.addSubview(editButton)
        editButton.center = rightView.center
        
        textField.rightView = rightView
        textField.rightViewMode = .always
        
        textField.returnKeyType = .done
        
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
        return imageView
    }()
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        recordTextField.text = userDate.text
        recordTextField.delegate = self
        // 텍스트 필드 편집 상태 감지를 위한 옵저버 추가
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidBeginEditing), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidEndEditing), name: UITextField.textDidEndEditingNotification, object: nil)
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
//        routeImage.image = viewModel.routeImageData.flatMap(UIImage.init)
        if let imageData = viewModel.routeImageData {
            routeImageView.image = UIImage(data: imageData)
        } else {
            routeImageView.image = nil // Or set a placeholder image
        }
    }
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Assume textField is recordTextField and it's editing the label
        if let newText = textField.text, !newText.isEmpty {
            // Update the viewModel and persist the new label
            viewModel.updateLabelText(newLabelText: newText)
            print("라벨 저장")
            
            // Optionally, refresh UI elements that depend on labelText
            // e.g., if you have a UILabel that displays labelText
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - @objc
    @objc func editButtonTapped(sender: UIButton) {
        if recordTextField.isFirstResponder {
            recordTextField.resignFirstResponder() // Hide keyboard and end editing mode
            recordTextField.text = "" // Clear text field content
            sender.setImage(UIImage(systemName: "pencil"), for: .normal) // Change icon to pencil
        } else {
            recordTextField.becomeFirstResponder() // Set text field to editing mode
            sender.setImage(UIImage(systemName: "xmark"), for: .normal) // Change icon to X
        }
    }

    @objc private func textFieldDidBeginEditing(notification: NSNotification) {
        // 텍스트 필드가 편집 모드일 때 X 아이콘으로 변경
        if let textField = notification.object as? UITextField, textField == recordTextField {
            let rightButton = textField.rightView?.subviews.compactMap { $0 as? UIButton }.first
            rightButton?.setImage(UIImage(systemName: "xmark"), for: .normal)
        }
    }
    
    @objc private func textFieldDidEndEditing(notification: NSNotification) {
        // 텍스트 필드 편집이 종료될 때 펜슬 아이콘으로 변경
        if let textField = notification.object as? UITextField, textField == recordTextField {
        }
    }
}
