//
//  CreateAccountViewController.swift
//  Restaurant_Comment
//
//  Created by Adam on 2021/11/18.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseStorage

class CreateAccountViewController: UIViewController {
    
    @IBOutlet var userImageView: UIImageView!{
        didSet{
            userImageView.layer.cornerRadius = 60
        }
    }
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmTextField: UITextField!
    @IBOutlet var createAccountButton: UIButton!{
        didSet{
            createAccountButton.layer.cornerRadius = 8
        }
    }
    //IBOutlet 連接 storyboard
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    let ref = Firestore.firestore().collection("Users")
    var storageRef = Storage.storage().reference()

    func saveUserData(){
        let userID = Auth.auth().currentUser!.uid
        storageRef = storageRef.child("Users").child(userID).child("\(UUID().uuidString).jpeg")
        let imageData = userImageView.image?.jpegData(compressionQuality: 0.9)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.putData(imageData!, metadata: metaData) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            self.storageRef.downloadURL { (url, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                if let url = url?.absoluteString {
                    print(url)
                    let userData = ["name": self.nameTextField.text! , "email": self.emailTextField.text!, "password": self.passwordTextField.text!, "image": url] as [String: Any]
                    self.ref.document(userID).setData(userData){ error in
                        if let error = error{
                            print(error.localizedDescription)
                        }else{
                            print("User upload")
                            let homePageVC = self.storyboard?.instantiateViewController(withIdentifier: "homePageVC")
                            self.present(homePageVC!, animated: true, completion: nil)
                            
                        }
                    }
                }
            }
        }
    }
    
    // 儲存 User 資訊，利用 FirebaseStorage 先儲存照片，並取得download URL ，再利用 FirebaseCore 儲存資料
    
    @IBAction func chooseImage(){
        let controller = UIAlertController(title: "選取照片", message: "", preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "圖片庫", style: .default) { (UIAlertAction) in
            let controller = UIImagePickerController()
            controller.sourceType = .photoLibrary
            controller.delegate = self
            self.present(controller, animated: true, completion: nil)
        }
        let camaraAction = UIAlertAction(title: "照相機", style: .default) { (UIAlertAction) in
            let controller = UIImagePickerController()
            controller.sourceType = .camera
            controller.delegate = self
            self.present(controller, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        controller.addAction(camaraAction)
        controller.addAction(photoLibraryAction)
        controller.addAction(cancelAction)
        self.present(controller, animated: true, completion: nil)
    }
    // IBAction 連接 storyboard ，利用 UIAlertController 顯現選單，讓使用者選擇 UIImagePickerController's sourceType 是 .photoLibrary or .camera
    
    
    @IBAction func creatAccount(){
        if emailTextField.text != "" && passwordTextField.text != "" && nameTextField.text != "" && confirmTextField.text != ""{
            if passwordTextField.text == confirmTextField.text{
                Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authResult, error in
                    if let error = error{
                        print(error.localizedDescription)
                    }
                    if let authResult = authResult{
                        let user = authResult.user
                        print("\(String(describing: user.email!)) is created" )
                        self.saveUserData()
                    }
                }
            }else{
                let alertController = UIAlertController(title: "提醒", message: "密碼不一樣，請確認", preferredStyle: .alert)
                let okActioin = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okActioin)
                present(alertController, animated: true, completion: nil)
            }
        }else{
            let alertController = UIAlertController(title: "提醒", message: "請輸入所有資料", preferredStyle: .alert)
            let okActioin = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okActioin)
            present(alertController, animated: true, completion: nil)

        }
    }
    // IBAction 連接 storyboard ，利用FirebaseAuth 建立 User ，當成功建立後呼叫 saveUserDate() 儲存使用者資料
}
extension CreateAccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        userImageView.image = (info[.originalImage] as! UIImage)
        dismiss(animated: true, completion: nil)
    }
    //為 UIImagePickerController 中的方法，完成選取的照片後，將照片放入 userImageView裡面
}
