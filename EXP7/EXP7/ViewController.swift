//
// ViewController.swift
// LabExp7CollectionView
//
// Created by shiro on 06/03/26.
//
import UIKit
class ViewController: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout{
@IBOutlet weak var collectionView: UICollectionView!

override func viewDidLoad() {
super.viewDidLoad()
// Do any additional setup after loading the view.
collectionView.dataSource = self
collectionView.delegate = self
collectionView.collectionViewLayout =
UICollectionViewFlowLayout()
}
func collectionView(_ collectionView: UICollectionView,
numberOfItemsInSection section: Int) -> Int {
return movie.count
}
func collectionView(_ collectionView: UICollectionView,
cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
let cell =
collectionView.dequeueReusableCell(withReuseIdentifier:
"MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
cell.setup(with: movie[indexPath.row])
return cell
}
func collectionView(_ collectionView: UICollectionView, layout
collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath:
IndexPath) -> CGSize {
return CGSize(width: 200 , height: 300)
}

func collectionView(_ collectionView: UICollectionView,
didSelectItemAt indexPath: IndexPath) {
print(movie[indexPath.row].title)
}

}
