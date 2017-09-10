//
//  FlagViewController.swift
//  Scholarli
//
//  Created by Kyle Papili on 8/21/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import Firebase

class FlagViewController: UIViewController {
    
    //Outlets
    @IBOutlet var FlagContent: UILabel!
    @IBOutlet var FlagExplanation: UILabel!
    @IBOutlet var FlagImage: UIImageView!
    @IBOutlet var FlagMessage: UIButton!
    @IBOutlet var BlockUserButton: UIButton!
    
    
    //Properties
    var message : Message? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let messageToCheck = message else {
            print("Error in FlagVC")
            return
        }
        messageHasFlag(message: messageToCheck, completion: { (result) in
            if result {
                //Message Has Flag
                self.FlagMessage.setTitle("This Message Has Already Been Flagged", for: .normal)
                self.FlagMessage.setTitleColor(UIColor.gray, for: .normal)
            } else {
                //Message Does Not Have Flag
            }
        })
        userIsBlocked(CurrentUserUid: (Auth.auth().currentUser?.uid)!, BlockedUserUid: messageToCheck.uid) { (result) in
            if result {
                //User is Blocked
                self.BlockUserButton.setTitle("This User Has Already Been Blocked", for: .normal)
                self.BlockUserButton.setTitleColor(UIColor.gray, for: .normal)
            } else {
                //User is not already blocked
            }
        }
    }
    
    @IBAction func FlagMessage(_ sender: Any) {
        if FlagMessage.titleLabel?.text == "This Message Has Already Been Flagged" {
            //Shake button
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 3
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: FlagMessage.center.x - 8, y: FlagMessage.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: FlagMessage.center.x + 8, y: FlagMessage.center.y))
            FlagMessage.layer.add(animation, forKey: "position")
            return
        } else {
            guard let messageToFlag = message as? Message else {
                print("Error in FlagVC FlagMessage()")
                return
            }
            AddFlaggTo(message: messageToFlag) { (result) in
                var alertTitle : String = ""
                var alertMessage : String = ""
                switch result {
                case .alreadyHasFlag:
                    //Alert "already has flag"
                    print("1")
                    alertTitle = "Flag"
                    alertMessage = "This Message already has a flag."
                case .flagAdded:
                    //Alert "Flag added"
                    print("2")
                    alertTitle = "Flag Added"
                    alertMessage = "This Message Has Been Flagged, thank you."
                case .unableToAddFlag:
                    //Alert: "Unable to add flag"
                    print("3")
                    alertTitle = "Error"
                    alertMessage = "We were unable to flag that message, please try again later."
                }
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    //Return to ChatLogVC
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func BlockUserAction(_ sender: Any) {
        if BlockUserButton.titleLabel?.text == "This User Has Already Been Blocked" {
            //Shake button
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 3
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: BlockUserButton.center.x - 8, y: BlockUserButton.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: BlockUserButton.center.x + 8, y: BlockUserButton.center.y))
            BlockUserButton.layer.add(animation, forKey: "position")
            return
        } else {
            guard let uid = message?.uid else {
                print("Error in BlockUserAction")
                return
            }
            BlockUser(uid: (uid)) { (result) in
                var alertTitle : String = ""
                var alertMessage : String = ""
                switch result {
                case .userAlreadyBlocked:
                    //Alert "User already blocked"
                    print("1")
                    alertTitle = "User Already Blocked"
                    alertMessage = "This user has already been blocked."
                case .unableToBlockUser:
                    //Alert "Unable to Block User"
                    print("2")
                    alertTitle = "Unable to Block User"
                    alertMessage = "We were unable to block this user, please try again later."
                case .userBlocked:
                    //Alert "User Blocked"
                    print("3")
                    alertTitle = "User Blocked"
                    alertMessage = "You will no longer recieve messages from this user."
                }
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    //Return to ChatLogVC
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    

}
