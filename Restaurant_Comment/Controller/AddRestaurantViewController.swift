//
//  AddRestaurantViewController.swift
//  Restaurant_Comment
//
//  Created by Adam on 2021/11/19.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseStorage

class AddRestaurantViewController: UITableViewController {

    @IBOutlet var restaurantImageView: UIImageView!{
        didSet{
            restaurantImageView.layer.cornerRadius = 12
        }
    }
    @IBOutlet var restaurantNameTextField: UITextField!
    @IBOutlet var restaurantTypeTextField: UITextField!
    @IBOutlet var restaurantLocationTextField: UITextField!
    @IBOutlet var restaurantDatePicker: UIDatePicker!
    @IBOutlet var restaurantDescriptionTextView: UITextView!
    @IBOutlet var foodImageView: UIImageView!{
        didSet{
            foodImageView.layer.cornerRadius = 12
        }
    }
    @IBOutlet var foodNameTextField: UITextField!
    @IBOutlet var foodPriceTextField: UITextField!
    @IBOutlet var foodCPValuePicker: UIPickerView!
    @IBOutlet var foodDescriptionTextView: UITextView!
    @IBOutlet var createButton: UIButton!{
        didSet{
            createButton.layer.cornerRadius = 8
        }
    }
    var cpValues = ["超高","不錯","普通","偏低","虧爆"]
    var cpValue: String = ""
    var date:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restaurantDatePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
        restaurantDatePicker.locale = Locale(identifier: "zh_TW")
        restaurantDatePicker.preferredDatePickerStyle = .wheels
        restaurantDatePicker.addTarget(self, action: #selector(self.datePickerChanged), for: .valueChanged)
        getDate()
        cpValue = cpValues[0]
        foodCPValuePicker.delegate = self
        foodCPValuePicker.dataSource = self
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func datePickerChanged(datePicker:UIDatePicker) {
        getDate()
        print(date)
    }
    func getDate(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        date = formatter.string(from: restaurantDatePicker.date)
    }
    var selectedIndex = 0
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 || indexPath.row == 4{
            var message = ""
            
            switch indexPath.row {
            case 1:
                selectedIndex = 0
                message = "選擇餐廳照片來源"
            case 4:
                selectedIndex = 1
                message = "選擇餐點照片來源"
            default:
                return
            }
            
            let photoSourceRequestController = UIAlertController(title: "", message: message, preferredStyle: .actionSheet)
            let cameraAction = UIAlertAction(title: "相機", style: .default) { (action) in
                if UIImagePickerController.isSourceTypeAvailable(.camera){
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .camera
                    imagePicker.delegate = self
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
            let photoLibraryAction = UIAlertAction(title: "圖片庫", style: .default) { (action) in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.delegate = self
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
            photoSourceRequestController.addAction(cameraAction)
            photoSourceRequestController.addAction(photoLibraryAction)
            present(photoSourceRequestController, animated: true, completion: nil)
            
        }
    }
    @IBAction func createRestaurant(){
        if restaurantImageView.image != nil && restaurantNameTextField.text != "" && restaurantTypeTextField.text != "" && restaurantLocationTextField.text != "" && restaurantDescriptionTextView.text != "" && foodImageView.image != nil && foodNameTextField.text != "" && foodPriceTextField.text != ""  && foodDescriptionTextView.text != "" {
            let restaurantID = UUID().uuidString
            let queue = DispatchQueue.main
            var restaurantStorageRef = Storage.storage().reference()
            var foodStorageRef = Storage.storage().reference()
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            let ref = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid)
            queue.async {
                let restaurantImageData = self.restaurantImageView.image?.jpegData(compressionQuality: 0.9)
                restaurantStorageRef = restaurantStorageRef.child("Users").child(Auth.auth().currentUser!.uid).child("Restuaurant").child("\(UUID().uuidString).jpeg")
                restaurantStorageRef.putData(restaurantImageData!, metadata: metaData) { (data, error) in
                    if let error = error{
                        print(error.localizedDescription)
                    }
                    restaurantStorageRef.downloadURL { (url, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        if let url = url?.absoluteString{
                            let restaurantData = ["restaurantID": restaurantID,"name": self.restaurantNameTextField.text!, "image": url , "type": self.restaurantTypeTextField.text!, "location": self.restaurantLocationTextField.text!, "date": self.date, "description": self.restaurantDescriptionTextView.text!, "score": "尚未評分"] as [String: Any]
                            ref.collection("Restaurants").document(restaurantID).setData(restaurantData) { (error) in
                                if let error = error{
                                    print(error.localizedDescription)
                                }else{
                                    print("Restaurant uploaded")
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
                
            }
            let foodImageData = self.foodImageView.image?.jpegData(compressionQuality: 0.9)
            foodStorageRef = foodStorageRef.child("Users").child(Auth.auth().currentUser!.uid).child("Food").child("\(UUID().uuidString).jpeg")
            foodStorageRef.putData(foodImageData!, metadata: metaData) { (data, error) in
                if let error = error{
                    print(error.localizedDescription)
                }
                foodStorageRef.downloadURL { (url, error) in
                    if let error = error{
                        print(error.localizedDescription)
                    }
                    if let url = url?.absoluteString{
                        let foodData = ["restaurantID": restaurantID, "name": self.foodNameTextField.text!, "image": url, "price": self.foodPriceTextField.text!, "cpValue": self.cpValue, "description": self.foodDescriptionTextView.text!, "rate": "zero"] as [String: Any]
                        ref.collection("Foods").document(restaurantID).collection("Food").addDocument(data: foodData) { (error) in
                            if let error = error{
                                print(error.localizedDescription)
                            }else{
                                print("Food uploaded")
                            }
                        }
                    }
                }
            }
        }else{
            print("ERROR")
            let alertController = UIAlertController(title: "提醒", message: "請輸入所有資料", preferredStyle: .alert)
            let okActioin = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okActioin)
            present(alertController, animated: true, completion: nil)
        }
    }
}
extension AddRestaurantViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            switch selectedIndex {
            case 0:
                restaurantImageView.image = selectedImage
                restaurantImageView.contentMode = .scaleAspectFill
                restaurantImageView.clipsToBounds = true
            case 1:
                foodImageView.image = selectedImage
                foodImageView.contentMode = .scaleAspectFill
                foodImageView.clipsToBounds = true
            default:
                return
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
extension AddRestaurantViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cpValues.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cpValues[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        cpValue = cpValues[row]
        print(cpValue)
    }
}
