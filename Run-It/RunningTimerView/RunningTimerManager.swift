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
    
    func start() {
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .background))
        timer?.schedule(deadline: .now(), repeating: .seconds(1))
        timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            // Int(Date().timeIntervalSince(startTime))
            self.time = Int(Date().timeIntervalSince(startTime)) - self.pauseDuration
            self.distance += 0.01 // RunningTimerManager와 연계해서 변경 필요
            // 거리가 0.05km, 즉 50m 이상일 때만 페이스를 계산
            self.pace = self.distance >= 0.05 ? Double(self.time) / self.distance : 0
            print("running properties : \(self.time), \(self.distance), \(self.pace)")
            DispatchQueue.main.async {
                // updateUI 클로져를 호출
                self.updateUI?()
            }
        }
//        startTime = Date()
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


