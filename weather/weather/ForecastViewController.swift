import UIKit

struct ForecastResponse: Codable {
    let list: [ForecastItem]
    let city: City
}

struct ForecastItem: Codable {
    let dt: Int
    let main: Main
    let weather: [Weather]
    let wind: Wind
    let dt_txt: String
}

struct City: Codable {
    let name: String
}

struct DaySummary {
    let day: String
    let minTemp: Double
    let maxTemp: Double
    let feelsLike: Double
    let humidity: Int
    let windSpeed: Double
    let description: String
    let icon: String
}

class ForecastViewController: UIViewController {

    var latitude: Double = 0
    var longitude: Double = 0
    var cityName: String = ""
    var currentTemp: Double = 0

    let apiKey = "b82b26ab9d5098418040d0eb36ef7256"

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var detailsTableView: UITableView!

    var hourlyItems: [ForecastItem] = []
    var dailyItems: [(day: String, min: Double, max: Double, icon: String)] = []
    var summaryItems: [DaySummary] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setGradientHeader()

        cityLabel.text = cityName
        currentTempLabel.text = "\(Int(currentTemp))°C"

        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isHidden = true

        detailsTableView.delegate = self
        detailsTableView.dataSource = self
        detailsTableView.isHidden = true
        detailsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DetailCell")

        segmentControl.selectedSegmentIndex = 1

        fetchForecast()
    }

    func setGradientHeader() {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 160)
        gradient.colors = [UIColor.systemBlue.cgColor, UIColor.systemTeal.cgColor]
        view.layer.insertSublayer(gradient, at: 0)
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        collectionView.isHidden = sender.selectedSegmentIndex != 0
        tableView.isHidden = sender.selectedSegmentIndex != 1
        detailsTableView.isHidden = sender.selectedSegmentIndex != 2
        tableView.reloadData()
        collectionView.reloadData()
        detailsTableView.reloadData()
    }

    func fetchForecast() {
        let urlStr = "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlStr) else { return }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let forecast = try JSONDecoder().decode(ForecastResponse.self, from: data)
                await MainActor.run {
                    self.processHourly(forecast.list)
                    self.processDaily(forecast.list)
                    self.processSummary(forecast.list)
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                    self.detailsTableView.reloadData()
                }
            } catch {
                print("Forecast error:", error)
            }
        }
    }

    func processHourly(_ items: [ForecastItem]) {
        hourlyItems = Array(items.prefix(8))
    }
    var globalMinTemp: Double = 0
    var globalMaxTemp: Double = 0

    func processDaily(_ items: [ForecastItem]) {
        let allTemps = items.map { $0.main.temp }
        globalMinTemp = allTemps.min() ?? 0
        globalMaxTemp = allTemps.max() ?? 1

        var grouped: [String: [ForecastItem]] = [:]
        for item in items {
            let key = String(item.dt_txt.prefix(10))
            grouped[key, default: []].append(item)
        }
        dailyItems = grouped.sorted { $0.key < $1.key }.map { key, vals in
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            let date = df.date(from: key) ?? Date()
            let display = DateFormatter()
            display.dateFormat = "EEE"
            let min = vals.map { $0.main.temp }.min() ?? 0
            let max = vals.map { $0.main.temp }.max() ?? 0
            let icon = vals.first?.weather.first?.icon ?? "01d"
            return (display.string(from: date), min, max, icon)
        }
    }

    func processSummary(_ items: [ForecastItem]) {
        var grouped: [String: [ForecastItem]] = [:]
        for item in items {
            let key = String(item.dt_txt.prefix(10))
            grouped[key, default: []].append(item)
        }
        summaryItems = grouped.sorted { $0.key < $1.key }.map { key, vals in
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            let date = df.date(from: key) ?? Date()
            let display = DateFormatter()
            display.dateFormat = "EEEE"
            let min = vals.map { $0.main.temp }.min() ?? 0
            let max = vals.map { $0.main.temp }.max() ?? 0
            let feelsLike = vals.first?.main.feels_like ?? 0
            let humidity = vals.first?.main.humidity ?? 0
            let wind = vals.first?.wind.speed ?? 0
            let desc = vals.first?.weather.first?.description.capitalized ?? ""
            let icon = vals.first?.weather.first?.icon ?? "01d"
            return DaySummary(day: display.string(from: date), minTemp: min, maxTemp: max,
                              feelsLike: feelsLike, humidity: humidity, windSpeed: wind,
                              description: desc, icon: icon)
        }
    }

    func formatHour(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let f = DateFormatter()
        f.dateFormat = "ha"
        return f.string(from: date)
    }
}

extension ForecastViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == detailsTableView { return summaryItems.count }
        return dailyItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == detailsTableView {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "DetailCell")
            let item = summaryItems[indexPath.row]
            cell.textLabel?.text = "\(item.day)  —  \(item.description)"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            cell.detailTextLabel?.text = "🌡 \(Int(item.minTemp))° / \(Int(item.maxTemp))°   💧 \(item.humidity)%   💨 \(item.windSpeed) m/s   Feels \(Int(item.feelsLike))°"
            cell.detailTextLabel?.textColor = .gray
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as! ForecastCell
        let item = dailyItems[indexPath.row]
        cell.configure(day: item.day, min: item.min, max: item.max, icon: item.icon,
                       globalMin: globalMinTemp, globalMax: globalMaxTemp)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 60 }
}

extension ForecastViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        hourlyItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath) as! HourlyCell
        let item = hourlyItems[indexPath.row]
        cell.configure(time: formatHour(item.dt), temp: item.main.temp, icon: item.weather.first?.icon ?? "01d")
        return cell
    }
}
