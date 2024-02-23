//
//  RunningTimerViewController.swift
//  Running&Eat
//
//  Created by Jason Yang on 2/21/24.
//

import UIKit
import SwiftUI

import SnapKit

// MARK: - Preview
struct PreView: PreviewProvider {
    static var previews: some View {
        RunningTimerViewController().toPreview()
    }
}

#if DEBUG
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }
    
    func toPreview() -> some View {
        Preview(viewController: self)
    }
}
#endif

class RunningTimerViewController: UIViewController {
    
    //MARK: - UI properties
    
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
        label.text = "0:00:00"
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
        label.text = "0:00:00"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 100)
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
        button.tintColor = .black
        let configuration = UIImage.SymbolConfiguration(pointSize: 50)
        if let image = UIImage(systemName: "pause.fill", withConfiguration: configuration) {
            button.setImage(image, for: .normal)
        }
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 50
        button.clipsToBounds = true
        
        button.addTarget(self, action: #selector(pauseRunning), for: .touchUpInside)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPresspauseRunning))
        longPressGesture.minimumPressDuration = 3
        button.addGestureRecognizer(longPressGesture)

        return button
    }()
    
    let bottomView = UIView()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubview()
        setupUI()
        setLayout()
        
    }
    
    // MARK: - @objc
    @objc private func pauseRunning() {
        print("TappedButton - pauseRunning()")
    }
    
    @objc func longPresspauseRunning(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            UIView.animate(withDuration: 0.3, animations: {
                self.pauseRunningButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { _ in
                self.pauseRunning()
            }
        } else if sender.state == .ended || sender.state == .cancelled {
            UIView.animate(withDuration: 0.3, animations: {
                self.pauseRunningButton.transform = CGAffineTransform.identity
            })
        }
    }
    
    @objc private func stopRunning() {
        print("TappedButton - stopRunning()")
    }
}

extension RunningTimerViewController {

    // MARK: - setupUI
    private func setupUI() {

        view.backgroundColor = .systemGreen
        statusBarView.backgroundColor = .systemGreen
        bottomView.backgroundColor = .systemGreen
        
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
            make.leading.equalToSuperview().offset(10)
        }

        timeNumberLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(40)
            make.leading.equalTo(timeLabel)
        }

        paceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.trailing.equalTo(topSplitLine.snp.leading).offset(100)
        }

        paceNumberLabel.snp.makeConstraints { make in
            make.top.equalTo(paceLabel.snp.bottom).offset(40)
            make.trailing.equalTo(topSplitLine.snp.leading).offset(175)
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
            make.leading.equalTo(distanceLabel)
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
