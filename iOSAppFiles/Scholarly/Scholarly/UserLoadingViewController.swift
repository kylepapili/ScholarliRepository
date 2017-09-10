//
//  UserLoadingViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/25/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import Firebase

class UserLoadingViewController: UIViewController {
    var window: UIWindow?
    let UserClasses = UserDefaults.standard.value(forKey: "Classes") as? Array<Any>
    var ClassData = [[String: AnyObject]]()
    var ClassDataFinal = [[String: AnyObject]]()
    @IBOutlet var LoadingIndicator: UIActivityIndicatorView!
    @IBAction func BailOutToLoginScreen(_ sender: Any) {
        LogoutAction(completion: {
            //Return to LoginVC
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginScreenVC") as! LoginScreenViewController
            self.present(loginVC, animated: true, completion: nil)
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareClassData { (ResultData) in
            print(ResultData)
            UniversalClassData = ResultData
            self.proceedToNextViewController()
        }
    }

    func proceedToNextViewController() {
        DispatchQueue.main.async(execute: {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "HomeScreenVC")
            self.show(vc, sender: self)
        })
    }

}
