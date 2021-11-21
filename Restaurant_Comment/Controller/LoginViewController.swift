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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func login(){
        if emailTextField.text != "" && passwordTextField.text != ""{
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { authResult, error in
                if let error = error {
                    print(error.localizedDescription)
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


}
