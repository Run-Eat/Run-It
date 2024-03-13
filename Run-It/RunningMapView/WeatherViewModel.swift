//
//  WeatherViewModel.swift
//  Run-It
//
//  Created by Jason Yang on 3/12/24.
//

import Foundation
import WeatherKit
import CoreLocation
import Combine

class WeatherViewModel: ObservableObject {
    // UI Properties
    @Published var weathersymbolName: String = ""
    @Published var currentTemperature: Double = 0
    @Published var currenthumidity: Double = 0
    @Published var windspeed: Double = 0
    @Published var uvIndexcategory: Int = 0
    
    func getWeather(location: CLLocation) {
        Task {
            do {
                let weather = try await WeatherService.shared.weather(for: location)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    print("날씨기호 이름: \(self.weathersymbolName), 온도: \(self.currentTemperature)°C, 습도: \(self.currenthumidity)%, 풍속: \(self.windspeed)m/s, UV 지수: \(self.uvIndexcategory)")
                    self.weathersymbolName = weather.currentWeather.symbolName
                    self.currentTemperature = weather.currentWeather.temperature.converted(to: .celsius).value
                    self.currenthumidity = weather.currentWeather.humidity
                    self.windspeed = weather.currentWeather.wind.speed.converted(to: .metersPerSecond).value
                    self.uvIndexcategory = weather.currentWeather.uvIndex.value
                    
                }
            } catch {
                print("날씨 데이터를 불러오는 데 실패했습니다: \(String(describing: error))")
            }
        }
    }
}
