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
    
    //MARK: - UI Properties
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation() // startUpdate를 해야 didUpdateLocation 메서드가 호출됨.
        manager.delegate = self
        manager.allowsBackgroundLocationUpdates = true
        manager.showsBackgroundLocationIndicator = true
        return manager
    }()
    
    var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.isRotateEnabled = true
        mapView.mapType = MKMapType.standard
        mapView.showsCompass = false
        return mapView
    }()
    
    lazy var compassButton: MKCompassButton = {
        let compassButton = MKCompassButton(mapView: self.mapView)
        compassButton.compassVisibility = .visible
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        compassButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        return compassButton
    }()
    
    var currentLocationButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemCyan
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "location")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.configuration = config
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(currentLocationButtonAction), for: .touchUpInside)
        return button
    }()
    
    var storeButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemIndigo
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.configuration = config
        button.layer.cornerRadius = 25
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.addTarget(self, action: #selector(didTapFloatingButton), for: .touchUpInside)
        return button
    }()
    
    var convenienceStoreButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemPink
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "storefront")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.configuration = config
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.alpha = 0.0
        button.addTarget(self, action: #selector(storeHalfModalButtonAction), for: .touchUpInside)
        return button
    }()
    
    private var isActive: Bool = false {
        didSet {
            showActionButtons()
        }
    }
    
    private var animation: UIViewPropertyAnimator? //회전 버튼 프로퍼티
    
    lazy var startRunningButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.tintColor = .white
        let configuration = UIImage.SymbolConfiguration(pointSize: 50)
        if let image = UIImage(systemName: "figure.run", withConfiguration: configuration) {
            button.setImage(image, for: .normal)
        }
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = 45
        button.clipsToBounds = true
        
        button.addTarget(self, action: #selector(TappedstartRunningButton), for: .touchUpInside)
        return button
    }()
    
    var routeLine: MKPolyline?
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubview()
        setLayout()
        getLocationUsagePermission()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.locationManager.stopUpdatingLocation()
    }
    
    //MARK: - @objc functions
    @objc private func TappedstartRunningButton() {
        print("TappedstartRunningButton()")
        let startRunningViewController =  StartRunningViewController()
        startRunningViewController.modalPresentationStyle = .fullScreen
        self.present(startRunningViewController, animated: true)

    }
    
    @objc func currentLocationButtonAction() {
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        print("확인")
    }
    
    @objc private func didTapFloatingButton() {
        isActive.toggle() //
    }
    
    @objc func storeHalfModalButtonAction() {
        let storeViewController = StoreViewController()
        showMyViewControllerInACustomizedSheet(storeViewController)
    }
    
    private func showActionButtons() {
        popButtons()
        rotateFloatingButton()
    }
    
    private func popButtons() {
        if isActive {
            convenienceStoreButton.layer.transform = CATransform3DMakeScale(0.4, 0.4, 1)
            UIView.animate(withDuration: 0.3, delay: 0.2, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.3, options: [.curveEaseInOut], animations: { [weak self] in
                guard let self = self else { return }
                self.convenienceStoreButton.layer.transform = CATransform3DIdentity
                self.convenienceStoreButton.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.15, delay: 0.2, options: []) { [weak self] in
                guard let self = self else { return }
                self.convenienceStoreButton.layer.transform = CATransform3DMakeScale(0.4, 0.4, 0.1)
                self.convenienceStoreButton.alpha = 0.0
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
        storeButton.layer.add(animation, forKey: nil)
    }
    


}

//MARK: - Layout setup
extension RunningMapViewController {
    private func addSubview() {
        view.addSubview(mapView)
        view.addSubview(compassButton)
        view.addSubview(startRunningButton)
        view.addSubview(currentLocationButton)
        view.addSubview(storeButton)
        view.addSubview(convenienceStoreButton)
    }
    
    private func setLayout() {
        mapView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        compassButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(120)
        }
        
        currentLocationButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(compassButton.snp.bottom).offset(20)
        }
        storeButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(currentLocationButton.snp.bottom).offset(20)
        }
        
        convenienceStoreButton.snp.makeConstraints {
            $0.top.equalTo(storeButton.snp.bottom).offset(20)
            $0.centerX.equalTo(storeButton)
        }
        
        startRunningButton.snp.makeConstraints {
            $0.width.height.equalTo(90)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-120)
        }
    }
    
    
} // extension

//MARK: - CLLocationManagerDelegate
extension RunningMapViewController: CLLocationManagerDelegate {
    // 사용자에게 위치 관한 요청하기
    func getLocationUsagePermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    // 위치 정보 업데이트 받기
    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
            let userLocation = location.coordinate
            
            calculateAndShowRoute(from: userLocation)
        }
    }
    // 사용자의 현재 위치를 기반으로 경로를 계산하고 지도에 표시하는 메서드
    func calculateAndShowRoute(from userLocation: CLLocationCoordinate2D) {
        // 예를 들어, 사용자의 현재 위치로부터 목적지(서울역)까지의 경로를 계산
        let destinationCoordinate = CLLocationCoordinate2D(latitude: 37.554722, longitude: 126.970833)
        
        // MKDirectionsRequest를 사용하여 경로를 요청
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        request.transportType = .walking // 적절한 이동 수단을 선택
        
        // MKDirections를 사용하여 경로를 추적
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else {
                if let error = error {
                    print("Error calculating route: \(error.localizedDescription)")
                }
                return
            }
            
            // 경로를 지도에 추가합니다.
            self.mapView.addOverlay(route.polyline)
            
            // 경로가 모두 표시되도록 지도를 조정합니다.
            let region = MKCoordinateRegion(route.polyline.boundingMapRect)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    // 지도에 경로를 표시하기 위해 MKMapViewDelegate에서 MKPolylineRenderer를 설정
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.systemIndigo // 경로의 색상을 설정
            renderer.lineWidth = 3 // 경로의 두께를 설정합니다.
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
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
