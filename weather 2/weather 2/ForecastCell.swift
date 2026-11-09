
//
//  Created by shiro on 23/04/26.
//
//
//  ForecastCell.swift
//  weather
//
import UIKit

class ForecastCell: UITableViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var minMaxLabel: UILabel!
    @IBOutlet weak var tempBar: UIProgressView!

    func configure(day: String,
                   min: Double,
                   max: Double,
                   icon: String,
                   globalMin: Double,
                   globalMax: Double) {

        dayLabel.text = day
        minMaxLabel.text = "\(Int(min))° / \(Int(max))°"

        let range = globalMax - globalMin
        let progress = (max - globalMin) / range

        tempBar.progress = Float(progress)

        // 🔥 UI improvement
        tempBar.transform = CGAffineTransform(scaleX: 1, y: 2)
        tempBar.layer.cornerRadius = 3
        tempBar.clipsToBounds = true
        tempBar.progressTintColor = .systemTeal

        loadIcon(icon)
    }

    func loadIcon(_ icon: String) {
        guard let url = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png") else { return }

        Task {
            guard let (data, _) = try? await URLSession.shared.data(from: url) else { return }
            await MainActor.run {
                self.iconView.image = UIImage(data: data)
            }
        }
    }
}
