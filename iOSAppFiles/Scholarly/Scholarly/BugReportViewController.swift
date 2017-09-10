//
//  BugReportViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 7/12/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import Firebase

class BugReportViewController: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet var BugDescriptionTextView: UITextView!
    @IBOutlet var ErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ErrorLabel.isHidden = true
        let myColor : UIColor = UIColor.gray
        BugDescriptionTextView.layer.borderColor = myColor.cgColor
        BugDescriptionTextView.layer.borderWidth = 1.0
        BugDescriptionTextView.clipsToBounds = true
        BugDescriptionTextView.layer.cornerRadius = 10.0
    }

    @IBAction func SendReport(_ sender: Any) {
        guard let bugReport = BugDescriptionTextView.text else {
            print("Error: Found nil in BugReportViewController")
            return
        }
        
        if bugReport == "" || bugReport.characters.count < 120 {
            ErrorLabel.text = "Bug Report Must be at least 120 characters"
            ErrorLabel.isHidden = false
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.05
            animation.repeatCount = 3
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: self.ErrorLabel.center.x - 8, y: self.ErrorLabel.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: self.ErrorLabel.center.x + 8, y: self.ErrorLabel.center.y))
            self.ErrorLabel.layer.add(animation, forKey: "position")
            return
        }
        let deviceName = UIDevice.current.modelName
        let systemVersion = UIDevice.current.systemVersion

        let ref = Database.database().reference().child("BugReports").childByAutoId()
        
        guard let childValues = ["UID" : Auth.auth().currentUser?.uid,
                           "firstName" : UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.FirstName)),
                           "lastName" : UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.LastName)),
                           "bugDescription" : bugReport,
                           "device" : deviceName,
        "systemVersion" : systemVersion] as? [String : String] else {
                            print("Error: Found nil in BugReportViewController")
                            return
        }
        
        ref.updateChildValues(childValues)
        
        finishedSendingBugReport()
    }
    
    func finishedSendingBugReport() {
        let alert = UIAlertController(title: "Bug Reported", message: "Thank You for helping make Scholarly a better app!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
            _ = self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}
