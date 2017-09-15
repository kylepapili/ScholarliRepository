//
//  FirebaseFunctions.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/25/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import Foundation
import Firebase

//typealias ClassDataClosure = ([[String: AnyObject]]) -> Void
//
//func prepareClassData(completionHandler: @escaping ClassDataClosure) {
//    let UserClasses = UserDefaults.standard.value(forKey: "Classes") as? Array<Any>
//    var ClassData = [[String: AnyObject]]()
//
//    let ref = Database.database().reference()
//    for var singleClass in UserClasses! {
//        let handle = ref.child("SchoolData").child((UserDefaults.standard.value(forKey: "School") as! String)).child("ClassData").child(singleClass as! String).child("DisplayInfo").observe(DataEventType.value, with: { (FIRDataSnapshot) in
//            if let dataDict = FIRDataSnapshot.value as? [String : String] {
//                ClassData.append(dataDict as [String : AnyObject])
//
//                if (ClassData.count == UserClasses!.count) {
//                    completionHandler(ClassData)
//                }
//            }
//        })
//        ref.removeObserver(withHandle: handle)
//    }
//
//
//}



func userIsAdmin(uid: String, completion: @escaping (Bool)-> Void) {
    let userRef = Database.database().reference().child("users").child(uid)
    userRef.child("info").observeSingleEvent(of: .value, with: { (snapshot) in
        guard let userInfo = snapshot.value as? [String : Any] else {
            completion(false)
            return
        }
        
        guard let userAdmin = userInfo["admin"] as? String else {
            completion(false)
            return
        }
        
        if userAdmin == "TRUE" {
            completion(true)
            return
        }
    })
}

//////////////////////////////
////Prepare User Defaults/////
//////////////////////////////

typealias ClassDefaultsDataClosure = () -> Void

func prepareClassesDefaults(completionHandler: @escaping ClassDefaultsDataClosure) {
    let ref = Database.database().reference()
    //First Observer
    ref.child("users").child((Auth.auth().currentUser?.uid)!).child("classes").observe(DataEventType.value, with: { (FIRDataSnapshot) in
        if let dataDict = FIRDataSnapshot.value as? [String : String] {
            let userClasses = Array(dataDict.values)
            UserDefaults.standard.set(userClasses, forKey: "Classes") //Classes
            completionHandler()
        }
    })
}


typealias UserDefaultsDataClosure = () -> Void

func prepareUserDefaults(completionHandler: @escaping UserDefaultsDataClosure) {
    //Reset User Defaults
    let domain = Bundle.main.bundleIdentifier!
    UserDefaults.standard.removePersistentDomain(forName: domain)
    let ref = Database.database().reference()
    
    UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "UID") //UID
    UserDefaults.standard.set(Auth.auth().currentUser?.email, forKey: "Email") //Email
    
    prepareClassesDefaults {
        
        //Second Observer
        let handle = ref.child("users").child((Auth.auth().currentUser?.uid)!).child("info").observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
            if let dataDict = FIRDataSnapshot.value as? [String : String] {
                let FirstName = dataDict["FirstName"]
                let LastName = dataDict["LastName"]
                let PhoneNumber = dataDict["PhoneNumber"]
                let School = dataDict["School"]
                
                UserDefaults.standard.set(FirstName, forKey: "FirstName") //FirstName
                UserDefaults.standard.set(LastName, forKey: "LastName") //LastName
                UserDefaults.standard.set(PhoneNumber, forKey: "PhoneNumber") //PhoneNumber
                UserDefaults.standard.set(School, forKey: "School") //School
                
                
                //Send device token to firebase
                let token = Messaging.messaging().fcmToken
                let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
                ref.child("info").child("pushToken").setValue(token)
                
                //Ready to Recieve Notifications!
                setNotificationStatus(readyToReceive: true, completionHandler: { 
                    if(UserDefaults.standard.value(forKey: "FirstName") != nil &&
                        UserDefaults.standard.value(forKey: "LastName") != nil &&
                        UserDefaults.standard.value(forKey: "PhoneNumber") != nil &&
                        UserDefaults.standard.value(forKey: "School") != nil &&
                        UserDefaults.standard.value(forKey: "Classes") != nil &&
                        UserDefaults.standard.value(forKey: "Email") != nil &&
                        UserDefaults.standard.value(forKey: "UID") != nil) {
                        completionHandler()
                    }
                })
            }
        })
    }
}


