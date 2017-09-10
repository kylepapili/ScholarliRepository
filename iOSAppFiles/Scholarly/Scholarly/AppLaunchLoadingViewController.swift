//
//  AppLaunchLoadingViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 7/14/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit

class AppLaunchLoadingViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet var IndicatorView: UIActivityIndicatorView!
    
    @IBAction func BailoutToLoginScreen(_ sender: Any) {
        LogoutAction(completion: {
            //Return to LoginVC
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginScreenVC") as! LoginScreenViewController
            self.present(loginVC, animated: true, completion: nil)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        IndicatorView.startAnimating()
        // Do any additional setup after loading the view.
    }

}
