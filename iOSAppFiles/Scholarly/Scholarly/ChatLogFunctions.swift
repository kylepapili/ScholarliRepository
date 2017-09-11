//
//  ChatLogFunctions.swift
//  Scholarly
///Users/kylepapili/Documents/ScholarlyFolder/Scholarly/Scholarly.xcodeproj
//  Created by Kyle Papili on 6/26/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import Foundation
import Firebase
import UserNotifications


func sendLocalNotification(title: String, subtitle: String, body: String) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.subtitle = subtitle
    content.body = body
    content.badge = 1
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
    let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}


typealias ClassDataClosure = ([[String: AnyObject]]) -> Void

func prepareClassData(completionHandler: @escaping ClassDataClosure) {
    
    
    var ClassData = [[String: AnyObject]]()
    
    guard let UserClasses = UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.Classes)) as? Array<Any> else {
        print("Error: Found nil")
        return
    }
    
    //Initialize ClassData
    let ref = Database.database().reference()
    for var singleClass in UserClasses {
        print("SINGLE CLASS: \(singleClass)")
        guard let school = (UserDefaults.standard.value(forKey: "School") as? String) else {
            print("School error in prepareClassData")
            return
        }
        
        let handle = ref.child("SchoolData").child(school).child("ClassData").child(singleClass as! String).child("DisplayInfo").observe(DataEventType.value, with: { (FIRDataSnapshot) in
            print(FIRDataSnapshot.value)
            if let dataDict = FIRDataSnapshot.value as? [String : String] {
                ClassData.append(dataDict as [String : AnyObject])
                
                
                if (ClassData.count == UserClasses.count) {
                    ClassData.sort(by: { (classOne, classTwo) -> Bool in
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
                        dateFormatter.locale = Locale.init(identifier: "en_GB")
                        dateFormatter.dateFormat = "MM-dd-yyyy"
                        
                        guard let timeOneStr = classOne["timeStamp"] as? String else {
                            print("Error: Found nil in PrepareClassData")
                            return true
                        }
                        guard let timeTwoStr = classTwo["timeStamp"] as? String else {
                            print("Error: Found nil in PrepareClassData no here")
                            return true
                        }
                        
                        guard let timeOneNum = Float(timeOneStr) else {
                            print("Error: Found nil in PrepareClassData this one")
                            return true
                        }
                        
                        guard let timeTwoNum = Float(timeTwoStr) else {
                            print("Error: Found nil in PrepareClassData ayy")
                            return true
                        }
                        
                        if(timeOneNum > timeTwoNum) {
                            return true
                        } else {
                            return false
                        }
                    })
                    completionHandler(ClassData)
                }
            } else {
                print("Error: Found nil")
                completionHandler([["AXDXANY" : "AXDXANY" as AnyObject]])
            }
        })
        ref.removeObserver(withHandle: handle)
    }
}



//typealias ChatLogDataClosure = ([Message]) -> Void
//
//let ChatLogRef = Database.database().reference().child("SchoolData").child(UserDefaults.standard.value(forKey: "\(UserDefaultKeys.School)") as! String).child("ClassData")
//
//
//func createChatLogFor(classID: String, completionHandler: @escaping ChatLogDataClosure) {
//    //let testMessage = Message(messageType: MessageType.text, message: "WELCOME", userFirstName: "Scholarly", userLastName: "App", timeStamp: "0342341234123", classID: "004")
//
//    var chat : [Message] = []
//    ChatLogRef.child(classID).child("Messages").observe(DataEventType.value, with: { (FIRDataSnapshot) in
//        if let dataDict = FIRDataSnapshot.value as? [String : [String : Any]] {
//            for var singleMessage in dataDict {
//                if singleMessage.value["messageType"] as! String == "text" {
//                    guard let messageStr = singleMessage.value["message"] as? String else {
//                        print("Error: Found nil")
//                        return
//                    }
//                    guard let userFirstName = singleMessage.value["userFirstName"] as? String else {
//                        print("Error: Found nil")
//                        return
//                    }
//                    guard let userLastName = singleMessage.value["userLastName"] as? String else {
//                        print("Error: Found nil")
//                        return
//                    }
//                    guard let timeStamp = singleMessage.value["timeStamp"] as? String else {
//                        print("Error: Found nil")
//                        return
//                    }
//                    guard let classID = singleMessage.value["classID"] as? String else {
//                        print("Error: Found nil")
//                        return
//                    }
//                    guard let uid = Auth.auth().currentUser?.uid else {
//                        print("Error: Found nil in ChatLogVC")
//                        return
//                    }
//
//                    let message = Message(messageType: MessageType.text,
//                                          message: messageStr,
//                                          userFirstName: userFirstName,
//                                          userLastName: userLastName,
//                                          timeStamp: timeStamp,
//                                          classID: classID,
//                                          imageURL : nil,
//                                          uid: uid ,
//                                          liked: false)
//
//                    chat.append(message)
//                } else {
//
//                    guard let userFirstName = singleMessage.value["userFirstName"] as? String else {
//                        print("Error: Found nil")
//                        return
//                    }
//                    guard let userLastName = singleMessage.value["userLastName"] as? String else {
//                        print("Error: Found nil")
//                        return
//                    }
//                    guard let timeStamp = singleMessage.value["timeStamp"] as? String else {
//                        print("Error: Found nil")
//                        return
//                    }
//                    guard let classID = singleMessage.value["classID"] as? String else {
//                        print("Error: Found nil")
//                        return
//                    }
//                    guard let imageURL = singleMessage.value["imageURL"] as? String else {
//                        print("Error: Found nil")
//                        return
//                    }
//                    guard let uid = Auth.auth().currentUser?.uid else {
//                        print("Error: Found nil in ChatLogVC")
//                        return
//                    }
//                    let message = Message(messageType: MessageType.text,
//                                          message: nil,
//                                          userFirstName: userFirstName,
//                                          userLastName: userLastName,
//                                          timeStamp: timeStamp,
//                                          classID: classID,
//                                          imageURL : imageURL,
//                                          uid: uid,
//                                          liked: false)
//
//                    chat.append(message)
//                }
//            }
//        }
//    })
//}



