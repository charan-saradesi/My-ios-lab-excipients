import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

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

    let apiKey = "b82b26ab9d5098418040d0eb36ef7256"
    let locationManager = CLLocationManager()
    var hasFetched = false
    var currentLat: Double = 0
    var currentLon: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        styleWeatherCards()
        
        setGradientBackground()
        cityLabel.text = "Detecting..."
        tempLabel.text = "--"
        descLabel.text = "--"
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func styleWeatherCards() {
        let cardViews = [feelsLabel, humidityLabel, windLabel, visibilityLabel, sunriseLabel, sunsetLabel]
        
        for label in cardViews {
            guard let label = label else { continue }
            label.backgroundColor = UIColor.white.withAlphaComponent(0.18)
            label.layer.cornerRadius = 14
            label.layer.masksToBounds = true
            label.textColor = .white
            label.textAlignment = .center
            label.numberOfLines = 2
            label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        }
        
        cityLabel.textColor = .white
        tempLabel.textColor = .white
        descLabel.textColor = .white
    }

    func setGradientBackground() {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.systemBlue.cgColor, UIColor.systemTeal.cgColor]
        view.layer.insertSublayer(gradient, at: 0)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if hasFetched { return }
        hasFetched = true
        guard let location = locations.last else { return }
        currentLat = location.coordinate.latitude
        currentLon = location.coordinate.longitude
        locationManager.stopUpdatingLocation()
        fetchWeather(lat: currentLat, lon: currentLon)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error:", error.localizedDescription)
    }

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

    func updateUI(data: WeatherResponse) {
        cityLabel.text = data.name
        tempLabel.text = "\(Int(data.main.temp))°C"
        descLabel.text = data.weather.first?.description.capitalized ?? "--"
        feelsLabel.text = "Feels\n\(data.main.feels_like)°C"
        humidityLabel.text = "Humidity\n\(data.main.humidity)%"
        windLabel.text = "Wind\n\(data.wind.speed) m/s"
        visibilityLabel.text = "Visibility\n\(data.visibility / 1000) km"
        sunriseLabel.text = "Sunrise\n\(formatTime(data.sys.sunrise))"
        sunsetLabel.text = "Sunset\n\(formatTime(data.sys.sunset))"
        if let icon = data.weather.first?.icon {
            loadImage(urlString: "https://openweathermap.org/img/wn/\(icon)@2x.png")
        }
        animateTemp()
    }

    func animateTemp() {
        tempLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8) {
            self.tempLabel.transform = .identity
        }
    }

    @IBAction func forecastTapped(_ sender: UIButton) {
            performSegue(withIdentifier: "showForecast", sender: nil)
        }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showForecast",
           let dest = segue.destination as? ForecastViewController {
            dest.latitude = currentLat
            dest.longitude = currentLon
            dest.cityName = cityLabel.text ?? ""
            dest.currentTemp = Double(tempLabel.text?.replacingOccurrences(of: "°C", with: "") ?? "0") ?? 0
        }
    }

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
}
