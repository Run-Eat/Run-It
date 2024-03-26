//
//  WeatherViewModel.swift
//  Run-It
//
//  Created by Jason Yang on 3/12/24.
//

struct AttributionData: Codable {
    let logoDark3x: String
    let logoLight1x: String
    let logoDark2x: String
    let logoDark1x: String
    let logoLight2x: String
    let logoLight3x: String
    let logoSquare2x: String
    let serviceName: String
    let logoSquare1x: String
    let logoSquare3x: String

    enum CodingKeys: String, CodingKey {
        case logoDark3x = "logoDark@3x"
        case logoLight1x = "logoLight@1x"
        case logoDark2x = "logoDark@2x"
        case logoDark1x = "logoDark@1x"
        case logoLight2x = "logoLight@2x"
        case logoLight3x = "logoLight@3x"
        case logoSquare2x = "logoSquare@2x"
        case serviceName = "serviceName"
        case logoSquare1x = "logoSquare@1x"
        case logoSquare3x = "logoSquare@3x"
    }
}

import Foundation
import WeatherKit
import CoreLocation
import Combine
import UIKit

class WeatherViewModel: ObservableObject {
    // UI Properties
    @Published var weathersymbolName: String = ""
    @Published var currentTemperature: Double = 0
    @Published var currenthumidity: Double = 0
    @Published var windspeed: Double = 0
    @Published var uvIndexcategory: Int = 0
    @Published var legalPageURL: URL?
    @Published var weatherAttribution: String = ""
    
    func getWeather(location: CLLocation) {
        Task {
            do {
                let weather = try await WeatherService.shared.weather(for: location)
                let attribution = "Data provided by WeatherKit"
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.weathersymbolName = weather.currentWeather.symbolName
                    self.currentTemperature = weather.currentWeather.temperature.converted(to: .celsius).value
                    self.currenthumidity = weather.currentWeather.humidity
                    self.windspeed = weather.currentWeather.wind.speed.converted(to: .metersPerSecond).value
                    self.uvIndexcategory = weather.currentWeather.uvIndex.value
                    self.legalPageURL = URL(string: "https://developer.apple.com/weatherkit/data-source-attribution/")
                    self.weatherAttribution = attribution
                }
            } catch {
                print("날씨 데이터를 불러오는 데 실패했습니다: \(String(describing: error))")
            }
        }
    }
}



extension WeatherViewModel {
    func loadWeatherAttribution() {
        guard let url = URL(string: "https://weatherkit.apple.com/attribution/en-US") else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in

            guard let data = data, error == nil else { return }

            do {
                let attributionData = try JSONDecoder().decode(AttributionData.self, from: data)
                let baseURLString = "https://weatherkit.apple.com"
                let imageURLString = baseURLString + attributionData.logoLight1x
                
                DispatchQueue.main.async {
                    self?.weatherAttribution = imageURLString
                    self?.legalPageURL = URL(string: "https://developer.apple.com/documentation/weatherkit/displaying_attribution_correctly")
                }
            } catch {
                print(error)
            }
        }

        task.resume()
    }
}
