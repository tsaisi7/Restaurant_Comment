//
//  HomepageViewController.swift
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

class HomepageViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var userImageView: UIImageView!{
        didSet{
            userImageView.layer.cornerRadius = 30
        }
    }
    @IBOutlet var userNameButton: UIButton!
    
//    var restaurants:[Restaurant] = [Restaurant(id: "01", name: "左岸咖啡", image: "cafelore", location: "台北市大安區基隆路四段43號", date: "2021/11/11", type: "咖啡館",description: "很棒的餐廳、很好、一級棒", score: "4.6")]
    var restaurants: [Restaurant] = []
    var restaurantScore = 0.0
    var user: User!
    enum score: String {
        case five
        case four
        case three
        case two
        case one
        case zero
        var restaurantScore: Int{
            switch self {
            case .five:
                return 5
            case .four:
                return 4
            case .three:
                return 3
            case .two:
                return 2
            case .one:
                return 1
            case .zero:
                return 0
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        self.navigationController?.navigationBar.shadowImage = image
        readData()
        tableView.delegate = self
        tableView.dataSource = self
    }

    let ref = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid)
    
    func readData(){
        self.ref.getDocument { (snapshot, error) in
            if let error = error{
                print(error.localizedDescription)
            }
            if let snapshot = snapshot{
                self.user = User(name: snapshot.data()!["name"] as! String, email: snapshot.data()!["email"] as! String, password: snapshot.data()!["password"] as! String, image: snapshot.data()!["image"] as! String)
                AF.request(self.user.image).responseImage { response in
                    if case .success(let image) = response.result {
                        self.userImageView.image = image
                    }
                }
                self.userNameButton.setTitle(self.user.name, for: .normal)
            }
        }
        self.ref.collection("Restaurants").addSnapshotListener { (snapshot, error) in
            if let error = error{
                print(error.localizedDescription)
            }
            if let snapshot = snapshot{
                self.restaurants = []
                for document in snapshot.documents{
                    
                    self.ref.collection("Foods").document(document.documentID).collection("Food").addSnapshotListener { (snapshot, error) in
                        if let error = error{
                            print(error.localizedDescription)
                        }
                        if let snapshot = snapshot{

                            self.restaurantScore = 0.0
                            var count = snapshot.documents.count
                            for document in snapshot.documents{
                                if Double(score(rawValue: document.data()["rate"] as! String)!.restaurantScore) == 0.0{
                                    count -= 1
                                }
                                self.restaurantScore += Double(score(rawValue: document.data()["rate"] as! String)!.restaurantScore)
                            }
                            if self.restaurantScore == 0.0{
                                self.ref.collection("Restaurants").document(document.documentID).updateData(["score": "尚未評分"])
                            }else{
                                self.ref.collection("Restaurants").document(document.documentID).updateData(["score": String(format: "%.1f",self.restaurantScore / Double(count))])
                            }
                        }
                    }
    
                    self.restaurants.append(Restaurant(id: document.data()["restaurantID"] as! String, name: document.data()["name"] as! String, image: document.data()["image"] as! String, location: document.data()["location"] as! String, date: document.data()["date"] as! String, type: document.data()["type"] as! String, description: document.data()["description"] as! String, score: document.data()["score"] as! String))
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"{
            if let indexPath = tableView.indexPathForSelectedRow{
                let destinationController = segue.destination as! DetailViewController
                destinationController.restaurant = restaurants[indexPath.row]
                
            }
        }
        if segue.identifier == "showProfile"{
            let destinationController = segue.destination as! ProfileViewController
            destinationController.user = user
                
            
        }

    }
}
extension HomepageViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as! RestaurantTableViewCell
        cell.nameLabel.text = restaurants[indexPath.row].name
        cell.locationLabel.text = restaurants[indexPath.row].location
        cell.dateLabel.text = restaurants[indexPath.row].date
        cell.typeLabel.text = restaurants[indexPath.row].type
        cell.scoreLabel.text = restaurants[indexPath.row].score
        AF.request(self.restaurants[indexPath.row].image).responseImage { response in
            if case .success(let image) = response.result {
                cell.restaurantImageView.image = image
            }
        }
        return cell
    }
}
