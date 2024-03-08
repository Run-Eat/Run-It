//
//  RunningMapModel.swift
//  Run-It
//
//  Created by t2023-m0039 on 2/25/24.
//

import Foundation
import CoreLocation

class RunningMapViewModel {
    private var locationManger = RunningTimerLocationManager.shared
    
    // 위치 데이터 업데이트를 위한 클로저
    var locationDidUpdate: ((CLLocation) -> Void)?
    
    init() {
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManger.updateLocationClosure = { [weak self] newLocation in
            // ViewModel 내부에서 처리할 로직, 예를 들어, UI 업데이트를 위한 데이터 준비
            self?.locationDidUpdate?(newLocation)
        }
    }
}