typealias SetNotificationStatusDataClosure = () -> Void


func setNotificationStatus(readyToReceive: Bool, completionHandler: @escaping SetNotificationStatusDataClosure) {
    guard let uid = Auth.auth().currentUser?.uid as? String else {
        print("Error: Found nil in setNotificationStatus")
        return
    }
    let ref = Database.database().reference().child("users").child(uid).child("info")
    switch readyToReceive {
        case true:
            ref.child("readyToReceive").setValue("TRUE")
            completionHandler()
        case false:
            ref.child("readyToReceive").setValue("FALSE")
            completionHandler()
    }
    
}

typealias ProfileDataClosure = (UserData) -> Void

func prepareUserDataFor(uid: String, completionHandler: @escaping ProfileDataClosure) {
    
    ArrayOfClassIDsFor(uid: uid) { (arrayOfClassIDs) in
        let UserRef = Database.database().reference().child("users").child(uid)
        
        
        UserRef.child("info").observe(.value, with: { (DataSnapshot) in
            guard let data = DataSnapshot.value as? [String : String] else {
                print("Error: Found nil in prepareUserDataFor 1")
                return
            }
            
            guard let FirstName = data["FirstName"] as? String else {
                print("Error: Found nil in prepareUserDataFor 2")
                return
            }
            guard let LastName = data["LastName"] as? String else {
                print("Error: Found nil in prepareUserDataFor 3")
                return
            }
            guard let PhoneNumber = data["PhoneNumber"] as? String else {
                print("Error: Found nil in prepareUserDataFor 4")
                return
            }
            guard let School = data["School"] as? String else {
                print("Error: Found nil in prepareUserDataFor 5")
                return
            }
            
            let userDataToReturn = UserData(userFirstName: FirstName,
                                            userLastName: LastName,
                                            userSchool: School,
                                            userPhoneNumber: PhoneNumber,
                                            userClasses: arrayOfClassIDs)
            completionHandler(userDataToReturn)
        })
    }
}


func ArrayOfClassIDsFor(uid: String, completion: @escaping (_ result: [String]) -> Void) {
    let dbRef = Database.database().reference().child("users").child(uid).child("classes")
    
    dbRef.observe(.value, with: { (DataSnapshot) in
        guard let dictOfClassIDs = DataSnapshot.value as? [String : String] else {
            print("Error in ArrayOfClassIDsFor 1")
            return
        }
        
        guard let arrayOfClassIDs = Array(dictOfClassIDs.values) as? [String] else {
            print("Error in ArrayOfClassIDsFor 2")
            return
        }
        
        completion(arrayOfClassIDs)
    })
    
}

func doesUserExist(userToTest: User?, completion: @escaping (_ exist: Bool, _ completedSetup: Bool) -> Void) {
    guard let safeUser = userToTest as? User else {
        print("Error: No user provided to doesUserExist()")
        completion(false, false)
        return
    }
    let ref = Database.database().reference().child("users")
    
    ref.child(safeUser.uid).observeSingleEvent(of: .value, with: { (FIRDataSnapshot) in
        if let resultData = FIRDataSnapshot.value as? [String : Any] {
            //User exists
            print("Result Data: \(resultData)")
            
            guard let infoData = resultData["info"] as? [String : Any] else {
                //User has no info
                completion(false, false)
                return
            }
            
            if let finishedSetup = infoData["completedSetup"] as? String {
                //User has finished sign up process
                print("User finished sign up process")
                if (finishedSetup == "TRUE") {
                    completion(true, true)
                } else {
                    completion(true, false)
                }
            } else {
                //User exists but did not complete sign up process
                completion(true, false)
            }
        } else {
            //User does not exist: 
            completion(false, false)
        }
    })
}

