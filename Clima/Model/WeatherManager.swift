//
//  WeatherManager.swift
//  Clima
//
//  Created by Stephen Chalker on 6/2/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

struct WeatherManager {
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=07b5240663a9744310736287db1b50cc&units=imperial"
    
    var delegate: WeatherModelDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherUrl)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(lat: Double, long: Double) {
        let urlString = "\(weatherUrl)&lat=\(lat)&lon=\(long)"
        performRequest(with: urlString)
    }
    
    func performRequest(with url: String) {
        if let url = URL(string: url) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if(error != nil) {
                    print(error!)
                    self.delegate?.didFailWithError(error!)
                    return
                }
                
                if let safedata = data {
                    if let weather = self.parseJson(safedata) {
                        self.delegate?.didUpdateWeather(self, weather)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJson(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temerature = decodedData.main.temp
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temerature)
            
            return weather
        } catch {
            print(error)
            delegate?.didFailWithError(error)
            return nil
        }
        
    }
}

protocol WeatherModelDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, _ weather: WeatherModel)
    func didFailWithError(_ error: Error)
}
