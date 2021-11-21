//
//  FoodViewController.swift
//  Restaurant_Comment
//
//  Created by Adam on 2021/11/19.
//

import UIKit
import Alamofire
import AlamofireImage

class FoodViewController: UIViewController {
    
    @IBOutlet var foodCollectionView: UICollectionView!
    var foods:[Food] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        foodCollectionView.delegate = self
        foodCollectionView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFoodDetail"{
            if let cell = sender as? FoodDetailCollectionViewCell, let indexPath = foodCollectionView.indexPath(for: cell){
                let destinationController = segue.destination as! FoodDetailViewController
                destinationController.food = foods[indexPath.row]
                print(indexPath.row)
            }

        }
    }
}
extension FoodViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(foods.count)
        return foods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = foodCollectionView.dequeueReusableCell(withReuseIdentifier: "foodDetailCell", for: indexPath) as! FoodDetailCollectionViewCell
        AF.request(self.foods[indexPath.row].image).responseImage { response in
            if case .success(let image) = response.result {
                cell.foodImageView.image = image
            }
        }

        return cell
        
    }
    
}
