//
//  AVSpeechSyncthesizer.swift
//  Run-It
//
//  Created by Jason Yang on 3/20/24.
//

import Foundation
import AVFoundation

class SpeechService {
    static let shared = SpeechService()
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    private init() {}
    
    func speakTimeDistancePace(time: Int, distance: Double, pace: Int) {
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = (time % 3600) % 60
        
        let distanceKm = distance / 1000 // 미터 단위의 거리를 킬로미터로 변환
        
        let paceMinutes = pace / 60
        let paceSeconds = pace % 60
        
        let speechText = """
        현재까지 총 시간은 \(hours)시간 \(minutes)분 \(seconds)초,
        총 거리는 \(String(format: "%.2f", distanceKm))킬로미터,
        페이스는 \(paceMinutes) 분 \(paceSeconds) 초
        입니다.
        """
        
        speak(speechText)
    }
    
    public func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        utterance.rate = 0.4
        speechSynthesizer.speak(utterance)
    }
}

// 예제 사용
let timeInSeconds = 5400 // 예: 1시간 30분을 초로 환산
let distanceInMeters = 10000.0 // 예: 10km를 미터로 환산
let paceInSeconds = 330 // 예: 페이스가 5분 30초라고 가정, 초로 환산

//SpeechService.shared.speakTimeDistancePace(time: timeInSeconds, distance: distanceInMeters, pace: paceInSeconds)

