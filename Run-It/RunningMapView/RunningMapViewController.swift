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

class RunningMapViewController: UIViewController, MKMapViewDelegate {
    
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
    
    lazy var mapView: MKMapView = {
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
    
    lazy var currentLocationButton: UIButton = {
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
    
    lazy var storeListButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemIndigo
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.configuration = config
        button.layer.cornerRadius = 25
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.addTarget(self, action: #selector(TappedstoreListButton), for: .touchUpInside)
        return button
    }()
    
    lazy var convenienceStoreButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemPink
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "storefront")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.configuration = config
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.alpha = 0.0
        button.addTarget(self, action: #selector(presentStoreAnnotationButton), for: .touchUpInside)
        return button
    }()
    
    lazy var cafeButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemPink
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "cup.and.saucer")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.configuration = config
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.alpha = 0.0
        button.addTarget(self, action: #selector(presentStoreAnnotationButton), for: .touchUpInside)
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
    
    //MARK: - 전역 변수 선언
    var routeLine = MKPolyline()
    var currentCircle: MKCircle?
    var currentLocation: CLLocation?
    var destination: CLLocationCoordinate2D?
    
    var startPin: MKPointAnnotation?
    var endPin: MKPointAnnotation?
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        mapView.delegate = self
        addSubview()
        setLayout()
        RunningTimerLocationManager.shared.getLocationUsagePermission() //viewDidLoad 되었을 때 권한요청을 할 것인지, 현재 위치를 눌렀을 때 권한요청을 할 것인지
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        RunningTimerLocationManager.shared.stopUpdatingLocation()  // 러닝 중에 지도가 보인다면, viewWillDisappear 할 때 stopUpdatingLocation()가 호출되면 안됨.
    }
    
    //MARK: - @objc functions
    @objc private func TappedstartRunningButton() {
        print("TappedstartRunningButton()")
        let startRunningViewController =  StartRunningViewController()
        startRunningViewController.modalPresentationStyle = .fullScreen
        self.present(startRunningViewController, animated: true)
        
    }
    
    @objc func currentLocationButtonAction() {
        //        RunningTimerLocationManager.shared.getLocationUsagePermission()  //viewDidLoad 되었을 때 권한요청을 할 것인지, 현재 위치를 눌렀을 때 권한요청을 할 것인지
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        print("확인")
    }
    
    @objc private func TappedstoreListButton() {
        isActive.toggle()
    }
    
    @objc func presentStoreAnnotationButton() {
        getAnnotationLocation()
        //        if mapView.annotations.count > 0 {
        //            removeAnnotationsFromMap()
        //
        //        } else {
        //            getAnnotationLocation()
        //        }
        //        let storeViewController = StoreViewController()
        //        showMyViewControllerInACustomizedSheet(storeViewController)
    }
    
}

//MARK: - Annotation Setup
extension RunningMapViewController {
    
    private func getAnnotationLocation() {
        guard let currentLocation = self.mapView.userLocation.location else {
            print("Failed to get user location")
            return
        }
        
        let Searchrequest = MKLocalSearch.Request()
        Searchrequest.naturalLanguageQuery = "GS25" // 원하는 POI 유형을 검색어로 지정
        //        request.region = mapView.region // 검색 범위를 지정
        Searchrequest.region = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 150, longitudinalMeters: 150) // 150m 범위를 지정
        
