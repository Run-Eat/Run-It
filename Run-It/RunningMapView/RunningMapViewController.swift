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
import Combine

class CustomAnnotation: MKPointAnnotation {
    var mapItem: MKMapItem?
    var startPin: MKPointAnnotation?
    var endPin: MKPointAnnotation?
    var name: String?
    var address: String?
    var distance: Int?
    var category: String?
    let url: String = ""
}

enum PresentView {
    case inProgress
    case completed
}

class RunningMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    weak var parentVC: RunningTimerToMapViewPageController?
    
    var weatherViewModel = WeatherViewModel()
    var cancellables = Set<AnyCancellable>()
    
    //MARK: - UI Properties
    var favoritesViewModel: FavoritesViewModel!
//    var tabBarHeight: CGFloat = .zero
    
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.startUpdatingLocation() // startUpdate를 해야 didUpdateLocation 메서드가 호출됨.
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        manager.showsBackgroundLocationIndicator = true
        manager.pausesLocationUpdatesAutomatically = false
        
        return manager
    }()
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.isRotateEnabled = true
        mapView.mapType = MKMapType.standard
        mapView.showsCompass = false
//        mapView.userTrackingMode = .followWithHeading
        return mapView
    }()
    
    lazy var weatherContainer : UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.systemGray6
        container.layer.cornerRadius = 20
        container.layer.shadowOpacity = 0.3
        container.alpha = 0.8
        return container
    }()
    
    lazy var weatherSymbol: UIImageView = {
        let symbol = UIImageView()
        symbol.image = UIImage(systemName: "sun.max.trianglebadge.exclamationmark")
        symbol.tintColor = UIColor.label
        symbol.contentMode = .scaleToFill
        return symbol
    }()
    
    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.text = "ºC"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.label
        label.textAlignment = .center
        return label
    }()
    
    lazy var humidityLabel: UILabel = {
        let label = UILabel()
        label.text = "%"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    lazy var windspeedLabel: UILabel = {
        let label = UILabel()
        label.text = "km/h"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    lazy var uvIndexcategoryLabel: UILabel = {
        let label = UILabel()
        label.text = "uv"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    lazy var attributionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var compassButton: MKCompassButton = {
        let Button = MKCompassButton(mapView: self.mapView)
        Button.compassVisibility = .visible
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        Button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        Button.layer.shadowOpacity = 0.3
        return Button
    }()
    
    lazy var currentLocationButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .white
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "location")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.configuration = config
        button.layer.shadowOpacity = 0.3
        button.addTarget(self, action: #selector(currentLocationButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var storeListButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemBlue
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.configuration = config
        button.layer.cornerRadius = 25
        button.layer.shadowOpacity = 0.3
        button.addTarget(self, action: #selector(TappedstoreListButton), for: .touchUpInside)
        return button
    }()
    
    lazy var convenienceStoreButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemIndigo
        config.image = UIImage(systemName: "drop")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .medium))
        config.cornerStyle = .capsule
        button.configuration = config
        button.layer.cornerRadius = 25
        button.layer.shadowOpacity = 0.3
        button.addTarget(self, action: #selector(presentConvenienceStoreAnnotations), for: .touchUpInside)
        return button
    }()

    lazy var coffeeAndBakeryFranchisesButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemIndigo
        config.image = UIImage(systemName: "cup.and.saucer")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .medium))
        config.cornerStyle = .capsule
        button.configuration = config
        button.layer.cornerRadius = 25
        button.layer.shadowOpacity = 0.3
        button.addTarget(self, action: #selector(presentcoffeeAndBakeryFranchisesAnnotations), for: .touchUpInside)
        return button
    }()

    lazy var healthyEatingOptionsButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemIndigo
        config.image = UIImage(systemName: "takeoutbag.and.cup.and.straw")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .medium))
        config.cornerStyle = .capsule
        button.configuration = config
        button.layer.cornerRadius = 25
        button.layer.shadowOpacity = 0.3
        button.addTarget(self, action: #selector(presenthealthyEatingOptionsAnnotations), for: .touchUpInside)
        return button
    }()
    
    private var isActive: Bool = true {
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
        button.backgroundColor = .systemTeal
        button.layer.shadowRadius = 15
        button.layer.shadowOpacity = 0.3
        button.layer.cornerRadius = 45
        button.addTarget(self, action: #selector(TappedstartRunningButton), for: .touchUpInside)
        return button
    }()
    
    lazy var backToRunningTimerViewButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.tintColor = .white
        let configuration = UIImage.SymbolConfiguration(pointSize: 50)
        if let image = UIImage(systemName: "restart", withConfiguration: configuration) {
            button.setImage(image, for: .normal)
        }
        button.backgroundColor = .systemTeal
        button.layer.shadowRadius = 15
        button.layer.shadowOpacity = 0.3
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.isHidden = true
        button.addTarget(self, action: #selector(backToRunningTimerView), for: .touchUpInside)
        return button
    }()

    //MARK: - 전역 변수 선언
    var currentCircle: MKCircle?
    var currentPolyLine: MKPolyline?
    var currentLocation: CLLocation?
    var destination: CLLocationCoordinate2D?
    
    var locations: [CLLocation] = []
    
    // CustomAnnotation 클래스로 초기화
    var startPin: CustomAnnotation?
    var endPin: CustomAnnotation?
    
    var storeVC: StoreViewController?
    
    var searchResultsCache: [String: [MKMapItem]] = [:]
    
    var presentationState = PresentView.completed
    
    var loadingIndicator: UIActivityIndicatorView?
    
    let generator = UIImpactFeedbackGenerator(style: .heavy)

    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addSubview()
        setLayout()
        mapView.delegate = self
        locationManager.delegate = self
        RunningTimerLocationManager.shared.getLocationUsagePermission() //viewDidLoad 되었을 때 권한요청을 할 것인지, 현재 위치를 눌렀을 때 권한요청을 할 것인지
        favoritesViewModel = FavoritesViewModel()
        RunningTimerLocationManager.shared.resetActivityTimer()
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        setupAttribution()
        weatherViewModel.loadWeatherAttribution()
    }
    
    //MARK: - @objc functions
    @objc private func TappedstartRunningButton() {
        print("TappedstartRunningButton()")
        generator.impactOccurred()
        // RunningTimerLocationManager 인스턴스의 위치 데이터 및 거리 초기화
        RunningTimerLocationManager.shared.resetLocationData()
        
        if let presentedVC = self.presentedViewController {
          presentedVC.dismiss(animated: true) {
            self.showStartRunningViewController()
          }
        } else {
          self.showStartRunningViewController()
        }
      }
      private func showStartRunningViewController() {
        let startRunningViewController = StartRunningViewController()
        startRunningViewController.modalPresentationStyle = .fullScreen
        self.present(startRunningViewController, animated: true)
      }
    
    @objc private func backToRunningTimerView() {
        closeModal()
        generator.impactOccurred()
        if let firstViewController = parentVC?.viewControllers.first {
            parentVC?.pageViewController.setViewControllers([firstViewController], direction: .reverse, animated: true, completion: nil)
        }
    }

    
    @objc func currentLocationButtonAction() {
        generator.impactOccurred()
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        weatherDatabindViewModel()
        print("확인")
    }
    
    @objc private func TappedstoreListButton() {
        generator.impactOccurred()
        isActive.toggle()
    }
    
    // 유저에게 편의전 옵션을 주고, 편의점 옵션을 선택해서 하프모달로 노출
    @objc func presentConvenienceStoreAnnotations() {
        generator.impactOccurred()
        let convenienceStores = ["GS25", "CU", "세븐일레븐", "이마트24", "미니스톱"]
        let category = "편의점"

        for convenienceStore in convenienceStores {
            getAnnotations(forQuery: convenienceStore, category: category)
        }
    }

    @objc func presentcoffeeAndBakeryFranchisesAnnotations() {
        generator.impactOccurred()
        let coffeeAndBakeryFranchises = ["Cafe", "coffee", "bakery", "투썸플레이스", "컴포즈커피",
                                         "스타벅스", "파리바게뜨", "뚜레쥬르", "할리스커피",
                                         "이디야커피", "메가커피", "브레드톡"]
        
        let category = "카페/베이커리"

        for coffeeAndBakeryFranchise in coffeeAndBakeryFranchises {
            getAnnotations(forQuery: coffeeAndBakeryFranchise, category: category)
        }
    }
    
    @objc func presenthealthyEatingOptionsAnnotations() {
        generator.impactOccurred()
        let healthyEatingOptions = ["샐러디", "subway"]
        let category = "건강식"
        
        for healthyEatingOption in healthyEatingOptions {
            getAnnotations(forQuery: healthyEatingOption, category: category)
        }
    }
    
}
//MARK: - Annotation Setup
extension RunningMapViewController {
    
