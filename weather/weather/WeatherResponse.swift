import Foundation

struct WeatherResponse: Codable, Sendable {
    let name: String
    let main: Main
    let weather: [Weather]
    let wind: Wind
    let visibility: Int
    let sys: Sys
}

struct Main: Codable, Sendable {
    let temp: Double
    let feels_like: Double
    let humidity: Int
}

struct Weather: Codable, Sendable {
    let description: String
    let icon: String
}

struct Wind: Codable, Sendable {
    let speed: Double
}

struct Sys: Codable, Sendable {
    let sunrise: Int
    let sunset: Int
}
