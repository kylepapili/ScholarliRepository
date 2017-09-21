//
//  ChatLogViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/26/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import Firebase

class ChatLogViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UITextFieldDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate , ChatMessageTableViewCellDelegator {
    
    
    // MARK: - Variables
    var classID = ""
    var className = ""
    var chatLog : [Message] = []
    var userInfoArray : [[String : String]]? = nil
    var storageRef : StorageReference! = Storage.storage().reference()
    let imageCache = NSCache<NSString, UIImage>()
    let ref = Database.database().reference().child("SchoolData").child(UserDefaults.standard.value(forKey: "School") as! String).child("ClassData")
    var test : [String] = [] //Same as below
    var testTwo = Array<String>() //Initializes an empty array of strings
    var selectedImage : UIImage? = nil //Used for ImageDisplayVC Segue
    var messageToFlag : Message? = nil //Used for FlagVC Segue
    
    // MARK: - Outlets
    @IBOutlet var NavigationBarOutlet: UINavigationBar!
    @IBOutlet var MessageFieldOutlet: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var NavBar: UINavigationItem!
    @IBOutlet var UserActionsView: UIView!
    @IBOutlet var UserActionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var ProgressViewBar: UIProgressView!
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() { //Don't clutter with logic
        super.viewDidLoad()
        
        if self.className != "" {
            self.title = self.className
        } else {
            self.title = "Temporary Title"
        }
        
        // Resize table view automatically
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        
        self.tableViewScrollToBottom(animated: false, delay: false)
        ref.child(classID).child("Messages").observe(.childAdded, with: { (DataSnapshot) in
            let data = DataSnapshot.value as! [String : String]
            var message : Message? = nil
            if data["messageType"] == "text" {
                guard let messageStr = data["message"] else {
                    print("Error: nil returned 1")
                    return
                }
                guard let firstName = data["userFirstName"] else {
                    print("Error: nil returned 2")
                    return
                }
                guard let lastName = data["userLastName"] else {
                    print("Error: nil returned 3")
                    return
                }
                guard let timeStamp = data["timeStamp"] else {
                    print("Error: nil returned 4")
                    return
                }
                guard let classID = data["classID"] else {
                    print("Error: nil returned 5")
                    return
                }
                guard let uid = data["uid"] else {
                    print("Error: Found nil in ChatLogVC")
                    return
                }
                guard let liked = data["liked"] as? String else {
                    print("Error: Found nil in ChatLogVC")
                    return
                }
                guard let flagged = data["flagged"] as? String else {
                    print("Error: Found nil in ChatLogVC")
                    return
                }
                guard let messageID = DataSnapshot.key as? String else {
                    print("Error: Found nil in ChatLogVC")
                    return
                }
                
                //Interpret Boolean String Values
                
                var likedBool : Bool = false
                if liked == "TRUE" {
                    likedBool = true
                } else {
                    likedBool = false
                }
                
                var flaggedBool : Bool = false
                if flagged == "FALSE" {
                    flaggedBool = false
                } else {
                    flaggedBool = true
                }
                
                
                message = Message(messageType: MessageType.text,
                                  message: messageStr,
                                  userFirstName: firstName,
                                  userLastName: lastName,
                                  timeStamp: timeStamp,
                                  classID: classID,
                                  imageURL: nil,
                                  uid: uid,
                                  liked: likedBool,
                                  messageID : messageID, flagged: flaggedBool)
            } else {
                guard let firstName = data["userFirstName"] else {
                    print("Error: nil returned 6")
                    return
                }
                guard let lastName = data["userLastName"] else {
                    print("Error: nil returned 7")
                    return
                }
                guard let timeStamp = data["timeStamp"] else {
                    print("Error: nil returned 8")
                    return
                }
                guard let classID = data["classID"] else {
                    print("Error: nil returned 9")
                    return
                }
                guard let imageURL = data["imageURL"] else {
                    print("Error: nil returned 10")
                    return
                }
                guard let uid = data["uid"] else {
                    print("Error: Found nil in ChatLogVC")
                    return
                }
                guard let liked = data["liked"] as? String else {
                    print("Error: Found nil in ChatLogVC")
                    return
                }
                guard let flagged = data["flagged"] as? String else {
                    print("Error: Found nil in ChatLogVC")
                    return
                }
                guard let messageID = DataSnapshot.key as? String else {
                    print("Error: Found nil in ChatLogVC")
                    return
                }
                //Need to interpret Boolean String Values
                var likedBool : Bool = false
                if liked == "TRUE" {
                    likedBool = true
                } else {
                    likedBool = false
                }
                var flaggedBool : Bool = false
                if flagged == "FALSE" {
                    flaggedBool = false
                } else {
                    flaggedBool = true
                }
                
                message = Message(messageType: MessageType.image,
                                  message: nil,
                                  userFirstName: firstName,
                                  userLastName: lastName,
                                  timeStamp: timeStamp,
                                  classID: classID,
                                  imageURL: imageURL,
                                  uid: uid,
                                  liked: likedBool,
                                  messageID: messageID, flagged: flaggedBool)
            }
            guard let messageFinal = message else {
                print("Error: nil returned HERE!!!")
                return
            }
            
            //Filter through blocked Users
            userIsBlocked(CurrentUserUid: (Auth.auth().currentUser?.uid)!, BlockedUserUid: messageFinal.uid, completion: { (result) in
                if (result) {
                    //User is blocked, DO NOT append message
                } else {
                    self.chatLog.append(messageFinal)
                }
                self.ProgressViewBar.isHidden = true
                //Stop!
                self.tableView.reloadData()
                self.tableViewScrollToBottom(animated: false, delay: true)
                self.chatLog.sort(by: { (messageOne, messageTwo) -> Bool in
                    if messageOne.timeStamp > messageTwo.timeStamp {
                        return false
                    } else {
                        return true
                    }
                })
            })
        })
        
        ref.child(classID).child("Messages").observe(.childChanged, with: { (DataSnapshot) in
            guard let data = DataSnapshot.value as? [String : String] else {
                print("Error in second observer in ChatLogVC")
                return
            }
            
            var newMessage : Message = Message()
            
            if data["messageType"] == "text" {
                guard let messageStr = data["message"] else {
                    print("Error: nil returned 1")
                    return
                }
                guard let firstName = data["userFirstName"] else {
                    print("Error: nil returned 2")
                    return
                }
                guard let lastName = data["userLastName"] else {
                    print("Error: nil returned 3")
                    return
                }
                guard let timeStamp = data["timeStamp"] else {
                    print("Error: nil returned 4")
                    return
                }
                guard let classID = data["classID"] else {
                    print("Error: nil returned 5")
                    return
                }
                guard let uid = data["uid"] else {
                    print("Error: Found nil in ChatLogVC")
                    return
                }
                guard let liked = data["liked"] as? String else {
                    print("Error: Found nil in ChatLogVC")
                    return
                }
                guard let flagged = data["flagged"] as? String else {
                    print("Error: Found nil in ChatLogVC")
                    return
                }
                guard let messageID = DataSnapshot.key as? String else {
                    print("Error: Found nil in ChatLogVC")
                    return
                }
                //Need to interpret Boolean String Values
                var likedBool : Bool = false
                if liked == "TRUE" {
                    likedBool = true
                } else {
                    likedBool = false
                }
                var flaggedBool : Bool = false
                if flagged == "FALSE" {
                    flaggedBool = false
                } else {
                    flaggedBool = true
                }
                
                newMessage = Message(messageType: MessageType.text,
                                     message: messageStr,
                                     userFirstName: firstName,
                                     userLastName: lastName,
                                     timeStamp: timeStamp,
                                     classID: classID,
                                     imageURL: nil,
                                     uid: uid,
                                     liked: likedBool,
                                     messageID : messageID, flagged: flaggedBool)
                
                var count = 0
                for message in self.chatLog {
                    if message.messageID == messageID {
                        self.chatLog[count] = newMessage
                        self.tableView.reloadData()
                        
                    }
                    count = count + 1
                }
            } else {
                guard let firstName = data["userFirstName"] else {
                    print("Error: nil returned 6")
                    return
                }
                guard let lastName = data["userLastName"] else {
                    print("Error: nil returned 7")
                    return
                }
                guard let timeStamp = data["timeStamp"] else {
                    print("Error: nil returned 8")
                    return
                }
                guard let classID = data["classID"] else {
                    print("Error: nil returned 9")
                    return
                }
                guard let imageURL = data["imageURL"] else {
                    print("Error: nil returned 10")
                    return
                }
                guard let uid = data["uid"] else {
                    print("Error: Found nil in ChatLogVC")
                    return
                }
                guard let liked = data["liked"] as? String else {
                    print("Error: Found nil in ChatLogVC")
                    return
                }
                guard let flagged = data["flagged"] as? String else {
                    print("Error: Found nil in ChatLogVC")
                    return
                }
                guard let messageID = DataSnapshot.key as? String else {
                    print("Error: Found nil in ChatLogVC")
                    return
                }
                //Need to interpret Boolean String Values
                var likedBool : Bool = false
                if liked == "TRUE" {
                    likedBool = true
                } else {
                    likedBool = false
                }
                var flaggedBool : Bool = false
                if flagged == "FALSE" {
                    flaggedBool = false
                } else {
                    flaggedBool = true
                }
                
                newMessage = Message(messageType: MessageType.image,
                                     message: nil,
                                     userFirstName: firstName,
                                     userLastName: lastName,
                                     timeStamp: timeStamp,
                                     classID: classID,
                                     imageURL: imageURL,
                                     uid: uid,
                                     liked: likedBool,
                                     messageID: messageID, flagged: flaggedBool)
                var count = 0
                for message in self.chatLog {
                    if message.messageID == messageID {
                        self.chatLog[count] = newMessage
                        self.tableView.reloadData()
                    }
                    count = count + 1
                }
            }
        })
        
    }
    
