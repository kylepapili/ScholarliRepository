//
//  FourthViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/24/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class FourthViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    //Variables
    let options : Array = ["Your Profile" , "About" , "Report a Bug" , "Request a Feature" , "Donate" , "Logout"]
    let optionImages : [UIImage] = [#imageLiteral(resourceName: "Profile") , #imageLiteral(resourceName: "About") , #imageLiteral(resourceName: "Bug") , #imageLiteral(resourceName: "Feature") , #imageLiteral(resourceName: "Donation") , #imageLiteral(resourceName: "Logout")]
    
    //Outlets
    @IBOutlet var TableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SettingsSelectionTableViewCell
        cell.SelectionOutlet.text = options[indexPath.row]
        cell.imageView?.image = optionImages[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            //Profile
            self.performSegue(withIdentifier: "profileSegue", sender: self)
            break
        case 1:
            //About
            self.performSegue(withIdentifier: "aboutSegue", sender: self)
            break
        case 2:
            //Bug Report
            self.performSegue(withIdentifier: "bugReportSegue", sender: self)
            break
        case 3:
            //Request a Feature
            self.performSegue(withIdentifier: "featureRequestSegue", sender: self)
            break
        case 4:
            //Donations
            self.performSegue(withIdentifier: "donationSegue", sender: self)
            break
        case 5:
            //Logout
            // Create the alert controller
            let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
            
            // Create the actions
            let yesAction = UIAlertAction(title: "Logout", style: UIAlertActionStyle.default) {
                UIAlertAction in
                LogoutAction(completion: {
                    //Return to LoginVC
                    let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginScreenVC") as! LoginScreenViewController
                    self.present(loginVC, animated: true, completion: nil)
                })
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
            }
            
            // Add the actions
            alertController.addAction(yesAction)
            alertController.addAction(cancelAction)
            
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
            
            break
        default: break
            //nothing yet
        }
    }
    
    
}


func LogoutAction(completion: @escaping () -> Void) {
    setNotificationStatus(readyToReceive: false) {
        //Delete Push Token ID
        let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
        ref.child("info").child("pushToken").setValue("nil")
        
        //Unauthorize User
        do {
            try Auth.auth().signOut()
        } catch {
            print("error")
        }
        //Set readyToReceive to no
        
        //Reset User Defaults
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
        UniversalClassData = [["": "" as AnyObject]]
        
        
        completion()
    }
}
