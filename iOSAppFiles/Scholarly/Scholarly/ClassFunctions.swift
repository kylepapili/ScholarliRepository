//
//  ClassFunctions.swift
//  Scholarli
//
//  Created by Kyle Papili on 8/16/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import Foundation
import Firebase

func editClass(withID: String, toData : courseData, completion: () -> Void) {
    guard let school = UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.School)) as? String else {
        print("Error in addClass")
        return
    }
    let schoolRef = Database.database().reference().child("SchoolData").child(school)
    let classRef = schoolRef.child("classes").child(withID)
    
    //Update Classes Table
    let valuesToUpdate = ["classID" : toData.classID,
                          "course" : toData.course,
                          "period" : toData.period,
                          "teacherLastName" : toData.teacherLastName,
                          "teacherTitle" : toData.teacherTitle]
    classRef.updateChildValues(valuesToUpdate)
    
    //Update ClassData
    let classDataRef = schoolRef.child("ClassData").child(withID).child("DisplayInfo").child("ClassName")
    classDataRef.setValue(toData.course)
    completion()
}

func deleteClass(withID: String, completion: () -> Void) {
    guard let school = UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.School)) as? String else {
        print("Error in addClass")
        return
    }
    let schoolRef = Database.database().reference().child("SchoolData").child(school)
    let classesRef = schoolRef.child("classes")
    
    classesRef.child(withID).removeValue()
    
    
    let classDataRef = schoolRef.child("ClassData").child(withID).removeValue()
    
    
    completion()
}

func addClass(ClassName: String, TeacherLastName: String, TeacherTitle: String, Period: String, completion: () -> Void) {
    guard let school = UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.School)) as? String else {
        print("Error in addClass")
        return
    }
    let schoolRef = Database.database().reference().child("SchoolData").child(school)
    let classesRef = schoolRef.child("classes")
    let ClassDataRef = schoolRef.child("ClassData")
    
    
    //Write Data under classes
    let newChildRef = classesRef.childByAutoId()
    let autoID = newChildRef.key
    
    //Assemble key-Value Pairs
    let keysToUpdate = ["classID" : autoID,
                        "course": ClassName,
                        "period": Period,
                        "teacherLastName" : TeacherLastName,
                        "teacherTitle": TeacherTitle]
    newChildRef.updateChildValues(keysToUpdate)
    
    //Write Data under ClassData DisplayInfo
    let classDataChildRef = ClassDataRef.child(autoID)
    
    //Assemble key-value pairs
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
    dateFormatter.locale = Locale.init(identifier: "en_GB")
    dateFormatter.dateFormat = "MM-dd-yyyy"
    let date = NSDate(timeIntervalSinceReferenceDate: Date.timeIntervalSinceReferenceDate)
    let dateStr = dateFormatter.string(from: date as Date)
    
    let displayInfoKeysToUpdate = ["ClassName" : ClassName,
                                   "DateUpdated" : dateStr,
                                   "LastMessage" : "No Messages",
                                   "classID": autoID,
                                   "timeStamp": (String(Date.timeIntervalSinceReferenceDate))]
    
    classDataChildRef.child("DisplayInfo").updateChildValues(displayInfoKeysToUpdate)
    completion()
}


func updateUserClasses(originalClasses: [String], newClasses: [String], completion: () -> Void) {
    guard let user = Auth.auth().currentUser?.uid as? String else {
        print("No UID in updateUserClasses")
        return
    }
    for newClass in newClasses {
        if originalClasses.contains(newClass) {
            //Carry over class, do nothing
        } else {
            //Add user to this class
            add(user: user, toClass: newClass, completion: { 
                //Complete
            })
        }
    }
    
    for originalClass in originalClasses {
        if newClasses.contains(originalClass) {
            //Carry over class, do nothing
        } else {
            //Remove user from class
            remove(user: user, fromClass: originalClass, completion: {
                //Complete
            })
        }
    }
    updateUserLastClassCheck(user: user)
}

func updateUserLastClassCheck(user: String) {
    let userInfoRef = Database.database().reference().child("users").child(user).child("info")
    let valueToUpdate = (String(Date.timeIntervalSinceReferenceDate))
    userInfoRef.child("lastClassUpdate").setValue(valueToUpdate)
}