    // MARK: - Table View Functions
    
    //Height For Row At
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //Need this to work, come one!!!
    
    //Cell For Row At
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.chatLog.isEmpty) {
            //Empty ChatLog
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! ChatMessageTableViewCell
            cell.message = Message(messageType: .text,
                                   message: "No Messages in this class yet",
                                   userFirstName: "Scholarly",
                                   userLastName: "App",
                                   timeStamp: "",
                                   classID: self.classID,
                                   imageURL: nil,
                                   uid: "APPID",
                                   liked: false,
                                   messageID: "",
                                   flagged: false)
            cell.MessageText.text = "No Messages in this class yet"
            cell.UserNameOutlet.text = "Scholarly App"
            return cell
        }
        
        //Chat Log is NOT empty: 
        
        let cellMessage = chatLog[indexPath.row]
        switch cellMessage.messageType {
        case .text :
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! ChatMessageTableViewCell
            
            cell.message = chatLog[indexPath.row]
            cell.PrepareCellForDisplay()
            
            return cell
            
        case .image :
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ChatImageTableViewCell
            
            cell.message = self.chatLog[indexPath.row]
            cell.PrepareCellForDisplay()
            
            Storage.storage().reference(forURL: cell.message.imageURL!).getData(maxSize: INT64_MAX, completion: { (data, error) in
                guard error == nil else {
                    print("Error downloading: \(error!)")
                    return
                }
                let messageImage = UIImage.init(data: data!, scale: 50)
                self.imageCache.setObject(messageImage!, forKey: cell.message.imageURL! as NSString)
                // check if the cell is still on screen, if so, update cell image
                if cell == self.tableView.cellForRow(at: indexPath) {
                    DispatchQueue.main.async {
                        cell.ImageViewOutlet.image = messageImage
                        cell.setNeedsLayout()
                    }
                }
            })
            
            
            return cell
        }
    }
    
    // MARK: Number of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.chatLog.isEmpty) {
            //Empty ChatLog
            return 1
        } else {
            return(chatLog.count)
        }
    }
    
    // MARK: Did Select Row At
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        //IF image message, need to display imageDisplayVC
        if !(chatLog.count >= indexPath.row) {
            print("Empty Chat Log")
            return
        }
        let message = chatLog[indexPath.row]
        
        switch message.messageType {
        case .image:
            let cell = tableView.cellForRow(at: indexPath) as? ChatImageTableViewCell
            guard let messageImage = cell?.ImageViewOutlet.image else {
                print("Error in DidSelectCellForRowAt 1")
                return
            }
            
            self.selectedImage = messageImage
            
            self.performSegue(withIdentifier: "presentImageDisplay", sender: self)
        case .text:
            let cell = tableView.cellForRow(at: indexPath) as? ChatMessageTableViewCell
            cell?.delegate = self
            if (cell?.FlagButton.isHidden)! {
                //Show button
                cell?.FlagButton.isHidden = false
            } else {
                //Hide button
                cell?.FlagButton.isHidden = true
            }
        }
    }
    
    // MARK: Table View Scroll To Bottom
    func tableViewScrollToBottom(animated: Bool, delay: Bool) {
        if delay {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(110)) {
                let numberOfSections = self.tableView.numberOfSections
                let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
                
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                let numberOfSections = self.tableView.numberOfSections
                let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
                
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
            }
        }
    }
    //MARK: - Call Segue From Cell
    
    func callSegueFromCell(message: Message)  {
        self.messageToFlag = message
        self.performSegue(withIdentifier: "FlagSegue", sender: nil)
    }
    
    
    
    //MARK: - Text Field & Keyboard
    
    //MARK: Return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        SendAction(self)
        return true
    }
    
    
    
    
    //MARK: - IB Actions
    
    //MARK: SendAction
    @IBAction func SendAction(_ sender: Any) {
        if let messageText = MessageFieldOutlet.text {
            if(messageText != "") {
                guard let userFirstName = (UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.FirstName)) as? String) else {
                    print("Error: Found nil in ChatLogVC")
                    return
                }
                guard let userLastName = (UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.LastName)) as? String) else {
                    print("Error: Found nil in ChatLogVC")
                    return
                }
                guard let uid = Auth.auth().currentUser?.uid else {
                    print("Error: Found nil in ChatLogVC")
                    return
                }
                
                
                let message = Message(messageType: MessageType.text,
                                      message: messageText,
                                      userFirstName: userFirstName,
                                      userLastName: userLastName,
                                      timeStamp: (String(Date.timeIntervalSinceReferenceDate)),
                                      classID: classID ,
                                      imageURL : nil,
                                      uid: uid,
                                      liked: false,
                                      messageID: "not",
                                      flagged: false)
                
                sendMessage(message: message) { (messageSendStatus) in
                    if (messageSendStatus == MessageSendStatus.success) {
                        self.tableViewScrollToBottom(animated: true, delay: true)
                        self.MessageFieldOutlet.text = ""
                        lytTextMessageSent()
                    }
                }
            }
        }
    }
    
    //MARK: BackButtonAction
    @IBAction func BackButtonAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // vc is the Storyboard ID that you added
        // as! ... Add your ViewController class name that you want to navigate to
        let controller = storyboard.instantiateViewController(withIdentifier: "HomeScreenVC")
        controller.modalTransitionStyle = .crossDissolve;
        self.present(controller, animated: true, completion: { () -> Void in
        })
    }
    
    //MARK: InfoAction
    @IBAction func InfoAction(_ sender: Any) {
//        print("action triggered")
//        //Get List of UserIDs
//        getClassMemberIDsFor(classID: classID) { (memberIDs) in
//            print("Made it here")
//            //Get Array of Dictionaries of User Info for Each Class Member
//            getUserInfoFor(memberIDs: memberIDs, completionHandler: { (userInfo) in
//                self.userInfoArray = userInfo
//                //Remove Observers
//                
//                self.performSegue(withIdentifier: "InfoSegue", sender: self)
//            })
//        }
        self.performSegue(withIdentifier: "InfoSegue", sender: self)
    }
    
    //MARK: Add Image Button Clicked
    @IBAction func AddImageButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    
    
    //MARK: - Image Picker Functions
    
    //MARK: didFinishPickingMediaWithInfo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String:Any]) {
        // constant to hold the information about the photo
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage, let photoData = UIImageJPEGRepresentation(photo, 0.8) {
            // call function to upload photo message
            sendPhotoMessage(photoData: photoData)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    //MARK: imagePickerControllerDidCancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier as? String else {
            print("no identifier")
            return
        }
        switch identifier {
        case "InfoSegue":
            let secondViewController = segue.destination as! InfoViewController
            secondViewController.classID = self.classID
        case "presentImageDisplay":
            guard let secondVC = segue.destination as? ImageDisplayViewController else {
                print("Error in prepareForSegue")
                return
            }
            guard let imageToDisplay = self.selectedImage as? UIImage else {
                print("Error in PrepareForSegue 2")
                return
            }
            secondVC.image = imageToDisplay
        case "FlagSegue":
            guard let destinationVC = segue.destination as? FlagViewController else {
                print("Error in PrepareForSegue 3")
                return
            }
            destinationVC.message = self.messageToFlag
        default:
            break
        }
    }
    
    
    
    
    
    
    //MARK: Send Message Function
    typealias MessageDataClosure = (MessageSendStatus) -> Void
    func sendMessage(message: Message, completionHandler: @escaping MessageDataClosure) {
        if let classID = message.classID {
            let sendRef = Database.database().reference().child("SchoolData").child(UserDefaults.standard.value(forKey: "\(UserDefaultKeys.School)") as! String).child("ClassData").child(classID).child("Messages").childByAutoId()
            let secondSendRef = Database.database().reference().child("SchoolData").child(UserDefaults.standard.value(forKey: "\(UserDefaultKeys.School)") as! String).child("ClassData").child(classID).child("DisplayInfo")
            switch message.messageType {
            case .text:
                var likedStr = ""
                if message.liked {
                    likedStr = "TRUE"
                } else {
                    likedStr = "FALSE"
                }
                var flaggedStr = ""
                if message.flagged {
                    flaggedStr = "TRUE"
                } else {
                    flaggedStr = "FALSE"
                }
                let childUpdates = ["messageType" : String(
                    describing: message.messageType),
                                    "message" : message.message,
                                    "userFirstName" : message.userFirstName,
                                    "userLastName": message.userLastName,
                                    "timeStamp" : message.timeStamp,
                                    "classID" : message.classID,
                                    "uid" : message.uid,
                                    "liked" : likedStr,
                                    "messageID" : sendRef.key,
                                    "flagged" : flaggedStr]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
                dateFormatter.locale = Locale.init(identifier: "en_GB")
                dateFormatter.dateFormat = "MM-dd-yyyy"
                //dateFormatter.string(from: message.timeStamp), for: .normal
                let date = NSDate(timeIntervalSinceReferenceDate: Date.timeIntervalSinceReferenceDate)
                let dateStr = dateFormatter.string(from: date as Date)
                
                let secondChildUpdates = ["LastMessage" : message.message, "DateUpdated" : dateStr, "timeStamp"  : message.timeStamp]
                
                
                
                sendRef.updateChildValues(childUpdates)
                secondSendRef.updateChildValues(secondChildUpdates)
                break
            case .image:
                self.ProgressViewBar.setProgress(80, animated: true)
                
                var likedStr = ""
                if message.liked {
                    likedStr == "TRUE"
                } else {
                    likedStr == "FALSE"
                }
                
                var flaggedStr = ""
                if message.flagged {
                    flaggedStr = "TRUE"
                } else {
                    flaggedStr = "FALSE"
                }
                
                let childUpdates = ["messageType" : String(describing: message.messageType),
                                    "userFirstName" : message.userFirstName as String,
                                    "userLastName": message.userLastName as String,
                                    "timeStamp" : message.timeStamp as String,
                                    "classID" : message.classID!,
                                    "imageURL" : message.imageURL,
                                    "uid" : message.uid,
                                    "liked" : likedStr,
                                    "messageID": sendRef.key,
                                    "flagged" : flaggedStr]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
                dateFormatter.locale = Locale.init(identifier: "en_GB")
                dateFormatter.dateFormat = "MM-dd-yyyy"
                //dateFormatter.string(from: message.timeStamp), for: .normal
                let date = NSDate(timeIntervalSinceReferenceDate: Date.timeIntervalSinceReferenceDate)
                let dateStr = dateFormatter.string(from: date as Date)
                
                let secondChildUpdates = ["LastMessage" : "Photo Message", "DateUpdated" : dateStr, "timeStamp" : message.timeStamp]
                
                sendRef.updateChildValues(childUpdates)
                secondSendRef.updateChildValues(secondChildUpdates)
                break
            }
            completionHandler(MessageSendStatus.success)
        } else {
            completionHandler(MessageSendStatus.fail)
        }
        
    }
    
    //MARK: sendPhotoMessage
    func sendPhotoMessage(photoData : Data) {
        self.ProgressViewBar.isHidden = false
        self.ProgressViewBar.setProgress(80, animated: true)
        // build a path using the user’s ID and a timestamp
        let imagePath = "chat_photos/" + Auth.auth().currentUser!.uid + "/\(Double(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
        // set content type to “image/jpeg” in firebase storage metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        // create a child node at imagePath with imageData and metadata
        storageRef!.child(imagePath).putData(photoData, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error uploading: \(error)")
                return
            }
            self.ProgressViewBar.setProgress(80, animated: true)
            //Create message variables
            guard let userFirstName = (UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.FirstName)) as? String) else {
                print("Error: Found nil in ChatLogVC")
                return
            }
            guard let userLastName = (UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.LastName)) as? String) else {
                print("Error: Found nil in ChatLogVC")
                return
            }
            guard let uid = Auth.auth().currentUser?.uid else {
                print("Error: Found nil in ChatLogVC")
                return
            }
            
            let message = Message(messageType: .image,
                                  message: nil,
                                  userFirstName: userFirstName,
                                  userLastName: userLastName,
                                  timeStamp: (String(Date.timeIntervalSinceReferenceDate)),
                                  classID: self.classID ,
                                  imageURL: (self.storageRef!.child((metadata?.path)!).description),
                                  uid: uid,
                                  liked: false,
                                  messageID: "nothing",
                                  flagged: false)
            
            self.sendMessage(message: message, completionHandler: { (MessageSendStatus) in
                self.ProgressViewBar.setProgress(80, animated: true)
                self.tableViewScrollToBottom(animated: true, delay: true)
                self.MessageFieldOutlet.text = ""
                self.ProgressViewBar.isHidden = true
                lytImageMessageSent()
            })
        }
    }
}

//MARK: - TextView Extension
extension UITextView {
    func numberOfLines() -> Int {
        let layoutManager = self.layoutManager
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var lineRange: NSRange = NSMakeRange(0, 1)
        var index = 0
        var numberOfLines = 0
        
        while index < numberOfGlyphs {
            layoutManager.lineFragmentRect(
                forGlyphAt: index, effectiveRange: &lineRange
            )
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        return numberOfLines
    }
}
