//
//  UserInfoViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/20/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import Firebase

class UserInfoViewController: UIViewController {
    let ref = Database.database().reference()
    
    
    @IBOutlet var FirstNameText: UITextField!
    @IBOutlet var LastNameText: UITextField!
    @IBOutlet var PhoneNumberText: UITextField!
    @IBOutlet var ErrorText: UILabel!
    
    var containsForeignCharacters: Bool = false
    
    @IBAction func action(_ sender: Any) {
        if (FirstNameText.text != "" && LastNameText.text != "" && PhoneNumberText.text != "")  {
            if (Int(PhoneNumberText.text!) != nil) {
                if (!(containsForeignCharacters)) {
                    //Add User info to database
                    self.ref.child("users").child((Auth.auth().currentUser?.uid)!).child("info").child("FirstName").setValue(FirstNameText.text!)
                    self.ref.child("users").child((Auth.auth().currentUser?.uid)!).child("info").child("LastName").setValue(LastNameText.text!)
                    self.ref.child("users").child((Auth.auth().currentUser?.uid)!).child("info").child("PhoneNumber").setValue(PhoneNumberText.text!)
                    
                    
                    
                    //Fetch School List for Next Screen
                    _ = self.ref.child("schools").observe(DataEventType.value, with: { (FIRDataSnapshot) in
                        guard let dataDict = FIRDataSnapshot.value as? NSDictionary else {
                            print("Error in IBAction")
                            return
                        }
                        guard let arrayToPass = (Array(dataDict.allValues)) as? [String] else {
                            print("Error in IBAction")
                            return
                        }
                        let SchoolSelectorViewController = self.storyboard?.instantiateViewController(withIdentifier:"schoolSelectorVC") as! SchoolSelectorViewController
                        SchoolSelectorViewController.schools = arrayToPass
                        
                        
                        self.present(SchoolSelectorViewController, animated
                            : true, completion: nil)
                    })
                }
            }
            
        } else {
            ErrorText.text = "All Fields Must Be Completed"
            ErrorText.isHidden = false
            
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 3
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: self.ErrorText.center.x - 8, y: self.ErrorText.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: self.ErrorText.center.x + 8, y: self.ErrorText.center.y))
            self.ErrorText.layer.add(animation, forKey: "position")

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
