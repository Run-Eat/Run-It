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
    
    var locationManager: CLLocationManager
    var previousLocation: CLLocation?
    var totalDistance: Double = 0
    var startTime: Date?
    var pace: Double = 0
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        startTime = Date()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            if previousLocation == nil {
                previousLocation = location
            } else if let previous = previousLocation {
                let distance = previous.distance(from: location)
                totalDistance += distance
                let time = Date().timeIntervalSince(startTime!)
                pace = time != 0 ? totalDistance / time : 0
            }
            previousLocation = location
        }
    }
}