func checkUserLastClassUpdate(user: String, completion: @escaping (Bool) -> Void ) {
    let userInfoRef = Database.database().reference().child("users").child(user).child("info")
    userInfoRef.observeSingleEvent(of: .value, with: { (Snapshot) in
        guard let data = Snapshot.value as? [String : Any] else {
            print("Error in checkUserLastClassUpdate()")
            return
        }
        guard let lastClassUpdate = data["lastClassUpdate"] as? String else {
            //If non-existant, user is good to update classes
            completion(true)
            return
        }
        //Need to see if it has been more than a day
        let currentDateTime = (Float(Date.timeIntervalSinceReferenceDate))
        
        let classUpdateInt = (Float(lastClassUpdate))
        
        if currentDateTime - classUpdateInt! >= 86400 {
            completion(true)
        } else {
            completion(false)
        }
    })
}

func add(user: String, toClass: String, completion: () -> Void) {
    let schoolRef = Database.database().reference().child("SchoolData").child(UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.School)) as! String)
    let classMembersRef = schoolRef.child("classMembers").child(toClass)
    classMembersRef.childByAutoId().setValue(user)
    
    let userClassesRef = Database.database().reference().child("users").child(user).child("classes")
    userClassesRef.child(toClass).setValue(toClass)
    completion()
}

func remove(user: String, fromClass: String, completion: @escaping () -> Void) {
    //Update user Classes under User ID
    let userRef = Database.database().reference().child("users").child(user).child("classes")
    userRef.child(fromClass).removeValue()
    
    //Update classMembers under Class Members
    let schoolRef = Database.database().reference().child("SchoolData").child(UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.School)) as! String)
    let classMembersRef = schoolRef.child("classMembers").child(fromClass)
    classMembersRef.observeSingleEvent(of: .value, with: { (Snapshot) in
        guard var data = Snapshot.value as? [String : Any] else {
            print("Error in remove() ")
            return
        }
        
        
        let keys = (data as NSDictionary).allKeys(for: user) as! [String]
        
        print("KEYS: \(keys)")
        
        for key in keys {
            //Update
            classMembersRef.child(key).removeValue()
        }
    })
}


//MARK: Get List of ClassMember IDs function
typealias MemberDataClosure = ([String]) -> Void
func getClassMemberIDsFor(classID: String, completionHandler: @escaping MemberDataClosure) {
    let memberRef = Database.database().reference().child("SchoolData").child(UserDefaults.standard.value(forKey: "\(UserDefaultKeys.School)") as! String).child("classMembers").child(classID)
    let memberHandle = memberRef.observe(.value, with: { (DataSnapshot) in
        let data = DataSnapshot.value as! [String : String]
        let memberIDs = Array(data.values)
        completionHandler(memberIDs)
    })
}

//MARK: Sorting classes function

func sortByCourse(classesArray : [[String : Any]]) -> [[String : Any]]  {
    print("Here")
    let returnVal = classesArray.sorted { (classOne, classTwo) -> Bool in
        let classes = [classOne, classTwo]
        guard let courseOne = classOne["course"] as? String else {
            return false
        }
        guard let courseTwo = classTwo["course"] as? String else {
            return false
        }
        let courses = [ courseOne, courseTwo ]
        let sortedCourses = courses.sorted { $0 < $1 }
        
        print("SORTED: \(sortedCourses)")
        
        if sortedCourses == courses {
            return true
        } else {
            return false
        }
    }
    
    return returnVal
}



//MARK: Get User Info Function
typealias UserInfoDataClosure = ([[String : String]]) -> Void
func getUserInfoFor(memberIDs: [String], completionHandler: @escaping UserInfoDataClosure) {
    let infoRef = Database.database().reference().child("users")
    var UserDataDict = [[String : String]]()
    var offset = 0
    for var member in memberIDs {
        _ = infoRef.child(member).child("info").observe(.value, with: { (DataSnapshot) in
            if DataSnapshot.value as? [String : String] != nil {
                let data = DataSnapshot.value as! [String : String]
                UserDataDict.append(data)
                
                if UserDataDict.count == (memberIDs.count - offset){
                    //Done
                    completionHandler(UserDataDict)
                }
            } else {
                offset = offset + 1
            }
        })
    }
}
