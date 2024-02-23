//
//  PauseRunningHalfModalViewController.swift
//  Run-It
//
//  Created by Jason Yang on 2/23/24.
//

import UIKit

class PauseRunningHalfModalViewController: UIViewController {
    //MARK: - UI properties
    
    let modaltopContainer : UIView = {
       let container = UIView()
        return container
    }()
    
    let modaltimeLabel: UILabel = {
        let label = UILabel()
        label.text = "시간"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 25)
        return label
    }()
    
    lazy var modaltimeNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "0:00:00"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 45)
        return label
    }()
    
    let modaltopSplitLine: UIView = {
        let line = UIView()
        line.alpha = 0.5
        line.backgroundColor = .gray
        return line
    }()
    
    let modaldistanceLabel: UILabel = {
        let label = UILabel()
        label.text = "거리"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 25)
        return label
    }()
    
    lazy var modaldistanceNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "0:00:00"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 45)
        return label
    }()
    
    let modalkilometerLabel: UILabel = {
        let label = UILabel()
        label.text = "킬로미터"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let modalpaceContainer = UIView()
    
    let modalmiddleSplitLine: UIView = {
        let line = UIView()
        line.alpha = 0.5
        line.backgroundColor = .gray
        return line
    }()
    
    let modalpaceLabel: UILabel = {
        let label = UILabel()
        label.text = "평균 페이스"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 25)
        return label
    }()
    
    lazy var modalpaceNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "0:00:00"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 45)
        return label
    }()
    let bottombuttonContainer = UIView()
    let restartbuttonContainer = UIView()
    
    lazy var restartRunningButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.tintColor = .black
        let configuration = UIImage.SymbolConfiguration(pointSize: 50)
        if let image = UIImage(systemName: "restart", withConfiguration: configuration) {
            button.setImage(image, for: .normal)
        }
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 50
        button.clipsToBounds = true
        
        button.addTarget(self, action: #selector(restartRunning), for: .touchUpInside)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(modallongPressrestartRunning))
        longPressGesture.minimumPressDuration = 3
        button.addGestureRecognizer(longPressGesture)

        return button
    }()
    
    let stopbuttonContainer = UIView()
    
    lazy var stopRunningButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.tintColor = .black
        let configuration = UIImage.SymbolConfiguration(pointSize: 50)
        if let image = UIImage(systemName: "stop.fill", withConfiguration: configuration) {
            button.setImage(image, for: .normal)
        }
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 50
        button.clipsToBounds = true
        
        button.addTarget(self, action: #selector(stopRunning), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        addModalSubview()
        setupModalUI()
        setModalLayout()
    }
    // MARK: - @objc
    @objc private func restartRunning() {
        print("TappedButton - restartRunning()")
    }
    
    @objc func modallongPressrestartRunning(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            UIView.animate(withDuration: 0.3, animations: {
                self.restartRunningButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { _ in
                self.restartRunning()
            }
        } else if sender.state == .ended || sender.state == .cancelled {
            UIView.animate(withDuration: 0.3, animations: {
                self.restartRunningButton.transform = CGAffineTransform.identity
            })
        }
    }
    
    @objc private func stopRunning() {
        print("TappedButton - stopRunning()")
    }
}

extension PauseRunningHalfModalViewController {

    // MARK: - setupUI
    private func setupModalUI() {
        view.backgroundColor = .white


    }

    // MARK: - addSubview
    private func addModalSubview() {

        
        view.addSubview(modaltopContainer)
        modaltopContainer.addSubview(modaltimeLabel)
        modaltopContainer.addSubview(modaltimeNumberLabel)
        modaltopContainer.addSubview(modaldistanceLabel)
        modaltopContainer.addSubview(modaldistanceNumberLabel)
        modaltopContainer.addSubview(modalkilometerLabel)
        modaltopContainer.addSubview(modaltopSplitLine)
        
        view.addSubview(modalpaceContainer)
        modalpaceContainer.addSubview(modalmiddleSplitLine)
        modalpaceContainer.addSubview(modalpaceLabel)
        modalpaceContainer.addSubview(modalpaceNumberLabel)

        view.addSubview(bottombuttonContainer)
        bottombuttonContainer.addSubview(restartbuttonContainer)
        bottombuttonContainer.addSubview(stopbuttonContainer)
        restartbuttonContainer.addSubview(restartRunningButton)
        stopbuttonContainer.addSubview(stopRunningButton)

    }

    // MARK: - Layout
    private func setModalLayout() {

        modaltimeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.leading.equalToSuperview().offset(10)
        }

        modaltimeNumberLabel.snp.makeConstraints { make in
            make.top.equalTo(modaltimeLabel.snp.bottom).offset(20)
            make.leading.equalTo(modaltimeLabel)
        }
        // topContainer의 정중앙에 수직의 선
        modaltopSplitLine.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(100)
            make.width.equalTo(1) //
        }
        
        modaldistanceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.leading.equalTo(modaltopSplitLine.snp.trailing).offset(10)
        }
        
        modaldistanceNumberLabel.snp.makeConstraints { make in
            make.top.equalTo(modaldistanceLabel.snp.bottom).offset(20)
            make.leading.equalTo(modaldistanceLabel)
        }
        modalkilometerLabel.snp.makeConstraints { make in
            make.top.equalTo(modaldistanceNumberLabel.snp.bottom).offset(5)
            make.centerX.equalTo(modaldistanceNumberLabel.snp.centerX)
        }
        
        
        modalpaceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview().offset(10)
        }

        modalpaceNumberLabel.snp.makeConstraints { make in
            make.top.equalTo(modalpaceLabel.snp.bottom).offset(10)
            make.leading.equalTo(modalpaceLabel.snp.leading)
        }
    

        modaltopContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.width.equalTo(360)
            make.height.equalTo(150)
        }

        modalpaceContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(modaltopContainer.snp.bottom)
            make.width.equalTo(360)
            make.height.equalTo(150)
        }

        modalmiddleSplitLine.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
            make.width.equalTo(350) //
        }
        
        bottombuttonContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(modalpaceContainer.snp.bottom)
            make.width.equalTo(360)
            make.height.equalTo(100)
        }
        
        restartbuttonContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(180)
            make.height.equalTo(100)
        }
        
        stopbuttonContainer.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(180)
            make.height.equalTo(100)
        }
        
        restartRunningButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        
        stopRunningButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        

    }
    

}
