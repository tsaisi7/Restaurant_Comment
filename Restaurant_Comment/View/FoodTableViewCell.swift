//
//  FoodTableViewCell.swift
//  Restaurant_Comment
//
//  Created by Adam on 2021/11/18.
//

import UIKit
import Alamofire
import AlamofireImage

class FoodTableViewCell: UITableViewCell {
    
    @IBOutlet var foodCollectionView: UICollectionView!
    var foods: [Food] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureCellSize()
        foodCollectionView.dataSource = self
        foodCollectionView.delegate = self
    }
    
    func configureCellSize() {
            let itemSpace: CGFloat = 3
            let columnCount: CGFloat = 2
            
        let flowLayout = foodCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let width = floor((foodCollectionView.bounds.width - itemSpace * (columnCount-1)) / columnCount)
        print(width)
        flowLayout?.itemSize = CGSize(width: width-10, height: width-10)
        flowLayout?.estimatedItemSize = .zero
        flowLayout?.minimumInteritemSpacing = itemSpace
        flowLayout?.minimumLineSpacing = itemSpace
            
    }
    func reloadData() {
        self.foodCollectionView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
extension FoodTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = foodCollectionView.dequeueReusableCell(withReuseIdentifier: "foodCollectionCell", for: indexPath) as! FoodCollectionViewCell
        AF.request(self.foods[indexPath.row].image).responseImage { response in
            if case .success(let image) = response.result {
                cell.foodImageView.image = image
            }
        }
        
        return cell
    }
    
    
}