    func getAnnotations(forQuery query: String, category: String) {
        closeModal()
        //TODO: 기존의 같은 카테고리의 어노테이션 제거
        let allAnnotations = self.mapView.annotations
        for annotation in allAnnotations {
            if let customAnnotation = annotation as? CustomAnnotation, customAnnotation.category != category {
                self.mapView.removeAnnotation(annotation)
            }
        }
        // mapView.overlays 배열에서 currentCircle를 제외하고 모두 제거
        let overlaysToRemove = mapView.overlays.filter { $0 !== currentCircle }
        mapView.removeOverlays(overlaysToRemove)

        //TODO: 사용자의 현재 위치를 가져오기
        guard let currentLocation = self.mapView.userLocation.location else {
            print("Failed to get user location")
            return
        }
        
        //TODO: MKLocalSearch.Request() 활용하여 자연어로 파라미터로 주입된 query를 검색을 정의하고, 지역을 사용자 현재 위치 기준 500m로 설정
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        searchRequest.region = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        
        //MKLocalSearch를 활용, 검색하여 mapItems을 응답값으로 호출
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] (response, error) in
            guard let response = response else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // 50미터 이내의 결과만 필터링
            let filteredMapItems = response.mapItems.filter { mapItem in
                let distance = currentLocation.distance(from: mapItem.placemark.location!)
                return distance <= 150
            }
            
//            검색 결과를 캐시에 저장
            self?.searchResultsCache[query] = filteredMapItems
            
