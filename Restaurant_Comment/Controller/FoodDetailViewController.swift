//
//  FoodDetailViewController.swift
//  Restaurant_Comment
//
//  Created by Adam on 2021/11/19.
//

import UIKit
import Alamofire
import AlamofireImage
import Firebase
import FirebaseAuth
import FirebaseCore

class FoodDetailViewController: UIViewController {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var foodImageView: UIImageView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var cpValueLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var rateButton: UIButton!{
        didSet{
            rateButton.layer.cornerRadius = 8
        }
    }
    @IBOutlet var rateImageView: UIImageView!

    var food: Food!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = food.name
        AF.request(self.food.image).responseImage { response in
            if case .success(let image) = response.result {
                self.foodImageView.image = image
            }
        }
        priceLabel.text = food.price
        cpValueLabel.text = food.cpVale
        descriptionTextView.text = food.descriptioin
        readData()
    }
    let ref = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid)
    func readData(){
        self.ref.collection("Foods").document(self.food.restaurantID).collection("Food").document(self.food.foodID).addSnapshotListener { (snapshot, error) in
            if let error = error{
                print(error.localizedDescription)
            }
            if let snapshot = snapshot{
                self.food.rating = Food.Rating(rawValue: snapshot.data()!["rate"] as! String)
                if let image = self.food.rating?.image{
                    self.rateImageView.image = UIImage(named: image)
                }
            }
        }
    }
            
    @IBAction func rateFood(segue: UIStoryboardSegue){
        guard let identifier = segue.identifier else {
            return
        }
        
        dismiss(animated: true) {
            if let rating = Food.Rating(rawValue: identifier){
                self.food.rating = rating
                self.rateImageView.image = UIImage(named: rating.image)
            }
            self.ref.collection("Foods").document(self.food.restaurantID).collection("Food").document(self.food.foodID).updateData(["rate": identifier])
            let scaleTranform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
            self.rateImageView.transform = scaleTranform
            self.rateImageView.alpha = 0
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.7, options: []) {
                self.rateImageView.transform = .identity
                self.rateImageView.alpha = 1
            }
        }
    }
}
