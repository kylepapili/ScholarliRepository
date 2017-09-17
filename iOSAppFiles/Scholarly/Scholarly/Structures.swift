//
//  Structures.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/26/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import Foundation

enum MessageType {
    case text, image
}

enum MessageSendStatus {
    case success, fail
}

enum UserDefaultKeys {
    case FirstName, LastName, PhoneNumber, School, Classes, UID, Email
}

struct courseData {
    var classID : String
    var course : String
    var period : String
    var teacherLastName : String
    var teacherTitle : String
}

struct Message {
    var messageType : MessageType = .text
    var message : String? = ""
    var userFirstName = ""
    var userLastName = ""
    var timeStamp = ""
    var classID : String? = ""
    var imageURL : String? = nil
    var uid : String = ""
    var liked : Bool = false
    var messageID : String = ""
    var flagged : Bool = false
}


struct Assignment {
    var title = ""
    var classTitle = ""
    var classID = ""
    var assignmentType = ""
    var dueDate : Date?
    var additionalInfo = ""
}

struct UserDisplayData {
    var uid = ""
    var score = Int()
    var userFirstName = ""
    var userLastName = ""
    var userFullName = ""
    
    init(uid: String, score: Int, userFirstName: String, userLastName: String) {
        self.userFirstName = userFirstName
        self.userLastName = userLastName
        self.userFullName = "\(userFirstName) \(userLastName)"
        self.uid = uid
        self.score = score
    }
}

struct UserData {
    var uid = ""
    var userFirstName = ""
    var userLastName = ""
    var userFullName = ""
    var userSchool = ""
    var userPhoneNumber = ""
    var userClasses = [""]
    
    init(userFirstName : String , userLastName : String, userSchool : String, userPhoneNumber : String, userClasses : [String]) {
        self.userFirstName = userFirstName
        self.userLastName = userLastName
        self.userSchool = userSchool
        self.userPhoneNumber = userPhoneNumber
        self.userFullName = "\(userFirstName) \(userLastName)"
        self.userClasses = userClasses
    }
}