            // 검색된 mapItems의 어노테이션을 추가
            self?.addAnnotationsToMap(mapItems: response.mapItems, category: category)
        }
    }
    
    private func addAnnotationsToMap(mapItems: [MKMapItem], category: String) {
        DispatchQueue.main.async {
            // 현재 맵에 있는 모든 어노테이션을 호출
            let existingAnnotations = self.mapView.annotations.compactMap { $0 as? CustomAnnotation }
            
            // 새로운 어노테이션을 추가하기 전에, 이미 존재하는 어노테이션인지 확인
            for item in mapItems {
                let newItemCoordinate = item.placemark.coordinate
                
                // 현재 맵에 동일한 위치의 어노테이션이 있는지 확인
                let isExisting = existingAnnotations.contains(where: { existingAnnotation in
                    existingAnnotation.coordinate.latitude == newItemCoordinate.latitude && existingAnnotation.coordinate.longitude == newItemCoordinate.longitude
                })
                
                // 동일한 위치의 어노테이션이 없을 경우에만 새 어노테이션을 추가
                if !isExisting {
                    let annotation = CustomAnnotation()
                    annotation.coordinate = newItemCoordinate
                    annotation.title = item.name
                    annotation.mapItem = item
                    annotation.category = category
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    func closeModal() {
        if let currentModal = self.presentedViewController {
            currentModal.dismiss(animated: true)
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
    
    func calculateDistance(to location: CLLocation) -> Int {
        let userLocation = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
        let distanceInMeters = userLocation.distance(from: location)
        return Int(distanceInMeters)
    }
    
    func isStoreFavorite(name: String, latitude: Double, longitude: Double) -> Bool {
        let viewModel = FavoritesViewModel()
        return viewModel.isFavorite(storeName: name, latitude: latitude, longitude: longitude)
    }

    func searchAndPresentStores(with query: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        searchRequest.region = mapView.region
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            
            var places: [AnnotationInfo] = []
            for item in response.mapItems {
                // 필요한 데이터를 places 배열에 추가
                let place = AnnotationInfo(
                    name: item.name ?? "Unknown",
                    category: query, // 카테고리를 검색어로 설정
                    address: item.placemark.title ?? "No address",
                    url: item.url?.absoluteString ?? "No URL",
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude,
                    isOpenNow: false, // 이 값을 설정하기 위한 로직이 필요
                    distance: self.calculateDistance(to: CLLocation(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)),
                    isFavorite: self.isStoreFavorite(name: item.name ?? "", latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)
                )
                
                places.append(place)
            }
            
            self.presentStoreViewController(with: places)
        }
    }
    
    func presentStoreViewController(with places: [AnnotationInfo]) {
        if let currentModal = self.presentedViewController {
            currentModal.dismiss(animated: true)
        }
        
        let storeVC = StoreViewController()
        storeVC.stores = places // 데이터 전달
        storeVC.modalPresentationStyle = .formSheet
        storeVC.modalTransitionStyle = .coverVertical
//        storeVC.modalPresentationStyle = .overCurrentContext
        // 모달을 표시하기 전에 sheetPresentationController 설정을 추가
        if let sheet = storeVC.presentationController as? UISheetPresentationController {
            let customDetentIdentifier = UISheetPresentationController.Detent.Identifier("customBottomBarHeight")
            let customDetent = UISheetPresentationController.Detent.custom(identifier: customDetentIdentifier) { _ in
                return 250
            }
            
            sheet.detents = [customDetent] // 모달의 높이를 중간.medium로 설정하고, .large()를 추가하면 크게.large로 설정합니다.
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = customDetentIdentifier // 모달이 처음 나타날 때 음영 처리 없이 표시
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false // 모달 내부 스크롤 시 확장되지 않도록 설정
            sheet.prefersEdgeAttachedInCompactHeight = true // 컴팩트 높이에서 모달이 화면 가장자리에 붙도록 설정
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true // 모달의 너비가 preferredContentSize를 따르도록 설정
            sheet.presentingViewController.modalTransitionStyle = .coverVertical
            
        }
        
        self.present(storeVC, animated: true, completion: nil)

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
            
            self.locations.append(location)
            
            // 새로운 경로를 추가
            let coordinates = self.locations.map { $0.coordinate }
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(polyline)
            self.currentPolyLine = polyline
            
            if let destination = destination {
                let userLocation = location.coordinate  // 사용자의 위치에 기기의 마지막 위경도를 주입
                
                calculateAndShowRoute(from: userLocation, to: destination)
                // 출발점과 목적지에 커스텀 애노테이션을 추가
                addCustomPins(userLocation: userLocation, destination: destination)
            }
        }
        weatherDatabindViewModel()
        RunningTimerLocationManager.shared.resetActivityTimer()
    }
    
    // 사용자의 현재 위치를 기반으로 경로를 계산하고 지도에 표시하는 메서드
    private func calculateAndShowRoute(from userLocation: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        
        mapView.removeOverlays(mapView.overlays)
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
            
//            let annotaionName =
            let routeName = route.name
            let distanceInMeters = route.distance // 미터 단위
            let timeInSeconds = route.expectedTravelTime // 초 단위

            
            print("routeName name: \(routeName)")
            print("Estimated Distance: \(distanceInMeters) meters")
            print("Estimated Time: \(timeInSeconds) seconds")

        }
        addCustomPins(userLocation: userLocation, destination: destination)
    }
    
    private func addCustomPins(userLocation: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        if let startPin = self.startPin, let annotationToRemove = mapView.annotations.first(where: { $0.coordinate.latitude == startPin.coordinate.latitude && $0.coordinate.longitude == startPin.coordinate.longitude }) {
            mapView.removeAnnotation(annotationToRemove)
        }
        if let endPin = self.endPin, let annotationToRemove = mapView.annotations.first(where: { $0.coordinate.latitude == endPin.coordinate.latitude && $0.coordinate.longitude == endPin.coordinate.longitude }) {
            mapView.removeAnnotation(annotationToRemove)
        }
        
        self.startPin = CustomAnnotation()
        self.endPin = CustomAnnotation()
        
        if let startPin = self.startPin {
            startPin.title = "start"
            startPin.coordinate = userLocation
            mapView.addAnnotation(startPin)
        }
        
        if let endPin = self.endPin {
            endPin.title = "end"
            endPin.coordinate = destination
            mapView.addAnnotation(endPin)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let customAnnotation = view.annotation as? CustomAnnotation, let mapItem = customAnnotation.mapItem else { return }
        mapView.removeOverlays(mapView.overlays)
        let annotation = CustomAnnotation()
        
        let name = mapItem.name ?? "Unknown"
        let address = mapItem.placemark.title ?? "No Address"
        let category = customAnnotation.category ?? "Unknown"

        // 어노테이션까지 거리 계산
        let userLocation = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
        let annotationLocation = CLLocation(latitude: customAnnotation.coordinate.latitude, longitude: customAnnotation.coordinate.longitude)
        let distance = userLocation.distance(from: annotationLocation)
        
        let url = mapItem.url?.absoluteString ?? "No URL"
        
        let isFavorite = favoritesViewModel.isFavorite(storeName: annotation.title ?? "", latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)

        // 예시 정보를 `AnnotationInfo`로 생성
        let info = AnnotationInfo(
            name: name,
            category: category,
            address: address,
            url: url,
            latitude: customAnnotation.coordinate.latitude,
            longitude: customAnnotation.coordinate.longitude,
            isOpenNow: true, // 로직 수정 필요
            distance: Int(distance), // 계산된 거리 정보 사용
            isFavorite: isFavorite
        )

        
        // 사용자 현재 위치와 선택한 어노테이션 위치 사이의 경로 계산 및 표시
        let sourceCoordinate = mapView.userLocation.coordinate
        let destinationCoordinate = customAnnotation.coordinate

        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)

        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)

        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceItem
        directionRequest.destination = destinationItem
        directionRequest.transportType = .walking // 또는 .automobile

        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            
            let route = response.routes[0]
            mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            // 폴리라인 주변에 여분의 공간을 추가하기 위한 패딩 설정
            let edgePadding = UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100)
//            mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            mapView.setVisibleMapRect(rect, edgePadding: edgePadding, animated: true)
        }
        
        if let currentModal = self.presentedViewController {
            currentModal.dismiss(animated: true)
        }
        
        // StoreViewController에 정보 전달 및 표시
        let storeVC = StoreViewController()
        storeVC.stores = [info] // 단일 어노테이션 정보 전달
//        storeVC.modalPresentationStyle = .formSheet
//        storeVC.modalTransitionStyle = .coverVertical
        storeVC.view.backgroundColor = UIColor.systemBackground
        
        if let sheet = storeVC.presentationController as? UISheetPresentationController {
            let customDetentIdentifier = UISheetPresentationController.Detent.Identifier("customBottomBarHeight")
            let customDetent = UISheetPresentationController.Detent.custom(identifier: customDetentIdentifier) { _ in
                return 150
            }
            
            sheet.detents = [customDetent] // 모달의 높이를 중간.medium로 설정하고, .large()를 추가하면 크게.large로 설정합니다.
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = customDetentIdentifier // 모달이 처음 나타날 때 음영 처리 없이 표시
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false // 모달 내부 스크롤 시 확장되지 않도록 설정
            sheet.prefersEdgeAttachedInCompactHeight = true // 컴팩트 높이에서 모달이 화면 가장자리에 붙도록 설정
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true // 모달의 너비가 preferredContentSize를 따르도록 설정
            sheet.presentingViewController.modalTransitionStyle = .coverVertical
        }
        
        self.present(storeVC, animated: true, completion: nil)
    }

    // 지도에 경로 및 주변원을 표시하기 위한 MKMapViewDelegate에서 MKPolylineRenderer, MKCircleRenderer를 설정
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        let polylineColor: UIColor = isDarkMode ? .systemGreen : .systemIndigo
        let circleFillColor: UIColor = isDarkMode ? UIColor.white.withAlphaComponent(0.2) : UIColor.systemIndigo.withAlphaComponent(0.2)

        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = polylineColor // 다크 모드에 따라 색상을 조정
            renderer.lineCap = .round
            renderer.lineWidth = 5.0
            return renderer
        } else if let circleOverlay = overlay as? MKCircle {
            let renderer = MKCircleRenderer(circle: circleOverlay)
            renderer.fillColor = circleFillColor // 다크 모드에 따라 색상을 조정
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
                annotationView?.image = UIImage(named: "DestinationIcon")
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
    
    func didSelectFavorite(_ favorite: Favorite) {
        DispatchQueue.main.async {
            // 기존에 맵에 추가된 어노테이션 중 같은 이름의 어노테이션이 있는지 확인
            if let existingAnnotations = self.mapView.annotations as? [CustomAnnotation],
               let index = existingAnnotations.firstIndex(where: { $0.title == favorite.storeName }) {
                // 이미 같은 이름의 어노테이션이 있으면 지도 중심을 그 어노테이션으로 이동
                let annotation = existingAnnotations[index]
                self.mapView.selectAnnotation(annotation, animated: true)
                self.mapView.centerCoordinate = annotation.coordinate
            } else {
                // 같은 이름의 어노테이션이 없으면 새로 생성하고 맵에 추가
                let annotation = CustomAnnotation()
                annotation.name = favorite.storeName
                annotation.category = favorite.category
                annotation.address = favorite.address
                annotation.coordinate = CLLocationCoordinate2D(latitude: favorite.latitude, longitude: favorite.longitude)
                // 사용자 위치 어노테이션을 제외한 모든 어노테이션 제거
                let annotationsToRemove = self.mapView.annotations.filter { !($0 is MKUserLocation) }
                self.mapView.removeAnnotations(annotationsToRemove)
                self.mapView.addAnnotation(annotation)
                
                self.mapView.selectAnnotation(annotation, animated: true)
                self.mapView.centerCoordinate = annotation.coordinate
            }
            
            DispatchQueue.main.async {
                let userLocation = CLLocation(latitude: self.mapView.userLocation.coordinate.latitude, longitude: self.mapView.userLocation.coordinate.longitude)

                let annotationLocation = CLLocation(latitude: favorite.latitude, longitude: favorite.longitude)

                let distance = userLocation.distance(from: annotationLocation)
                
                let info = AnnotationInfo(
                    name: favorite.storeName ?? "",
                    category: favorite.category ?? "",
                    address: favorite.address ?? "",
                    url: "", // 필요하다면 URL 정보 추가
                    latitude: favorite.latitude,
                    longitude: favorite.longitude,
                    isOpenNow: true, // 실제 상태에 따라 설정
                    distance: Int(distance),
                    isFavorite: true
                )

                let sourceCoordinate = self.mapView.userLocation.coordinate
                let destinationCoordinate = annotationLocation.coordinate

                let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
                let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)

                let sourceItem = MKMapItem(placemark: sourcePlacemark)
                let destinationItem = MKMapItem(placemark: destinationPlacemark)

                let directionRequest = MKDirections.Request()
                directionRequest.source = sourceItem
                directionRequest.destination = destinationItem
                directionRequest.transportType = .walking

                let directions = MKDirections(request: directionRequest)
                directions.calculate { (response, error) in
                    guard let response = response else {
                        if let error = error {
                            print("Error: \(error)")
                        }
                        return
                    }
                    
                    let route = response.routes[0]
                    self.mapView.removeOverlays(self.mapView.overlays)
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                    
                    let rect = route.polyline.boundingMapRect

                    let edgePadding = UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100)

                    self.mapView.setVisibleMapRect(rect, edgePadding: edgePadding, animated: true)
                }
                
                if let currentModal = self.presentedViewController {
                    currentModal.dismiss(animated: true)
                }
                
                let storeVC = StoreViewController()
                storeVC.stores = [info]
                storeVC.view.backgroundColor = UIColor.systemBackground
                
                if let sheet = storeVC.presentationController as? UISheetPresentationController {
                    let customDetentIdentifier = UISheetPresentationController.Detent.Identifier("customBottomBarHeight")
                    let customDetent = UISheetPresentationController.Detent.custom(identifier: customDetentIdentifier) { _ in
                        return 150
                    }
                    
                    sheet.detents = [customDetent]
                    sheet.prefersGrabberVisible = true
                    sheet.largestUndimmedDetentIdentifier = customDetentIdentifier
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheet.prefersEdgeAttachedInCompactHeight = true
                    sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                    sheet.presentingViewController.modalTransitionStyle = .coverVertical
                }
                
                self.present(storeVC, animated: true, completion: nil)
            }
        }
        print("\(favorite.latitude),\(favorite.longitude)")
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
                
                self.coffeeAndBakeryFranchisesButton.layer.transform = CATransform3DIdentity
                self.coffeeAndBakeryFranchisesButton.alpha = 1.0
                
                self.healthyEatingOptionsButton.layer.transform = CATransform3DIdentity
                self.healthyEatingOptionsButton.alpha = 1.0
                
            })
            
        } else {
            if let currentModal = self.presentedViewController {
                currentModal.dismiss(animated: true)
            }
            
            UIView.animate(withDuration: 0.15, delay: 0.2, options: []) { [weak self] in
                guard let self = self else { return }
                self.convenienceStoreButton.layer.transform = CATransform3DMakeScale(0.4, 0.4, 0.1)
                self.convenienceStoreButton.alpha = 0.0
                
                self.coffeeAndBakeryFranchisesButton.layer.transform = CATransform3DMakeScale(0.4, 0.4, 0.1)
                self.coffeeAndBakeryFranchisesButton.alpha = 0.0
                
                self.healthyEatingOptionsButton.layer.transform = CATransform3DMakeScale(0.4, 0.4, 0.1)
                self.healthyEatingOptionsButton.alpha = 0.0
                
                
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
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func addSubview() {
        view.addSubview(mapView)
        view.addSubview(compassButton)
        view.addSubview(startRunningButton)
        view.addSubview(backToRunningTimerViewButton)
        view.addSubview(currentLocationButton)
        view.addSubview(storeListButton)
        view.addSubview(convenienceStoreButton)
        view.addSubview(coffeeAndBakeryFranchisesButton)
        view.addSubview(healthyEatingOptionsButton)
        view.addSubview(weatherContainer)
        view.addSubview(attributionImageView)
        weatherContainer.addSubview(temperatureLabel)
        weatherContainer.addSubview(humidityLabel)
        weatherContainer.addSubview(windspeedLabel)
        weatherContainer.addSubview(uvIndexcategoryLabel)
        weatherContainer.addSubview(weatherSymbol)
    }
    
    private func setLayout() {
        mapView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        weatherContainer.snp.makeConstraints {
            $0.top.equalToSuperview().offset(80)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(160)
            $0.height.equalTo(60)
        }
        weatherSymbol.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
            $0.width.height.equalTo(40)
        }
        
        temperatureLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(weatherContainer.snp.top).offset(10)
        }
        humidityLabel.snp.makeConstraints {
            $0.centerX.equalTo(temperatureLabel)
            $0.top.equalTo(temperatureLabel.snp.bottom).offset(10)
        }
        windspeedLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-10)
            $0.top.equalTo(temperatureLabel)
        }
        uvIndexcategoryLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-10)
            $0.top.equalTo(windspeedLabel.snp.bottom).offset(10)
        }
        
        attributionImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.top.equalTo(weatherContainer.snp.bottom).offset(8)
        }
        startRunningButton.snp.makeConstraints {
            $0.width.height.equalTo(90)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-120)
        }
        
        backToRunningTimerViewButton.snp.makeConstraints {
            $0.width.height.equalTo(90)
            $0.leading.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-120)
        }
        
        compassButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(80)
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
        
        convenienceStoreButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.top.equalTo(storeListButton.snp.bottom).offset(20)
            make.centerX.equalTo(storeListButton)
           
        }

        coffeeAndBakeryFranchisesButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.top.equalTo(convenienceStoreButton.snp.bottom).offset(20)
            make.centerX.equalTo(storeListButton)
            
        }

        healthyEatingOptionsButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.top.equalTo(coffeeAndBakeryFranchisesButton.snp.bottom).offset(20)
            make.centerX.equalTo(storeListButton)
            
        }

        
    }
    
    
}

