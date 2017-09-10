//
//  leaderboard.swift
//  Scholarly
//
//  Created by Kyle Papili on 8/1/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import Foundation
import Firebase


func latestLeaderboard(completionHandler: @escaping ([UserDisplayData]) -> Void) {
    let leaderBoardRef = Database.database().reference().child("SchoolData").child(UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.School)) as! String).child("Leaderboard")
    leaderBoardRef.observe(.value, with: { (snapshot) in
        guard let data = snapshot.value as? [String : Any] else {
            print("Error in latestLeaderboard")
            return
        }
        var idScoreDict : [String : Int] = [:]
        for singleUser in data {
            guard let userValue = singleUser.value as? [String : String] else {
                print("second error")
                return
            }
            
            guard let userScoreInt = Int(userValue["score"]!) else {
                print("Error in latestLeaderboard 2")
                return
            }
            let userID = singleUser.key
            
            idScoreDict[userID] = userScoreInt
        }
        
        idScoreDict.sorted(by: { (itemOne: (key: String, value: Int), itemTwo: (key: String, value: Int)) -> Bool in
            if itemOne.value > itemTwo.value {
                return true
            } else {
                return false
            }
        })
        
        
        //Generate UserData For Each UID
        
        displayArrayFrom(scoreDict: idScoreDict, completionHandler: { (result) in
            let arrayToReturn = result.sorted(by: { (itemOne, itemTwo) -> Bool in
                if itemOne.score > itemTwo.score {
                    return true
                } else {
                    return false
                }
            })
            completionHandler(arrayToReturn)
        })
    })
}

func displayArrayFrom(scoreDict: [String : Int], completionHandler: @escaping ([UserDisplayData]) -> Void) {
    var displayArray = [UserDisplayData]()
    for user in scoreDict {
        userDisplayDataFor(uid: user.key, score: user.value, completionHandler: { (userDisplayInfo) in
            displayArray.append(userDisplayInfo)
            if displayArray.count == scoreDict.count {
                completionHandler(displayArray)
            }
        })
    }
}

func userDisplayDataFor(uid: String, score: Int, completionHandler : @escaping (UserDisplayData) -> Void) {
    print("UID: \(uid), Score: \(score)")
    
    let userInfoRef = Database.database().reference().child("users").child(uid).child("info")
    
    userInfoRef.observeSingleEvent(of: .value, with: { (snapshot) in
        
        print("OCTOPUS: \(snapshot.value!)")
        
        guard let data = snapshot.value as? [String : Any] else {
            print("Error in userDisplayDataFor 1")
            return
        }
        
        guard let FirstName = data["FirstName"] as? String else {
            print("Error in userDisplayDataFor 2")
            return
        }
        
        guard let LastName = data["LastName"] as? String else {
            print("Error in userDisplayDataFor 3")
            return
        }
        
        let displayDataToReturn = UserDisplayData(uid: uid, score: score, userFirstName: FirstName, userLastName: LastName)
        completionHandler(displayDataToReturn)
    })
}





