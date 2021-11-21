//
//  ProfileViewController.swift
//  Restaurant_Comment
//
//  Created by Adam on 2021/11/19.
//

import UIKit
import Firebase
import FirebaseAuth
import Alamofire
import AlamofireImage

class ProfileViewController: UIViewController {
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var userEmailTextField: UITextField!
    @IBOutlet var userPasswrodTextField: UITextField!
    @IBOutlet var userImageView: UIImageView!
    
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField.text = user.name
        userNameTextField.isEnabled = false
        userEmailTextField.text = user.email
        userEmailTextField.isEnabled = false
        userPasswrodTextField.text = user.password
        userPasswrodTextField.isEnabled = false
        AF.request(self.user.image).responseImage { response in
            if case .success(let image) = response.result {
                self.userImageView.image = image
            }
        }
    }
    
    @IBAction func logout(){
        do {
            try Auth.auth().signOut()
            let loginVC = self.storyboard?.instantiateViewController(identifier: "loginVC")
            let delegate: SceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
            delegate.window?.rootViewController = loginVC
            
        } catch let signoutError as NSError{
            print(signoutError)
        }
        
    }

}
