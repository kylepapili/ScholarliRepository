//
//  flagFunctions.swift
//  Scholarli
//
//  Created by Kyle Papili on 8/21/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import Foundation
import Firebase

enum AddFlagResults {
    case alreadyHasFlag, flagAdded, unableToAddFlag
}

enum BlockUserResults {
    case userAlreadyBlocked, userBlocked, unableToBlockUser
}

func BlockUser(uid: String, completion: @escaping (_ result: BlockUserResults) -> Void) {
    //Confirm that user has NOT already been blocked
    userIsBlocked(CurrentUserUid: (Auth.auth().currentUser?.uid)!, BlockedUserUid: uid) { (UserIsBlocked) in
        if UserIsBlocked {
            completion(.userAlreadyBlocked)
        } else {
            let userRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
            
            userRef.child("BlockedUsers").childByAutoId().setValue(uid)
            completion(.userBlocked)
        }
    }
}

func userIsBlocked(CurrentUserUid: String, BlockedUserUid: String, completion: @escaping (_ result: Bool) -> Void) {
    if CurrentUserUid == BlockedUserUid {
        //Can't block yourself
        completion(false)
        return
    }
    let userRef = Database.database().reference().child("users").child(CurrentUserUid)
    print("USER IS BLOCKED IS RUNNING*****")
    userRef.child("BlockedUsers").observeSingleEvent(of: .value, with: { (Snapshot) in
        guard let blockedUserDict = Snapshot.value as? [String : String] else {
            //No Blocked Users
            completion(false)
            return
        }
        let arrayOfBlockedUsers = Array(blockedUserDict.values)
        if arrayOfBlockedUsers.contains(BlockedUserUid) {
            completion(true)
        } else {
            completion(false)
        }
    })
}

func AddFlaggTo(message: Message, completion: @escaping (_ result: AddFlagResults) -> Void) {
    //Confirm that message does NOT already have flag
    messageHasFlag(message: message) { (result) in
        if result {
            //Message already has flag
            completion(.alreadyHasFlag)
        } else {
            //Continue with function
            let messageID = message.messageID
            guard let classID = message.classID else {
                print("error in messageHasFlag()")
                completion(.unableToAddFlag)
                return
            }
            let MessageRef = Database.database().reference().child("SchoolData").child(UserDefaults.standard.value(forKey: (String(describing: UserDefaultKeys.School))) as! String).child("ClassData").child(classID).child("Messages").child(messageID)
            
            MessageRef.child("flagged").setValue("TRUE")
            completion(.flagAdded)
        }
    }
}

func messageHasFlag(message: Message, completion: @escaping (_ result: Bool) -> Void) {
    let messageID = message.messageID
    guard let classID = message.classID else {
        print("error in messageHasFlag() 1")
        return
    }
    let MessageRef = Database.database().reference().child("SchoolData").child(UserDefaults.standard.value(forKey: (String(describing: UserDefaultKeys.School))) as! String).child("ClassData").child(classID).child("Messages").child(messageID)
    
    MessageRef.observeSingleEvent(of: .value, with: { (Snapshot) in
        print("VALUE: \(Snapshot.value)")
        guard let data = Snapshot.value as? [String : Any] else {
            print("error in messageHasFlag() 2")
            return
        }
        
        guard let flaggedStr = data["flagged"] as? String else {
            print("error in messageHasFlag() 3")
            return
        }
        
        if flaggedStr == "FALSE" {
            completion(false)
        } else {
            completion(true)
        }
    })
    
}
