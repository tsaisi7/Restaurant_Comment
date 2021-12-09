//
//  LoginViewController.swift
//  Restaurant_Comment
//
//  Created by Adam on 2021/11/18.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!{
        didSet{
            loginButton.layer.cornerRadius = 8
        }
    }
    // IBOutlet 連接 storyboard
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func login(){
        if emailTextField.text != "" && passwordTextField.text != ""{
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { authResult, error in
                if let error = error {
                    print(error.localizedDescription)
                    let alertController = UIAlertController(title: "提醒", message: "帳號或密碼錯誤", preferredStyle: .alert)
                    let okActioin = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okActioin)
                    self.present(alertController, animated: true, completion: nil)

                }
                if let authResult = authResult{
                    let user = authResult.user
                    print("\(String(describing: user.email!)) is login")
                    let homePageVC = self.storyboard?.instantiateViewController(withIdentifier: "homePageVC")
                    self.present(homePageVC!, animated: true, completion: nil)
                }
              
            }
        }

    }
    // User 登入，利用FirebaseAuth 的 signIn()方法登入

}
