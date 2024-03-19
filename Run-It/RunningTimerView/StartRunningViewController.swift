//
//  StartRunningViewController.swift
//  Run-It
//
//  Created by Jason Yang on 2/25/24.
//

import UIKit

import SnapKit


class StartRunningViewController: UIViewController {
    //MARK: - UI properties
    
    var countdownTimer: Timer?
    var countdownSeconds = 3
    
    lazy var timerCounterView: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Arial Rounded MT Bold", size: 200)
        label.textColor = .systemYellow
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubview()
        setupUI()
        setLayout()
        TappedstartRunningButton()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - @objc
    @objc private func TappedstartRunningButton() {
        print("TappedstartRunningButton()")
        timerCounterView.isHidden = false // 타이머 뷰를 보여줍니다
        startCountdownTimer()
    }


}

extension StartRunningViewController {
    
    private func addSubview() {

        view.addSubview(timerCounterView)

    }
    private func setupUI() {
        view.backgroundColor = .systemTeal
    }
    private func setLayout() {
        
        timerCounterView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    
    private func startCountdownTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    @objc private func updateCounter() {
        if countdownSeconds > 0 {
            timerCounterView.text = "\(countdownSeconds)"
            countdownSeconds -= 1
        } else {
            countdownTimer?.invalidate()
            countdownTimer = nil
            countdownSeconds = 3 // 다음 번 카운트다운을 위해 시간을 초기화합니다
            timerCounterView.isHidden = true // 카운트다운이 끝나면 타이머 뷰를 숨깁니다
            
            let runningTimerToMapViewPageController =  RunningTimerToMapViewPageController()
            runningTimerToMapViewPageController.modalPresentationStyle = .fullScreen
            self.present(runningTimerToMapViewPageController, animated: true)
        }
    }
    
}
