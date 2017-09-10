//
//  AgendaFunctions.swift
//  Scholarly
//
//  Created by Kyle Papili on 7/4/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import Foundation
import Firebase


func ArrayOfClassesFor(arrayOfClassIDs: [String], completion: @escaping (_ result: [String]) -> Void) {
    let dbRef = Database.database().reference().child("SchoolData").child(UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.School)) as! String).child("ClassData")
    
    var arrayOfClassNames : [String]? = nil
    for SingleClassID in arrayOfClassIDs {
        dbRef.child(SingleClassID).child("DisplayInfo").child("ClassName").observe(.value, with: { (snapshot) in
            if let data = snapshot.value as! String? {
                if arrayOfClassNames?.append(data) == nil {
                    arrayOfClassNames = [data]
                }
                if arrayOfClassNames?.count == arrayOfClassIDs.count {
                    //Function is finished
                    completion(arrayOfClassNames!)
                }
            }
        })
        
    }
}

func postAssignment(assignment: Assignment, completion: @escaping () -> Void) {
    let dbRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
    var childValues : [String : String] = ["title" : assignment.title, "classTitle" : assignment.classTitle, "classID" : assignment.classID, "assignmentType" : assignment.assignmentType, "additionalInfo" : assignment.additionalInfo]
    //Handling the date
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM-dd-yyyy"
    dateFormatter.locale = Locale.init(identifier: "en_GB")
    let dateStr = dateFormatter.string(from: assignment.dueDate!)
    childValues["dueDate"] = dateStr
    dbRef.child("Agenda").childByAutoId().updateChildValues(childValues)
    completion()
}


func updateUserAssignmentsFor(assignmentArray: [[String : String]], completion: @escaping () -> Void) {
    let dbRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Agenda")
    dbRef.removeValue()
    
    if (assignmentArray.count != 0 ) {
        for index in 0...((assignmentArray.count) - 1) {
            dbRef.childByAutoId().updateChildValues(assignmentArray[index])
        }
    }
    
    completion()
}


func updateAssignment(assignment : Assignment, assignmentID : String, completion: @escaping () -> Void) {
    let dbRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Agenda")
    var childValues : [String : String] = ["title" : assignment.title, "classTitle" : assignment.classTitle, "classID" : assignment.classID, "assignmentType" : assignment.assignmentType, "additionalInfo" : assignment.additionalInfo]
    //Handling the date
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM-dd-yyyy"
    dateFormatter.locale = Locale.init(identifier: "en_GB")
    let dateStr = dateFormatter.string(from: assignment.dueDate!)
    childValues["dueDate"] = dateStr
    
    dbRef.child(assignmentID).updateChildValues(childValues)
    completion()
}










