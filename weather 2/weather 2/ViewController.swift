//
//  ViewController.swift
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var feelsLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!

    // MARK: - Actions

    @IBAction func forecastTapped(_ sender: UIButton) {
            performSegue(withIdentifier: "showForecast", sender: nil)
        }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showForecast",
           let dest = segue.destination as? ForecastViewController {
            dest.latitude = locationManager.location?.coordinate.latitude ?? 0
            dest.longitude = locationManager.location?.coordinate.longitude ?? 0
            dest.cityName = cityLabel.text ?? ""
            dest.currentTemp = Double(
                tempLabel.text?.replacingOccurrences(of: "°C", with: "") ?? "0"
            ) ?? 0
        }
    }
    
    
    func setGradientBackground() {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor.systemBlue.cgColor,
            UIColor.systemTeal.cgColor
        ]
        view.layer.insertSublayer(gradient, at: 0)
    }

    // MARK: - Properties

    let apiKey = "b82b26ab9d5098418040d0eb36ef7256"
    let locationManager = CLLocationManager()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setGradientBackground()
        cityLabel.text = "Hello"
        tempLabel.text = "--"
        descLabel.text = "--"

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // MARK: - Location

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude

        locationManager.stopUpdatingLocation()
        fetchWeather(lat: lat, lon: lon)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error:", error.localizedDescription)
    }

    // MARK: - Fetch Weather

    func fetchWeather(lat: Double, lon: Double) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else { return }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let weatherData = try JSONDecoder().decode(WeatherResponse.self, from: data)
                await MainActor.run { self.updateUI(data: weatherData) }
            } catch {
                print("Error:", error)
            }
        }
    }

    // MARK: - Update UI

    func updateUI(data: WeatherResponse) {
        cityLabel.text = data.name
        tempLabel.text = String(format: "%.1f°C", data.main.temp)
        descLabel.text = data.weather.first?.description.capitalized

        feelsLabel.text = "Feels: \(data.main.feels_like)°C"
        humidityLabel.text = "Humidity: \(data.main.humidity)%"
        windLabel.text = "Wind: \(data.wind.speed) m/s"
        visibilityLabel.text = "Visibility: \(data.visibility / 1000) km"
        sunriseLabel.text = "Sunrise: \(formatTime(data.sys.sunrise))"
        sunsetLabel.text = "Sunset: \(formatTime(data.sys.sunset))"

        if let icon = data.weather.first?.icon {
            loadImage(urlString: "https://openweathermap.org/img/wn/\(icon)@2x.png")
        }

        animateTemp()   // ← called here, inside updateUI
    }

    // MARK: - Animate Temp

    func animateTemp() {
        tempLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.4, delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.8) {
            self.tempLabel.transform = .identity
        }
    }

    // MARK: - Helpers

    func formatTime(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    func loadImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                await MainActor.run { self.weatherImage.image = UIImage(data: data) }
            } catch {
                print("Image Load Error:", error)
            }
        }
    }
    

} // ← single closing brace for the entire class
