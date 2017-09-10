//
//  FinalSetupViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/22/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class FinalSetupViewController: UIViewController {
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func TermsOfService(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://papili.us/scholarli/terms.html")!)
    }
    
    @IBAction func NotificationAction(_ sender: Any) {
        //Ask for Notification Access
        
        //Report to Firebase and crap
        
        //Set Remaining User Defaults and Proceed to Next Screen
        
        //Need to Set User Defaults
        prepareUserDefaults {
        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("info").child("completedSetup").setValue("TRUE")
            
            self.performSegue(withIdentifier: "finalSetupToUserLoad", sender: self)
        }
    }
}
