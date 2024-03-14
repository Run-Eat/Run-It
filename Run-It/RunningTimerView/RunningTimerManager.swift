//
//  RunningTimer.swift
//  Run-It
//
//  Created by Jason Yang on 3/1/24.
//
enum TimerState {
    case suspended //일시정지
    case resumed   //재개
    case canceled  //취소
    case finished  //종료
    case background
    case foreground
}

import Foundation
import UIKit
import CoreData

class RunningTimer {
    
    var state: TimerState = .suspended
    private var timer: DispatchSourceTimer?
    private var startTime = Date()
    
    private var pauseTime: Date?
    private var restartTime: Date?
    private var pauseDuration: Int = 0
    
    private var backgroundTime: Date?
    
    var time: Int = 0
    var distance: Double = 0.0
    var pace: Double = 0.0
    
    // UI 업데이트를 위한 클로져
    var updateUI: (() -> Void)?
    
    var locationManger = RunningTimerLocationManager.shared
    
    init() {
        setupLocationUpdateHandling()
        setupLocationUpdateListener()
    }
    private func setupLocationUpdateHandling() {
        locationManger.updateLocationClosure = { [weak self] location in
            // 여기에서 위치 업데이트에 대한 처리를 정의
            // 예: self?.distance += 계산된 거리
        }
    }
    
    private func setupLocationUpdateListener() {
        RunningTimerLocationManager.shared.updateLocationClosure = { [weak self] newLocation in
            guard let self = self, self.state == .resumed else { return }
            // RunningTimerLocationManager에서 제공하는 totalDistance를 사용하여 거리 업데이트
            self.distance = RunningTimerLocationManager.shared.totalDistance
            
            // 경과 시간을 기반으로 페이스 계산
            let elapsedTime = Date().timeIntervalSince(self.startTime) - Double(self.pauseDuration)
            if self.distance > 0 {
                self.pace = elapsedTime / (self.distance / 1000.0)
            } else {
                self.pace = 0
            }
            
            DispatchQueue.main.async {
                // UI 업데이트 클로저 호출
                self.updateUI?()
            }
        }
    }
    
    func start() {
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .background))
        timer?.schedule(deadline: .now(), repeating: .seconds(1))
        timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            // Int(Date().timeIntervalSince(startTime))
            self.time = Int(Date().timeIntervalSince(startTime)) - self.pauseDuration
            // 이동 거리와 페이스 계산은 위치 업데이트 클로저 내에서 처리

            // 로그 출력 및 UI 업데이트
            print("running properties : \(self.time), \(self.distance), \(self.pace)")
            
            DispatchQueue.main.async {
                // updateUI 클로져를 호출
                self.updateUI?()
            }
        }
        timer?.resume()
        state = .resumed
    }
    
    func pause() {
        if state == .resumed {
            timer?.suspend()
            state = .suspended
            pauseTime = Date()
            print("pause properties : \(self.time), \(self.distance), \(self.pace)")
        }
    }
    
    func timerEnterBackground() {
        if state == .background {
            timer?.suspend()
            state = .suspended
            backgroundTime = Date()
        }
        print(backgroundTime ?? Date())
    }
    
    
    func restart() {
        if state == .suspended {
            //            timer?.activate()
            timer?.resume()
            state = .resumed
            restartTime = Date()
            
            
            //현지시간 출력
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let restartTimeString = dateFormatter.string(from: restartTime ?? Date())
            print("Restart Time: \(restartTimeString)")
            
            if let pTime = pauseTime, let rTime = restartTime {
                pauseDuration += Int(rTime.timeIntervalSince(pTime))
            }
            print("restart properties : \(self.time), \(self.distance), \(self.pace)")
            DispatchQueue.main.async {
                self.updateUI?()
            }
        }
    }
    
    func timerWillEnterForeground() {
        if state == .foreground {
            let backgroundDuration = Date().timeIntervalSince(backgroundTime ?? Date())
            print("Background Duration: \(backgroundDuration)")
            time += Int(backgroundDuration)
            
            timer?.activate()
            timer?.resume()
            state = .resumed
            DispatchQueue.main.async {
                self.updateUI?()
            }
        }
        print("Forground properties : \(self.time), \(self.distance), \(self.pace)")
    }
    
    func stop() {
        timer?.cancel()
        state = .canceled
        timer = nil
    }
}


