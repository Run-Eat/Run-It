//
//  PauseRunningHalfModalViewController.swift
//  Run-It
//
//  Created by Jason Yang on 2/23/24.
//

import UIKit

class PauseRunningHalfModalViewController: UIViewController {
    //MARK: - UI properties
    
    var time: Int = 0
    var distance: Double = 0.0
    var pace: Double = 0.0
    
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
        label.text = "0:00"
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateModalUI()
    }

    // MARK: - @objc
    @objc private func restartRunning() {
        print("TappedButton - restartRunning()")
        
        let runningTimerViewController =  RunningTimerViewController()
        runningTimerViewController.modalPresentationStyle = .fullScreen

        runningTimerViewController.time = self.time
        runningTimerViewController.distance = self.distance
        runningTimerViewController.pace = self.pace
        self.present(runningTimerViewController, animated: true)
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
        
        let alert = UIAlertController(title: "운동을 완료하시겠습니까?", message: "근처 편의점에서 물 한잔 어떻신가요?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "운동 완료하기", style: .default, handler: { _ in
            let startRunningViewController =  StartRunningViewController()
            startRunningViewController.modalPresentationStyle = .fullScreen
            self.present(startRunningViewController, animated: true)
        }))
        
        //        // Core Data context를 가져옵니다.
        //        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        //
        //        // RunningData Entity의 새 인스턴스를 생성합니다.
        //        let runningData = NSEntityDescription.insertNewObject(forEntityName: "RunningData", into: context) as! RunningData
        //
        //        // 러닝 데이터를 설정합니다.
        //        runningData.time = Int32(self.time)
        //        runningData.distance = self.distance
        //        runningData.pace = self.pace
        //
        //        // 변경 사항을 저장합니다.
        //        do {
        //            try context.save()
        //        } catch {
        //            // 저장에 실패한 경우 에러를 출력합니다.
        //            print("Failed to save running data: \(error)")
        //        }
        
//        self.dismiss(animated: true, completion: nil)
        
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
        modaldistanceNumberLabel.text = String(format: "%.2f", distance)
        modalpaceNumberLabel.text = String(format: "%02d:%02d", paceMinutes, paceSeconds)
    }
    

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
