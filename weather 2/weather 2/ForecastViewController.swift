
//
//  ForecastViewController.swift
//  weather
//

import UIKit

// MARK: - Forecast Models

struct ForecastResponse: Codable {
    let list: [ForecastItem]
    let city: City
}

struct ForecastItem: Codable {
    let dt: Int
    let main: Main
    let weather: [Weather]
    let dt_txt: String
}

struct City: Codable {
    let name: String
}

// MARK: - View Controller

class ForecastViewController: UIViewController {

    var latitude: Double = 0
    var longitude: Double = 0
    var cityName: String = ""
    var currentTemp: Double = 0

    let apiKey = "b82b26ab9d5098418040d0eb36ef7256"

    // MARK: - Outlets
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Data
    var hourlyItems: [ForecastItem] = []
    var dailyItems: [(day: String, min: Double, max: Double, icon: String)] = []

    // MARK: - Lifecycle

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

        segmentControl.selectedSegmentIndex = 1

        fetchForecast()
    }

    // MARK: - Gradient

    func setGradientHeader() {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 160)
        gradient.colors = [UIColor.systemBlue.cgColor, UIColor.systemTeal.cgColor]
        view.layer.insertSublayer(gradient, at: 0)
    }

    // MARK: - Segment

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        collectionView.isHidden = sender.selectedSegmentIndex != 0
        tableView.isHidden = sender.selectedSegmentIndex == 0
        tableView.reloadData()
        collectionView.reloadData()
    }

    // MARK: - Fetch

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
                    print("✅ Daily items count:", self.dailyItems.count)
                    print("✅ Hourly items count:", self.hourlyItems.count)
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                }
            } catch {
                print("Forecast error:", error)
            }
        }
    }

    // MARK: - Process Data

    func processHourly(_ items: [ForecastItem]) {
        hourlyItems = Array(items.prefix(8))
    }

    func processDaily(_ items: [ForecastItem]) {
        var grouped: [String: [ForecastItem]] = [:]

        for item in items {
            let key = String(item.dt_txt.prefix(10))
            grouped[key, default: []].append(item)
        }

        dailyItems = grouped.sorted { $0.key < $1.key }.map { (key, vals) in
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "yyyy-MM-dd"
            let date = dayFormatter.date(from: key) ?? Date()
            let display = DateFormatter()
            display.dateFormat = "EEE"
            let min = vals.map { $0.main.temp }.min() ?? 0
            let max = vals.map { $0.main.temp }.max() ?? 0
            let icon = vals.first?.weather.first?.icon ?? "01d"
            return (display.string(from: date), min, max, icon)
        }
    }

    func formatHour(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let f = DateFormatter()
        f.dateFormat = "ha"
        return f.string(from: date)
    }
}

// MARK: - TableView

extension ForecastViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dailyItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Loading cell at row", indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as! ForecastCell
        let item = dailyItems[indexPath.row]
        cell.configure(day: item.day, min: item.min, max: item.max, icon: item.icon)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 60 }
}

// MARK: - CollectionView

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
