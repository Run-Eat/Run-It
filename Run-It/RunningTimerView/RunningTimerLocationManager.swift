//
//  RunningTimerManager.swift
//  Run-It
//
//  Created by Jason Yang on 2/25/24.
//

import Foundation
import CoreLocation


// 위치 권한 요청, 사용자 위치를 계속 요청하므로 추적 배터리 소모 고려 조정 필요
class RunningTimerLocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = RunningTimerLocationManager()
    
    var locations: [CLLocation] = []
    var locationManager: CLLocationManager = CLLocationManager()
    var previousLocation: CLLocation?
    var totalDistance: Double = 0
    var startTime: Date?
    var pace: Double = 0
    var updateLocationClosure: ((CLLocation) -> Void)?
    var state: LocationManagerState = .stopped
    
    var lastActivityTime: Date?
    var activityTimer: Timer?
    
    enum LocationManagerState {
        case started
        case stopped
        case paused
    }
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 3
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.pausesLocationUpdatesAutomatically = false
        resetActivityTimer()
    }
    
    //위치사용 권한 요청
    func getLocationUsagePermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    // Call this method to start updating the location
    func startUpdatingLocation() {
        guard state != .started else { return }
        locationManager.startUpdatingLocation()
        state = .started
    }
    
    // Call this method to stop updating the location
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        state = .stopped
    }
    
    func pauseLocationUpdates() {
        guard state == .started else { return }
        locationManager.stopUpdatingLocation()
        state = .paused
    }

    func resumeLocationUpdates() {
        guard state == .paused else { return }
        locationManager.startUpdatingLocation()
        state = .started
    }

    
    //위치서비스의 권한 상태가 변경될 때 호출되는 매서드
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
            print("GPS 권한 설정됨")
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.locationManager.requestWhenInUseAuthorization()
            }
            print("GPS 권한 요청함")
        case .notDetermined:
            //결정이 안되었을 경우 권한 요청
            DispatchQueue.main.async {
                self.locationManager.requestWhenInUseAuthorization()
            }
            print("GPS 권한 요청함")
        default:
            return
        }
    }
    
    // 오류 처리
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error)")
    }
    
    // CLLocationManagerDelegate 메서드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, state == .started else { return }
        // 현재 위치 정보 출력
//        print("Current location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
//        print("Locations array count: \(self.locations.count)")

        if let previousLocation = self.previousLocation {
            // 이전 위치와 현재 위치 사이의 거리 계산
            let distance = previousLocation.distance(from: location)
            totalDistance += distance

            // 계산된 거리 정보 출력
//            print("Distance from previous location: \(distance) meters")
//            print("Total distance: \(totalDistance) meters")
        } else {
            // 이전 위치 정보가 없을 경우, 처음 위치 업데이트를 받은 것임
            print("Starting location updates...")
        }

        // 새 위치를 이전 위치로 업데이트
        self.previousLocation = location
        
        // 모든 새 위치를 self.locations 배열에 추가
        self.locations.append(contentsOf: locations)

        // 위치 업데이트 클로저 호출 (새 위치 데이터 전달)
        updateLocationClosure?(location)
        resetActivityTimer()
    }

    func getLocations() -> [CLLocation] {
        return self.locations
    }
    
    func resetLocationData() {
        locations.removeAll()
        totalDistance = 0.0
        previousLocation = nil
    }
    
    func resetActivityTimer() {
        // 이전 타이머가 있으면 무효화
        activityTimer?.invalidate()
        // 마지막 활동 시간 업데이트
        lastActivityTime = Date()
        // 30분 후에 checkActivity를 호출하는 타이머 설정
        activityTimer = Timer.scheduledTimer(timeInterval: 1800, target: self, selector: #selector(checkActivity), userInfo: nil, repeats: false)
    }

    @objc func checkActivity() {
        if let lastActivityTime = lastActivityTime, Date().timeIntervalSince(lastActivityTime) >= 3600 {
            // 위치 추적 중단
            locationManager.stopUpdatingLocation()
        }
    }
}
