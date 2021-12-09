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
    
    // IBOutlet 連接 storyboard
    
    var restaurants: [Restaurant] = []
    var restaurantScore = 0.0
    var user: User!
    var searchController: UISearchController!
    var searchArray: [Restaurant] = []
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
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "餐廳查詢"
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.tintColor = UIColor(red: 255/255, green: 180/255, blue: 75/255, alpha: 1.0)
        self.navigationItem.searchController = searchController
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: "更新中")
    }
    
    @objc func handleRefresh(){
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
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
        return searchController.isActive ? searchArray.count : restaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as! RestaurantTableViewCell
        
        if searchController.isActive {
            cell.nameLabel.text = searchArray[indexPath.row].name
            cell.locationLabel.text = searchArray[indexPath.row].location
            cell.dateLabel.text = searchArray[indexPath.row].date
            cell.typeLabel.text = searchArray[indexPath.row].type
            cell.scoreLabel.text = searchArray[indexPath.row].score
            AF.request(self.searchArray[indexPath.row].image).responseImage { response in
                if case .success(let image) = response.result {
                    cell.restaurantImageView.image = image
                }
            }
        } else{
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
        }

        return cell
    }
}
extension HomepageViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else{
            return
        }
        searchArray = restaurants.filter { (Restaurant) -> Bool in
            return Restaurant.name.localizedCaseInsensitiveContains(searchText)
        }
        tableView.reloadData()
    }
}
