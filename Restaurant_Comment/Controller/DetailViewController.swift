//
//  DetailViewController.swift
//  Restaurant_Comment
//
//  Created by Adam on 2021/11/18.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import Alamofire
import AlamofireImage

class DetailViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var restaurantImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    
    var restaurant: Restaurant!
//    var foods:[Food] = [Food(name: "濃郁咖啡", image: "cafeloisl", price: "180", cpVale: "高", descriptioin: "濃郁美味，很好喝", rating: Food.Rating(rawValue: "five")),Food(name: "特條咖啡", image: "cafedeadend", price: "220", cpVale: "高", descriptioin: "很特別的拉花，非常順口好喝", rating: Food.Rating(rawValue: "five"))]
    var foods: [Food] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        self.navigationController?.navigationBar.shadowImage = image
        AF.request(self.restaurant.image).responseImage { response in
            if case .success(let image) = response.result {
                self.restaurantImageView.image = image
            }
        }
        nameLabel.text = restaurant.name
        typeLabel.text = restaurant.type
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.backButtonTitle = ""
        readData()
        
    }
    let ref = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid)
    
    func readData(){
        self.ref.collection("Foods").document(self.restaurant.id).collection("Food").addSnapshotListener { (snapshot, error) in
            if let error = error{
                print(error.localizedDescription)
            }
            if let snapshot = snapshot{
                self.foods = []
                for document in snapshot.documents{
                    self.foods.append(Food(foodID: document.documentID,restaurantID: self.restaurant.id ,name: document.data()["name"] as! String, image: document.data()["image"] as! String, price: document.data()["price"] as! String, cpVale: document.data()["cpValue"] as! String, descriptioin: document.data()["description"] as! String, rating: Food.Rating(rawValue: document.data()["rate"] as! String)))
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap"{
            let destinationController = segue.destination as! MapViewController
            destinationController.restaurant = restaurant
        }
        if segue.identifier == "showFoodCollection"{
            let destinationController = segue.destination as! FoodViewController
            destinationController.foods = foods
        }
        if segue.identifier == "showAddFood"{
            let destinationController = segue.destination as! AddFoodTableViewController
            destinationController.restaurant = restaurant
        }
    }

}
extension DetailViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell",for: indexPath) as! DetailTableViewCell
            cell.locationLabel.text = restaurant.location
            cell.descriptionTextView.text = restaurant.description
            return cell
        case 1:
            print("1")
            let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath) as! FoodTableViewCell
            DispatchQueue.main.async {
                cell.foods = self.foods
                cell.reloadData()
            }

            return cell
        case 2:
            print("2")
            let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath) as! MapTableViewCell
            cell.configure(location: restaurant.location)
            return cell
        default:
            fatalError("ERROR")
        }
    }
    
    
}
