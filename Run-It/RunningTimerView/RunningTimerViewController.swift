//
//  RunningTimerViewController.swift
//  Running&Eat
//
//  Created by Jason Yang on 2/21/24.
//

import UIKit

import SnapKit

class RunningTimerViewController: UIViewController, PauseRunningHalfModalViewControllerDelegate {

    let runningTimer = RunningTimer()
    //MARK: - UI properties
    
    var distance: Double = 0
    var time: Int = 0
    var pace: Double = 0

    
    let statusBarView = UIView()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "시간"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 30)
        return label
    }()
    
    lazy var timeNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "0:00:00"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 45)
        return label
    }()
    
    let topContainer : UIView = {
       let container = UIView()
        return container
    }()
    
    
    let distanceContainer = UIView()
    
    let topSplitLine: UIView = {
        let line = UIView()
        line.alpha = 0.5
        line.backgroundColor = .gray
        return line
    }()
    
    let middleSplitLine: UIView = {
        let line = UIView()
        line.alpha = 0.5
        line.backgroundColor = .gray
        return line
    }()
    
    let paceLabel: UILabel = {
        let label = UILabel()
        label.text = "페이스"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 30)
        return label
    }()
    
    lazy var paceNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "0:00"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 45)
        return label
    }()
    
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "거리"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 30)
        return label
    }()
    
    lazy var distanceNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "0.00"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 100)
        label.adjustsFontSizeToFitWidth = false
        return label
    }()
    
    let kilometerLabel: UILabel = {
        let label = UILabel()
        label.text = "킬로미터"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 30)
        return label
    }()
    
    lazy var pauseRunningButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.tintColor = .white
        let configuration = UIImage.SymbolConfiguration(pointSize: 50)
        if let image = UIImage(systemName: "pause.fill", withConfiguration: configuration) {
            button.setImage(image, for: .normal)
        }
        button.backgroundColor = .systemBlue
        button.layer.shadowRadius = 15
        button.layer.shadowOpacity = 0.3
        button.layer.cornerRadius = 50
        button.clipsToBounds = true
        
        button.addTarget(self, action: #selector(pauseRunning), for: .touchUpInside)

        return button
    }()
    
    let bottomView = UIView()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubview()
        setupUI()
        setLayout()
        
        runningTimer.updateUI = { [weak self] in
            // 메인 스레드에서 UI 업데이트를 보장
            DispatchQueue.main.async {
                self?.time = self?.runningTimer.time ?? 0
                self?.distance = self?.runningTimer.distance ?? 0.0
                self?.pace = self?.runningTimer.pace ?? 0.0
                self?.updateTimerUI()
            }
        }
//        // 위치 업데이트 시작
        RunningTimerLocationManager.shared.startUpdatingLocation()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.runningTimer.start()
        if runningTimer.state == .suspended {
            runningTimer.start()
        } else if runningTimer.state == .background {
            runningTimer.timerEnterBackground()
        } else if runningTimer.state == .foreground {
            runningTimer.timerWillEnterForeground()
        }

    }
    
    // MARK: - @objc
    @objc private func pauseRunning() {
        print("TappedButton - pauseRunning()")
        self.runningTimer.pause()
        
        let pauseRunningHalfModalViewController = PauseRunningHalfModalViewController()
        pauseRunningHalfModalViewController.time = self.time
        pauseRunningHalfModalViewController.distance = self.distance
        pauseRunningHalfModalViewController.pace = self.pace
        pauseRunningHalfModalViewController.delegate = self

        
        showMyViewControllerInACustomizedSheet(pauseRunningHalfModalViewController)
    }
    
    func didDismissPauseRunningHalfModalViewController() {
        runningTimer.restart()
    }
    
}

extension RunningTimerViewController {
    
    // MARK: - Running Timer UI Update

    func updateTimerUI() {
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = (time % 3600) % 60
        timeNumberLabel.text = String(format: "%01d:%02d:%02d", hours, minutes, seconds)
        
        if pace > 0 { // 페이스가 0보다 클 때만 계산
            let paceMinutes = Int(pace) / 60
            let paceSeconds = Int(pace) % 60
            paceNumberLabel.text = String(format: "%02d:%02d", paceMinutes, paceSeconds)
        } else {
            // 페이스가 0 이하일 경우 대체 텍스트 표시
            paceNumberLabel.text = "--:--"
        }
        
        distanceNumberLabel.text = String(format: "%.2f", distance / 1000)
    }

    // MARK: - setupUI
    
    private func setupUI() {

        view.backgroundColor = .systemYellow
        statusBarView.backgroundColor = .systemYellow
        bottomView.backgroundColor = .systemYellow
        
        [statusBarView, bottomView].forEach { subView in view.addSubview(subView)
        }

    }

    // MARK: - addSubview
    private func addSubview() {
        
        view.addSubview(statusBarView)
        
        view.addSubview(topContainer)
        topContainer.addSubview(timeLabel)
        topContainer.addSubview(timeNumberLabel)
        topContainer.addSubview(paceLabel)
        topContainer.addSubview(paceNumberLabel)
        topContainer.addSubview(topSplitLine)
        
        view.addSubview(distanceContainer)
        distanceContainer.addSubview(middleSplitLine)
        distanceContainer.addSubview(distanceLabel)
        distanceContainer.addSubview(distanceNumberLabel)
        distanceContainer.addSubview(kilometerLabel)
        
        view.addSubview(pauseRunningButton)
        
        view.addSubview(bottomView)

    }

    // MARK: - Layout
    private func setLayout() {
        
        statusBarView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.leading.equalToSuperview().offset(2)
        }

        timeNumberLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(40)
            make.leading.equalTo(timeLabel)
        }

        paceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.trailing.equalToSuperview().offset(-10)
        }

        paceNumberLabel.snp.makeConstraints { make in
            make.top.equalTo(paceLabel.snp.bottom).offset(40)
            make.trailing.equalTo(paceLabel)
        }

        // topContainer의 정중앙에 수직의 선
        topSplitLine.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(150)
            make.width.equalTo(1) //
        }

        topContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.width.equalTo(360)
            make.height.equalTo(200)
        }

        distanceContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(topContainer.snp.bottom)
            make.width.equalTo(360)
            make.height.equalTo(330)
        }

        middleSplitLine.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
            make.width.equalTo(350) //
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.leading.equalToSuperview().offset(10)
        }
        distanceNumberLabel.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
        kilometerLabel.snp.makeConstraints { make in
            make.top.equalTo(distanceNumberLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        pauseRunningButton.snp.makeConstraints { make in
            make.top.equalTo(distanceContainer.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        
        bottomView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
        }

    }
    

}
