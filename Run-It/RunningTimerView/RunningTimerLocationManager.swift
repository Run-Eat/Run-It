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
    
    var locationManager: CLLocationManager = CLLocationManager()
    var previousLocation: CLLocation?
    var totalDistance: Double = 0
    var startTime: Date?
    var pace: Double = 0
    var updateLocationClosure: ((CLLocation) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Call this method to start updating the location
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    // Call this method to stop updating the location
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // CLLocationManagerDelegate 메서드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // 현재 위치 정보 출력
        print("Current location: \(location.coordinate.latitude), \(location.coordinate.longitude)")

        if let previousLocation = self.previousLocation {
            // 이전 위치와 현재 위치 사이의 거리 계산
            let distance = previousLocation.distance(from: location)
            totalDistance += distance

            // 계산된 거리 정보 출력
            print("Distance from previous location: \(distance) meters")
            print("Total distance: \(totalDistance) meters")
        } else {
            // 이전 위치 정보가 없을 경우, 처음 위치 업데이트를 받은 것임
            print("Starting location updates...")
        }

        // 새 위치를 이전 위치로 업데이트
        self.previousLocation = location

        // 위치 업데이트 클로저 호출 (새 위치 데이터 전달)
        updateLocationClosure?(location)
    }

}
