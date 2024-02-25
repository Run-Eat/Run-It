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
    
    lazy var startRunningButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.tintColor = .black
        let configuration = UIImage.SymbolConfiguration(pointSize: 50)
        if let image = UIImage(systemName: "figure.run", withConfiguration: configuration) {
            button.setImage(image, for: .normal)
        }
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 50
        button.clipsToBounds = true
        
        button.addTarget(self, action: #selector(TappedstartRunningButton), for: .touchUpInside)
        return button
    }()
    
    var countdownTimer: Timer?
    var countdownSeconds = 3
    
    lazy var timerCounterView: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 100)
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

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - @objc
    @objc private func TappedstartRunningButton() {
        print("TappedstartRunningButton()")
//        let runningTimerViewController =  RunningTimerViewController()
//        runningTimerViewController.modalPresentationStyle = .fullScreen
//        self.present(runningTimerViewController, animated: true)
        startRunningButton.isHidden = true
        timerCounterView.isHidden = false // 타이머 뷰를 보여줍니다
        startCountdownTimer()
    }


}

extension StartRunningViewController {
    
    private func addSubview() {
        view.addSubview(startRunningButton)
        view.addSubview(timerCounterView)

    }
    private func setupUI() {
        view.backgroundColor = .white
    }
    private func setLayout() {
        
        startRunningButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        
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
            
            let runningTimerViewController =  RunningTimerViewController()
            runningTimerViewController.modalPresentationStyle = .fullScreen
            self.present(runningTimerViewController, animated: true)
        }
    }
    
}
