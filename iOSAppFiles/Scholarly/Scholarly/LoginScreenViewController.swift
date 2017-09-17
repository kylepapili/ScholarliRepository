//
//  LoginScreenViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/20/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseMessaging

class LoginScreenViewController: UIViewController {
    @IBOutlet var emailText: UITextField!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var confirmPasswordText: UITextField!
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var errorLabel : UILabel!
    @IBOutlet var ActivityIndicator: UIActivityIndicatorView!
    
    
    
    var userState : currentState = .login
    
    enum currentState{
        case login , signup
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actionButton.setTitle("Login", for: .normal)
        errorLabel.isHidden = true
        confirmPasswordText.isHidden = true
        ActivityIndicator.isHidden = true
    }
    
    @IBAction func action (_ sender: Any) {
        ActivityIndicator.isHidden = false
        ActivityIndicator.startAnimating()
        if emailText.text == "" || passwordText.text == "" {
            //Error, insufficient information
            errorLabel.text = "All Fields Must Be Completed"
            errorLabel.isHidden = false
            ActivityIndicator.isHidden = true
            return
        }
        switch userState {
        case .login:
            Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                if user != nil {
                    //Login Successful
                    doesUserExist(userToTest: user, completion: { (userExists, completedSetup) in
                        if userExists {
                            if completedSetup {
                                let token = Messaging.messaging().fcmToken
                                let ref = Database.database().reference().child("users").child((user?.uid)!)
                                ref.child("info").child("pushToken").setValue(token)
                                
                                prepareUserDefaults(completionHandler: {
                                    setNotificationStatus(readyToReceive: true, completionHandler: {
                                        self.performSegue(withIdentifier: "loginsegue", sender: self)
                                    })
                                })
                            } else {
                                self.userNeedsToCompleteSetup()
                            }
                        } else {
                            self.errorLabel.text = "User does not exist"
                            self.errorLabel.isHidden = false
                        }
                    })
                    
                } else {
                    //Unable to Login
                    guard let myError = error?.localizedDescription else {
                        self.errorLabel.text = "Unknown Error"
                        self.errorLabel.isHidden = false
                        self.ActivityIndicator.isHidden = true
                        return
                    }
                    self.errorLabel.text = myError
                    self.errorLabel.isHidden = false
                    self.ActivityIndicator.isHidden = true
                }
            })
        case .signup:
            //Sign Up User
            if (passwordText.text == confirmPasswordText.text) {
                Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                    if user != nil {
                        //Sign Up Successful
                        self.performSegue(withIdentifier: "signupsegue", sender: self)
                    } else {
                        //Sign Up Error
                        guard let myError = error?.localizedDescription else {
                            self.errorLabel.text = "Unknown Error"
                            self.errorLabel.isHidden = false
                            self.ActivityIndicator.isHidden = true
                            return
                        }
                        self.errorLabel.text = myError
                        self.errorLabel.isHidden = false
                        self.ActivityIndicator.isHidden = true
                    }
                })
            } else {
                self.errorLabel.text = "Passwords do not match"
                self.errorLabel.isHidden = false
                ActivityIndicator.isHidden = true
            }
        }
    }
    
    @IBAction func UserActionChanged(_ sender: Any) {
        if userState == .login {
            userState = .signup
            actionButton.setTitle("Sign Up", for: .normal)
            confirmPasswordText.isHidden = false
            
        } else {
            userState = .login
            confirmPasswordText.isHidden = true
            actionButton.setTitle("Login", for: .normal)
        }
    }
    
    func userNeedsToCompleteSetup() {
        print("User needs to complete setup")
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "FirstPageVC") as! UIViewController
        self.present(initialViewControlleripad, animated: true, completion: {
            return
        })
    }
}