//MARK: - Weather Setup
extension RunningMapViewController {

    func weatherDatabindViewModel() {
        // 현재 위치 정보가 있는지 확인
        if let location = self.currentLocation {
            // 위치 정보가 있을 경우, 해당 위치를 사용하여 날씨 정보를 업데이트
            weatherViewModel.getWeather(location: location)
            
            weatherViewModel.$weathersymbolName.receive(on: DispatchQueue.main).sink { [weak self] weatherSymbol in
                self?.weatherSymbol.image = UIImage(systemName: weatherSymbol)
            }.store(in: &cancellables)
            
            weatherViewModel.$currentTemperature.receive(on: DispatchQueue.main).sink { [weak self] temperatureLabel in
                let roundedTemperature = round(temperatureLabel * 10) / 10.0
                self?.temperatureLabel.text = "\(roundedTemperature)ºC"
            }.store(in: &cancellables)
            
            weatherViewModel.$currenthumidity.receive(on: DispatchQueue.main).sink { [weak self] humidityLabel in
                let percentageHumidity = Int(humidityLabel * 100) // 백분율로 변환 후 정수로 표시
                self?.humidityLabel.text = "\(percentageHumidity)%"
            }.store(in: &cancellables)
            
            weatherViewModel.$windspeed.receive(on: DispatchQueue.main).sink { [weak self] windspeedLabel in
                let roundedwindspeed = round(windspeedLabel * 10) / 10.0
                self?.windspeedLabel.text = "\(roundedwindspeed)m/s"
            }.store(in: &cancellables)
            
            weatherViewModel.$uvIndexcategory.receive(on: DispatchQueue.main).sink { [weak self] uvIndexcategoryLabel in
                self?.uvIndexcategoryLabel.text = "UV \(uvIndexcategoryLabel)"
            }.store(in: &cancellables)
        } else {
            print("no location data")
        }
    }
    
    func setupAttribution() {
        weatherViewModel.$weatherAttribution.receive(on: DispatchQueue.main).sink { [weak self] attributionImageURLString in
            let url = URL(string: attributionImageURLString)
            self?.downloadAndSetAttributionImage(from: url)
        }.store(in: &cancellables)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(attributionTapped))
        attributionImageView.isUserInteractionEnabled = true
        attributionImageView.addGestureRecognizer(tapGesture)
    }

    @objc func attributionTapped() {
        if let url = weatherViewModel.legalPageURL {
            UIApplication.shared.open(url)
        }
    }

    func downloadAndSetAttributionImage(from url: URL?) {
        guard let url = url else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.attributionImageView.image = image
            }
        }
        task.resume()
    }
}