        let search = MKLocalSearch(request: Searchrequest)
        search.start { (response, error) in
            guard let response = response else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            for item in response.mapItems {
                // 검색한 POI를 지도에 추가
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    private func removeAnnotationsFromMap() {
        // mapView.annotations 배열에서 MKUserLocation 인스턴스를 제외하고 모두 제거
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations(annotationsToRemove)
        
        // mapView.overlays 배열에서 currentCircle를 제외하고 모두 제거
        let overlaysToRemove = mapView.overlays.filter { $0 !== currentCircle }
        mapView.removeOverlays(overlaysToRemove)
    }
    
} //extension

//MARK: - CLLocationManagerDelegate
extension RunningMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentLocation = location
            
            // 이전에 추가된 원을 제거
            if let currentCircle = currentCircle {
                mapView.removeOverlay(currentCircle)
            }
            
            // 새로운 원을 추가
            let circle = MKCircle(center: location.coordinate, radius: 150)
            mapView.addOverlay(circle)
            self.currentCircle = circle
            
            if let destination = destination {
                let userLocation = location.coordinate  // 사용자의 위치에 기기의 마지막 위경도를 주입
                
                calculateAndShowRoute(from: userLocation, to: destination)
            }
        }
    }
    
    // 사용자의 현재 위치를 기반으로 경로를 계산하고 지도에 표시하는 메서드
    private func calculateAndShowRoute(from userLocation: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        
        mapView.removeOverlays(mapView.overlays)
        
        if let startPin = startPin, let annotationToRemove = mapView.annotations.first(where: { $0.coordinate.latitude == startPin.coordinate.latitude && $0.coordinate.longitude == startPin.coordinate.longitude }) {
            mapView.removeAnnotation(annotationToRemove)
        }
        if let endPin = endPin, let annotationToRemove = mapView.annotations.first(where: { $0.coordinate.latitude == endPin.coordinate.latitude && $0.coordinate.longitude == endPin.coordinate.longitude }) {
            mapView.removeAnnotation(annotationToRemove)
        }
        
        // MKDirectionsRequest를 사용하여 경로를 요청
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
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
            
            // 경로를 지도에 추가
            self.mapView.addOverlay(route.polyline)
            
            // 경로가 모두 표시되도록 지도를 조정
            let region = MKCoordinateRegion(route.polyline.boundingMapRect)
            self.mapView.setRegion(region, animated: true)
            
            // 출발점과 목적지에 커스텀 애노테이션을 추가
            self.addCustomPins(userLocation: userLocation, destination: destination)
        }
    }
    
    private func addCustomPins(userLocation: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        startPin = MKPointAnnotation()
        endPin = MKPointAnnotation()
        
        if let startPin = startPin {
            startPin.title = "start"
            startPin.coordinate = userLocation
            mapView.addAnnotation(startPin)
        }
        
        if let endPin = endPin {
            endPin.title = "end"
            endPin.coordinate = destination
            mapView.addAnnotation(endPin)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let annotation = view.annotation {
            
            // 사용자의 현재 위치에서 선택한 애노테이션까지의 경로를 계산하고 보여줌
            calculateAndShowRoute(from: mapView.userLocation.coordinate, to: annotation.coordinate)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
    }
    
    
    // 지도에 경로 및 주변원을 표시하기 위해 MKMapViewDelegate에서 MKPolylineRenderer를 설정
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.systemIndigo // 경로의 색상을 설정
            renderer.lineCap = .round
            renderer.lineWidth = 5.0 // 경로의 두께를 설정합니다.
            return renderer
            // 지도에 서클을 표시하기 위해 MKCircle를 활용
        } else if let circleOverlay = overlay as? MKCircle {
            let renderer = MKCircleRenderer(circle: circleOverlay)
            renderer.fillColor = UIColor.systemIndigo.withAlphaComponent(0.2)
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    //지도에 표시될 annotation 아이콘 설정 매소드
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        switch annotation.title {
        case "end":
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "endPin")
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "endPin")
                annotationView?.image = UIImage(systemName: "figure.run")
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        case "start":
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "startPin")
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "startPin")
                annotationView?.image = UIImage(systemName: "figure.stand")
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        default:
            return nil
        }
    }
    
}
//MARK: - PopButton setup
extension RunningMapViewController {
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
                removeAnnotationsFromMap() // 지도에 표시된 MapItem을 삭제(사용자 위치 제외)
                
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
        storeListButton.layer.add(animation, forKey: nil)
    }
}
//MARK: - Layout setup
extension RunningMapViewController {
    private func addSubview() {
        view.addSubview(mapView)
        mapView.addOverlay(routeLine)
        view.addSubview(compassButton)
        view.addSubview(startRunningButton)
        view.addSubview(currentLocationButton)
        view.addSubview(storeListButton)
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
        storeListButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(currentLocationButton.snp.bottom).offset(20)
        }
        
        convenienceStoreButton.snp.makeConstraints {
            $0.top.equalTo(storeListButton.snp.bottom).offset(20)
            $0.centerX.equalTo(storeListButton)
        }
        
        startRunningButton.snp.makeConstraints {
            $0.width.height.equalTo(90)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-120)
        }
    }
    
    
}
