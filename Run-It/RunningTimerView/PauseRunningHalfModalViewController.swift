//
//  PauseRunningHalfModalViewController.swift
//  Run-It
//
//  Created by Jason Yang on 2/23/24.
//
protocol PauseRunningHalfModalViewControllerDelegate: AnyObject {
    func didDismissPauseRunningHalfModalViewController()
}

import UIKit
import CoreLocation

class PauseRunningHalfModalViewController: UIViewController {
    
    let runningTimer = RunningTimer()
    
    weak var delegate: PauseRunningHalfModalViewControllerDelegate?
    //MARK: - UI properties
    var time: Int = 0
    var distance: Double = 0.0
    var pace: Double = 0.0
    var routeImage: Data = Data()
    var id: UUID = UUID()
    
    let modaltopContainer : UIView = {
        let container = UIView()
        return container
    }()
    
    let modaltimeLabel: UILabel = {
        let label = UILabel()
        label.text = "시간"
        label.textColor = UIColor.label
        label.font = UIFont.systemFont(ofSize: 25)
        return label
    }()
    
    lazy var modaltimeNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "0:00:00"
        label.textColor = UIColor.label
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
        label.textColor = UIColor.label
        label.font = UIFont.systemFont(ofSize: 25)
        return label
    }()
    
    lazy var modaldistanceNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "0:00:00"
        label.textColor = UIColor.label
        label.font = UIFont.systemFont(ofSize: 45)
        return label
    }()
    
    let modalkilometerLabel: UILabel = {
        let label = UILabel()
        label.text = "킬로미터"
        label.textColor = UIColor.label
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
        label.textColor = UIColor.label
        label.font = UIFont.systemFont(ofSize: 25)
        return label
    }()
    
    lazy var modalpaceNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "0:00"
        label.textColor = UIColor.label
        label.font = UIFont.systemFont(ofSize: 45)
        return label
    }()
    let bottombuttonContainer = UIView()
    let restartbuttonContainer = UIView()
    
    lazy var restartRunningButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.tintColor = .white
        let configuration = UIImage.SymbolConfiguration(pointSize: 50)
        if let image = UIImage(systemName: "restart", withConfiguration: configuration) {
            button.setImage(image, for: .normal)
        }
        button.backgroundColor = .systemBlue
        button.layer.shadowRadius = 15
        button.layer.shadowOpacity = 0.3
        button.layer.cornerRadius = 50
        button.clipsToBounds = true
        
        button.addTarget(self, action: #selector(restartRunning), for: .touchUpInside)
        
        return button
    }()
    
    let stopbuttonContainer = UIView()
    
    lazy var stopRunningButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.tintColor = .white
        let configuration = UIImage.SymbolConfiguration(pointSize: 50)
        if let image = UIImage(systemName: "stop.fill", withConfiguration: configuration) {
            button.setImage(image, for: .normal)
        }
        button.backgroundColor = .systemRed
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateModalUI()
    }
    
    // MARK: - @objc
    @objc private func restartRunning() {
        print("TappedButton - restartRunning()")
        self.runningTimer.restart()
        self.dismiss(animated: true) {
            self.delegate?.didDismissPauseRunningHalfModalViewController()
        }
        
        
    }
    
    
    @objc private func stopRunning() {
        // 운동 기록 정보 출력
        print("TappedButton - stopRunning()")
        print("stop Time: \(self.time), Distance: \(self.distance), Pace: \(self.pace), routeImage: String(\(self.routeImage))")
        
        // 타이머와 위치 업데이트 중지
        self.runningTimer.stop()
        RunningTimerLocationManager.shared.stopUpdatingLocation()
        
        // 운동 완료 알림창 표시
        presentCompletionAlert()
    }
    
    func presentCompletionAlert() {
        let alert = UIAlertController(title: "운동을 완료하시겠습니까?", message: "근처 편의점에서 물 한잔 어떻신가요?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "운동 완료하기", style: .default, handler: { _ in
            let locations = RunningTimerLocationManager.shared.getLocations()
            
            // 맵 스냅샷 생성
            MapSnapshotManager.createSnapshot(for: locations) { [weak self] image in
                guard let self = self, let image = image, let imageData = image.pngData() else {
                    print("Failed to create route image snapshot.")
                    return
                }
                
                // 스냅샷 이미지 데이터와 함께 코어 데이터에 러닝 기록 저장
                if let recordId = CoreDataManager.shared.createRunningRecord(time: self.time, distance: self.distance, pace: self.pace, routeImage: imageData) {
                    print("Running record with route saved successfully. Record ID: \(recordId)")
                } else {
                    print("Failed to save running record with route image.")
                }
            }
            
            let mainTabBarViewController = MainTabBarViewController()
            mainTabBarViewController.modalPresentationStyle = .fullScreen
            self.present(mainTabBarViewController, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "취소하기", style: .destructive, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension PauseRunningHalfModalViewController {
    
    // MARK: - Running Timer Method
    private func updateModalUI() {
        // 시간, 거리, 페이스를 포맷에 맞게 변환
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = (time % 3600) % 60
        
        let paceMinutes = Int(pace) / 60
        let paceSeconds = Int(pace) % 60
        
        // 레이블의 텍스트를 설정
        modaltimeNumberLabel.text = String(format: "%01d:%02d:%02d", hours, minutes, seconds)
        modaldistanceNumberLabel.text = String(format: "%.2f", distance / 1000)
        modalpaceNumberLabel.text = String(format: "%02d:%02d", paceMinutes, paceSeconds)
    }
    
    
    // MARK: - setupUI
    private func setupModalUI() {
        view.backgroundColor = .systemBackground
        
        
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
            make.top.equalTo(modaldistanceNumberLabel.snp.bottom).offset(2)
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
