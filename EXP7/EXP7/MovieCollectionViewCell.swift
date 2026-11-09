//
// MovieCollectionViewCell.swift
// LabExp7CollectionView
//
// Created by SHIRO on 06/03/26.
//
import UIKit
class MovieCollectionViewCell: UICollectionViewCell {
@IBOutlet weak var titleLbl: UILabel!
@IBOutlet weak var movieImageView: UIImageView!

func setup(with movie: Movie) {
movieImageView.image = movie.image
titleLbl.text = movie.title
}
}
