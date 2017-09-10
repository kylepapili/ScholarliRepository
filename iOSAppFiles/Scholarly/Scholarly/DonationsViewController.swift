//
//  DonationsViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 7/12/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit

class DonationsViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

    
    @IBAction func DonateButtonPress(_ sender: Any) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Donate", message: "Thank you for your interest. Unfortunately we are not accepting donations at this time, please check again in the near future.", preferredStyle: .alert)
        
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
        }
        
        // Add the actions
        alertController.addAction(okAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
        //UIApplication.shared.openURL(URL(string: "http://papili.us/scholarli/donate.html")!)
    }

}