//MARK: - prepareClassInfoData


typealias ClassInfoDataClosure = ([[String: AnyObject]]) -> Void

func prepareClassInfoData(completionHandler: @escaping ClassInfoDataClosure) {
    var ClassData = [[String: AnyObject]]()
    
    guard let UserClasses = UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.Classes)) as? Array<Any> else {
        print("Error: Found nil")
        return
    }
    
    //Initialize ClassData
    let ref = Database.database().reference()
    for var singleClass in UserClasses {
        let handle = ref.child("SchoolData").child((UserDefaults.standard.value(forKey: "School") as! String)).child("classes").child(singleClass as! String).observe(DataEventType.value, with: { (FIRDataSnapshot) in
            if let dataDict = FIRDataSnapshot.value as? [String : String] {
                ClassData.append(dataDict as [String : AnyObject])
                
                
                if (ClassData.count == UserClasses.count) {
                    completionHandler(ClassData)
                }
            }
        })
        ref.removeObserver(withHandle: handle)
    }
}




//MARK: - prepareClassInfoDataFor(uid)


typealias ClassInfoForArrayOfClassIDsDataClosure = ([[String: AnyObject]]) -> Void

func prepareClassInfoDataFor(arrayOfClassIDs: [String], completionHandler: @escaping ClassInfoForArrayOfClassIDsDataClosure) {
    var ClassData = [[String: AnyObject]]()
    
    //Initialize ClassData
    let ref = Database.database().reference()
    for var singleClassID in arrayOfClassIDs {
        let handle = ref.child("SchoolData").child((UserDefaults.standard.value(forKey: "School") as! String)).child("classes").child(singleClassID as! String).observe(DataEventType.value, with: { (FIRDataSnapshot) in
            if let dataDict = FIRDataSnapshot.value as? [String : String] {
                ClassData.append(dataDict as [String : AnyObject])
                
                
                if (ClassData.count == arrayOfClassIDs.count) {
                    completionHandler(ClassData)
                }
            }
        })
        ref.removeObserver(withHandle: handle)
    }
}


//MARK: - Like / Dislike message

func likeMessage(id : String, classID : String, uid: String) {
    updateUserScore(uid: uid, add: true) { 
        let dbRef = Database.database().reference().child("SchoolData").child("West Morris Mendham").child("ClassData").child(classID).child("Messages").child(id)
        dbRef.child("liked").setValue("TRUE")
    }
}

func dislikeMessage(id : String, classID : String, uid: String) {
    updateUserScore(uid: uid, add: false) {
        let dbRef = Database.database().reference().child("SchoolData").child("West Morris Mendham").child("ClassData").child(classID).child("Messages").child(id)
        dbRef.child("liked").setValue("FALSE")
    }
}

func updateUserScore(uid: String, add: Bool, completionHandler: @escaping () -> Void) {
    print("UPDATING USer SCORE")
    let userLeaderboardRef = Database.database().reference().child("SchoolData").child(UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.School)) as! String).child("Leaderboard").child(uid)
    var updatedScore : Int = Int()
    var userInit : Bool = true
    userLeaderboardRef.child("score").observeSingleEvent(of: .value, with: { (snapshot) in
        guard let currentScoreStr = snapshot.value as? String else {
            //User does not have a score yet
            userInit = false
            print("USER HAS NO SCORE")
            if add {
                updatedScore = 10
            } else {
                updatedScore = 0
            }
            if updatedScore < 0 {
                updatedScore = 0
            }
            userLeaderboardRef.child("score").setValue(String(updatedScore))
            completionHandler()
            return
        }
        if userInit {
            guard let currentScoreInt = Int(currentScoreStr) as? Int else {
                print("Error in updateUserScore")
                return
            }
            if add {
                //Add a point to the users score (someone liked a message)
                updatedScore = currentScoreInt + 10
            } else {
                //Remove a point from the users score (someone unliked a message)
                updatedScore = currentScoreInt - 10
            }
            
            if updatedScore < 0 {
                updatedScore = 0
            }
            
            userLeaderboardRef.child("score").setValue(String(updatedScore))
            completionHandler()
        }
    })
    
    
}

func checkMessageForLike(id: String, classID: String, completionHandler: @escaping (_ result: Bool) -> Void) {
    var returnVal : Bool = false
    let dbRef = Database.database().reference().child("SchoolData").child("West Morris Mendham").child("ClassData").child(classID).child("Messages").child(id).child("liked")
    dbRef.observe(.value, with: { (DataSnapshot) in
        guard let data = DataSnapshot.value as? String else {
            print("Error in CheckMessageForLike")
            return
        }
        if data == "TRUE" {
            returnVal = true
            completionHandler(returnVal)
        } else {
            returnVal = false
            completionHandler(returnVal)
        }
    })
    dbRef.removeAllObservers()
}
