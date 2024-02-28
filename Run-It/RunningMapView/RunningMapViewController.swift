//
//  RunningViewController.swift
//  Running&Eat
//
//  Created by Jason Yang on 2/21/24.
//

import UIKit
import SnapKit
import MapKit
import CoreLocation

class RunningMapViewController: UIViewController, MKMapViewDelegate{
    
    // MARK: 변수
    var mapView: MKMapView = {
        let mapView = MKMapView()
        return mapView
    }()
    
    var runningButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .black
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "figure.run")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.configuration = config
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 45
        
        return button
    }()
    
    var currentLocationButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemCyan
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "location")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.configuration = config
        button.layer.cornerRadius = 25
        return button
    }()
    
    var amenitiesButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemPink
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.configuration = config
        button.layer.cornerRadius = 25
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.addTarget(self, action: #selector(didTapFloatingButton), for: .touchUpInside)
        return button
    }()
    
    var writeButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemPink
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "figure.run")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.configuration = config
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.alpha = 0.0
        return button
    }()
    
    private var isActive: Bool = false {
        didSet {
            showActionButtons()
        }
    }
    
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation() // startUpdate를 해야 didUpdateLocation 메서드가 호출됨.
        manager.delegate = self
        return manager
    }()
    
    // MARK: 라이프사이클
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubview()
        setLayout()
        getLocationUsagePermission()
        buttonActions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.locationManager.stopUpdatingLocation()
    }
    
    // MARK: 기능
    
    func runButtonAction() {
        
    }
    
    @objc func currentLocationButtonAction() {
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        print("확인")
    }
    
    @objc private func didTapFloatingButton() {
        isActive.toggle()
    }
    
    @objc func writeButtonAction() {
            
        let vc = AmenitiesViewController()
        
        vc.modalPresentationStyle = .pageSheet
            
        if let sheet = vc.sheetPresentationController {
                
            //지원할 크기 지정
            sheet.detents = [.medium(), .large()]
            //크기 변하는거 감지
            sheet.delegate = self
            
            //시트 상단에 그래버 표시 (기본 값은 false)
            sheet.prefersGrabberVisible = true
            
            //처음 크기 지정 (기본 값은 가장 작은 크기)
            //sheet.selectedDetentIdentifier = .large
            
            //뒤 배경 흐리게 제거 (기본 값은 모든 크기에서 배경 흐리게 됨)
            //sheet.largestUndimmedDetentIdentifier = .medium
        }
        
        present(vc, animated: true, completion: nil)
    }
    
    // 레이아웃
    func setLayout() {
        mapView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-90)
        }
        runningButton.snp.makeConstraints {
            $0.width.height.equalTo(90)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-120)
        }
        currentLocationButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(60)
        }
        amenitiesButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(currentLocationButton.snp.bottom).offset(20)
        }
        
        writeButton.snp.makeConstraints {
            $0.top.equalTo(amenitiesButton.snp.bottom).offset(20)
            $0.centerX.equalTo(amenitiesButton)
        }
    }
   
    func addSubview() {
        view.addSubview(mapView)
        mapView.mapType = .standard
        view.addSubview(runningButton)
        view.addSubview(currentLocationButton)
        view.addSubview(amenitiesButton)
        view.addSubview(writeButton)
    }
    
    private func popButtons() {
        if isActive {
            writeButton.layer.transform = CATransform3DMakeScale(0.4, 0.4, 1)
            UIView.animate(withDuration: 0.3, delay: 0.2, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.3, options: [.curveEaseInOut], animations: { [weak self] in
                guard let self = self else { return }
                self.writeButton.layer.transform = CATransform3DIdentity
                self.writeButton.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.15, delay: 0.2, options: []) { [weak self] in
                guard let self = self else { return }
                self.writeButton.layer.transform = CATransform3DMakeScale(0.4, 0.4, 0.1)
                self.writeButton.alpha = 0.0
            }
        }
    }
        
    private func rotateFloatingButton() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        let fromValue = isActive ? 0 : CGFloat.pi / 4
        let toValue = isActive ? CGFloat.pi / 4 : 0
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = 0.3
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        amenitiesButton.layer.add(animation, forKey: nil)
    }
    
    func showActionButtons() {
        popButtons()
        rotateFloatingButton()
    }
    
    // addTarget
    func buttonActions() {
        currentLocationButton.addTarget(self, action: #selector(currentLocationButtonAction), for: .touchUpInside)
        writeButton.addTarget(self, action: #selector(writeButtonAction), for: .touchUpInside)
    }
    
    
}

extension RunningMapViewController: CLLocationManagerDelegate {
    // 사용자에게 위치 관한 요청하기
    func getLocationUsagePermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    // 위치 정보 업데이트 받기
    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }
    // 오류 처리
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
        }
    }
    // 오류 처리
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error)")
    }
    // 위치 관한 상태 감지
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            startLocationUpdates()
            print("GPS 권한 설정됨")
        case .restricted, .notDetermined:
            print("GPS 권한 설정되지 않음")
            DispatchQueue.main.async {
                self.getLocationUsagePermission()
            }
        case .denied:
            print("GPS 권한 요청 거부됨")
            DispatchQueue.main.async {
                self.getLocationUsagePermission()
            }
        default:
            print("GPS: Default")
        }
    }
}

extension RunningMapViewController: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        //크기 변경 됐을 경우
        print(sheetPresentationController.selectedDetentIdentifier == .large ? "large" : "medium")
    }
}
    




