//
//  HourlyCell.swift
//  weather 2
//
//  Created by shiro on 23/04/26.
//

import UIKit

class HourlyCell: UICollectionViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!

    func configure(time: String, temp: Double, icon: String) {
        timeLabel.text = time
        tempLabel.text = "\(Int(temp))°"
        guard let url = URL(string: "https://openweathermap.org/img/wn/\(icon).png") else { return }
        Task {
            guard let (data, _) = try? await URLSession.shared.data(from: url) else { return }
            await MainActor.run { self.iconView.image = UIImage(data: data) }
        }
    }
}
