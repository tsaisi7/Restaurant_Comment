//
//  AddFoodTableViewController.swift
//  Restaurant_Comment
//
//  Created by Adam on 2021/11/20.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseStorage

class AddFoodTableViewController: UITableViewController {

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
    var restaurant: Restaurant!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cpValue = cpValues[0]
        foodCPValuePicker.delegate = self
        foodCPValuePicker.dataSource = self
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1{
            var message = ""
            message = "選擇餐點照片來源"
            
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
    @IBAction func createFood(){
        if foodImageView.image != nil && foodNameTextField.text != "" && foodPriceTextField.text != ""  && foodDescriptionTextView.text != "" {

            let queue = DispatchQueue.main
            var foodStorageRef = Storage.storage().reference()
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            let ref = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid)
            queue.async {
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
                        let foodData = ["restaurantID": self.restaurant.id, "name": self.foodNameTextField.text!, "image": url, "price": self.foodPriceTextField.text!, "cpValue": self.cpValue, "description": self.foodDescriptionTextView.text!, "rate": "zero"] as [String: Any]
                        ref.collection("Foods").document(self.restaurant.id).collection("Food").addDocument(data: foodData) { (error) in
                            if let error = error{
                                print(error.localizedDescription)
                            }else{
                                print("Food uploaded")
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }}
        }else{
            print("ERROR")
            let alertController = UIAlertController(title: "提醒", message: "請輸入所有資料", preferredStyle: .alert)
            let okActioin = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okActioin)
            present(alertController, animated: true, completion: nil)

        }
    }
}
extension AddFoodTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            foodImageView.image = selectedImage
            foodImageView.contentMode = .scaleAspectFill
            foodImageView.clipsToBounds = true
        }
        dismiss(animated: true, completion: nil)
    }
}
extension AddFoodTableViewController: UIPickerViewDelegate, UIPickerViewDataSource{
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
