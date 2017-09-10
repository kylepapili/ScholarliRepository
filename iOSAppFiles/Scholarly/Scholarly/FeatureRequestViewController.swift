//
//  FeatureRequestViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 7/12/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import Firebase
class FeatureRequestViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet var FeatureRequestTextView: UITextView!
    @IBOutlet var ErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ErrorLabel.isHidden = true
        let myColor : UIColor = UIColor.gray
        FeatureRequestTextView.layer.borderColor = myColor.cgColor
        FeatureRequestTextView.layer.borderWidth = 1.0
        FeatureRequestTextView.clipsToBounds = true
        FeatureRequestTextView.layer.cornerRadius = 10.0
    }
    
    @IBAction func SendReport(_ sender: Any) {
        guard let bugReport = FeatureRequestTextView.text else {
            print("Error: Found nil in BugReportViewController")
            return
        }
        
        if bugReport == "" {
            ErrorLabel.text = "Feature Request May Not Be Left Blank"
            ErrorLabel.isHidden = false
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.05
            animation.repeatCount = 3
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: self.ErrorLabel.center.x - 8, y: self.ErrorLabel.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: self.ErrorLabel.center.x + 8, y: self.ErrorLabel.center.y))
            self.ErrorLabel.layer.add(animation, forKey: "position")
            return
        }
        
        let ref = Database.database().reference().child("FeatureRequests").childByAutoId()
        
        guard let childValues = ["UID" : Auth.auth().currentUser?.uid,
                                 "firstName" : UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.FirstName)),
                                 "lastName" : UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.LastName)),
                                 "featureDescription" : bugReport] as? [String : String] else {
                                    print("Error: Found nil in BugReportViewController")
                                    return
        }
        
        ref.updateChildValues(childValues)
        
        finishedSendingFeatureRequest()
    }
    
    func finishedSendingFeatureRequest() {
        let alert = UIAlertController(title: "Request Sent", message: "Thank You for your contribution!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
            _ = self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
