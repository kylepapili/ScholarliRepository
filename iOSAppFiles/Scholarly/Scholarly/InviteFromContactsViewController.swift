//
//  InviteFromContactsViewController.swift
//  Scholarli
//
//  Created by Kyle Papili on 9/3/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import ContactsUI
import Firebase

class InviteFromContactsViewController: UIViewController , CNContactPickerDelegate {

    var contactStore = CNContactStore()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.askForContactAccess()
        
        launchContactVC()
    }
    
    func launchContactVC() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        print("Ayyeee")
    }
    
    func askForContactAccess() {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if !access {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        DispatchQueue.main.async(execute: { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            let alertController = UIAlertController(title: "Contacts", message: message, preferredStyle: UIAlertControllerStyle.alert)
                            
                            let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
                            }
                            
                            alertController.addAction(dismissAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                        })  
                    }  
                }  
            })  
            break  
        default:  
            break  
        }  
    }

}
