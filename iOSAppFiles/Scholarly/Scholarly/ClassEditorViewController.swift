//
//  ClassSelectorViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/21/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
class ClassEditorViewController: UIViewController, UITableViewDelegate , UITableViewDataSource, UISearchBarDelegate{
    var classes = [[String : Any]]()
    var UserClassSelections = [String]()
    var filteredData = [[String : Any]]()
    let ref = Database.database().reference()
    var isSearching = false
    var hasAddedClass : Bool = false
    var originalUserClasses : [String]? = nil
    
    @IBOutlet var WarningLabelText: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    
    //Add class
    
    @IBAction func AddClassAction(_ sender: Any) {
        
        switch hasAddedClass {
        case true:
            // Create the alert controller
            let alertController = UIAlertController(title: "Add Class", message: "Are you sure that the class you are trying to add does not already exist?", preferredStyle: .alert)
            
            // Create the actions
            let yesAction = UIAlertAction(title: "Yes, Let Me Add It!", style: UIAlertActionStyle.default) {
                UIAlertAction in
                //Proceed to New Class
                self.performSegue(withIdentifier: "addClassSegueFromEditor", sender: self)
            }
            
            let cancelAction = UIAlertAction(title: "No, let me check", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
            }
            
            // Add the actions
            alertController.addAction(yesAction)
            alertController.addAction(cancelAction)
            
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
            
        case false:
            let alertController = UIAlertController(title: "Add Class", message:
                "To avoid duplicate classes, please double check that the class you are trying to add does not already exist.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (action) in
                self.hasAddedClass = true
            }))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier as? String else {
            return
        }
        switch identifier {
        case "addClassSegueFromEditor" :
            let destinationVC = segue.destination as! AddClassViewController
            destinationVC.sender = "editor"
        default:
            return
        }
    }
    
    
    //////////
    //Cell For Row At
    //////////
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Create Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell", for: indexPath) as! ClassSelectorTableViewCell
        
        if classes == nil {
            cell.CourseText.text = "loading"
            return cell
        }
        if isSearching {
            //If searching, populate cells from filteredData
            if let course = ((filteredData[indexPath.row]) as Dictionary?) {
                cell.CourseText.text = course["course"] as? String
            }
            
            if let period = ((filteredData[indexPath.row]) as Dictionary?) {
                cell.PeriodText.text = "Period \(period["period"] as? String ?? "N/A")"
            }
            
            if let teacher = ((filteredData[indexPath.row]) as Dictionary?) {
                let teacherTitle = teacher["teacherTitle"] as? String
                let teacherLastName = teacher["teacherLastName"] as? String
                cell.TeacherText.text = "\(teacherTitle ?? "") \(teacherLastName ?? "teacher")"
            }
            
            if let courseID = ((filteredData[indexPath.row]) as Dictionary?) {
                cell.ClassIDText.text = courseID["classID"] as? String
            }
        } else {
            //If NOT searching, populate cells from classes
            if let course = ((classes[indexPath.row]) as Dictionary?) {
                cell.CourseText.text = course["course"] as? String
            }
            
            if let period = ((classes[indexPath.row]) as Dictionary?) {
                cell.PeriodText.text = "Period \(period["period"] as? String ?? "N/A")"
            }
            
            if let teacher = ((classes[indexPath.row]) as Dictionary?) {
                let teacherTitle = teacher["teacherTitle"] as? String
                let teacherLastName = teacher["teacherLastName"] as? String
                cell.TeacherText.text = "\(teacherTitle ?? "") \(teacherLastName ?? "teacher")"
            }
            
            if let courseID = ((classes[indexPath.row]) as Dictionary?) {
                cell.ClassIDText.text = courseID["classID"] as? String
            }
        }
        //Determine whether cell has been selected or not by looking at UserClassSelections Array
        if let courseID = cell.ClassIDText.text {
            if UserClassSelections.contains(courseID) {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
        }
        //Return Cell
        return (cell)
    }
    
    
    //////////
    //Number of Rows
    //////////
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  isSearching {
            return filteredData.count
        }
        if classes == nil {
            return 1
        }
        return classes.count
    }
    
    
    //////////
    //DidSelectRowAt
    //////////
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //DeSelect Cell for Visual Effect
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Create a cell for reference
        let cell = tableView.cellForRow(at: indexPath) as! ClassSelectorTableViewCell
        
        if(cell.accessoryType == UITableViewCellAccessoryType.checkmark) {
            //If cell already has a checkmark, hide it & remove that cell from UserClassSelections array
            cell.accessoryType = UITableViewCellAccessoryType.none
            if let classID = cell.ClassIDText.text {
                if let index = UserClassSelections.index(of: classID) {
                    UserClassSelections.remove(at: index)
                }
            }
            print(UserClassSelections)
        } else {
            //If Cell does not have a checkmark, check to see if user has less that 8 classes selected
            if(UserClassSelections.count == 8) {
                //Can't add more than 8
                WarningLabelText.textColor = UIColor.red
                let animation = CABasicAnimation(keyPath: "position")
                animation.duration = 0.07
                animation.repeatCount = 3
                animation.autoreverses = true
                animation.fromValue = NSValue(cgPoint: CGPoint(x: self.WarningLabelText.center.x - 8, y: self.WarningLabelText.center.y))
                animation.toValue = NSValue(cgPoint: CGPoint(x: self.WarningLabelText.center.x + 8, y: self.WarningLabelText.center.y))
                self.WarningLabelText.layer.add(animation, forKey: "position")
            } else {
                //If user has less than eight classes, select the cell and add it to the UserClassSelections Array
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
                if let classID = cell.ClassIDText.text {
                    UserClassSelections.append(classID)
                }
                //UserClassSelections[counter] = (classes[counter] as AnyObject).value!(forKey: "classID") as? String
                print(UserClassSelections)
            }
        }
    }
    
    
    //////////
    //searchBar(textDidChange)
    //////////
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            //If nothing is typed in searchBar, just show the normal tableView
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            //When something is typed in search bar, populate filteredData array with the appropriate results
            if let searchText = searchBar.text {
                isSearching = true
                filteredData =  classes.filter({ (dict) -> Bool in
                    if let course = dict["course"] as? String {
                        return course.lowercased().contains(searchText.lowercased())
                    }
                    if let teacher = dict["teacherLastName"] as? String {
                        return teacher.lowercased().contains(searchText.lowercased())
                    }
                    if let period = dict["period"] as? String {
                        return period.lowercased().contains(searchText.lowercased())
                    }
                    return false
                })
                //nfilteredData = classes.filter({($0 as AnyObject) as! String == searchBar.text}) as NSArray
                filteredData = sortByCourse(classesArray: filteredData)
                tableView.reloadData()
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        startObserver()
        loadUserClasses()
    }
    
    func loadUserClasses() {
        let userClasses = UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.Classes)) as! [String]
        self.UserClassSelections = userClasses
        self.originalUserClasses = userClasses
        print(self.UserClassSelections)
    }
    
    func startObserver() {
        let classesRef = Database.database().reference().child("SchoolData").child(UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.School)) as! String).child("classes")
        classesRef.observe(.value, with: { (FIRDataSnapshot) in
            guard let dataDict = FIRDataSnapshot.value as? [String : [String : Any]] else {
                print("Error in startObserver")
                return
            }
            guard let dataArray = Array(dataDict.values) as? [[String : Any]] else {
                print("Error in startObserver 2")
                return
            }
            self.classes = dataArray
            self.classes = sortByCourse(classesArray: dataArray)
            self.tableView.reloadData()
        })
    }
    
    @IBAction func ContinueAction(_ sender: Any) {
        if(UserClassSelections.count < 3) {
            let alert = UIAlertController(title: "Not Enough Classes", message: "You MUST select at least 3 Classes", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            
            // Create the alert controller
            let alertController = UIAlertController(title: "Update Classes", message: "Are you sure you would like to update your selected classes?", preferredStyle: .alert)
            
            // Create the actions
            let affirmAction = UIAlertAction(title: "Yes, update!", style: UIAlertActionStyle.default) {
                UIAlertAction in
                //Update user classes and proceed
                print(self.originalUserClasses)
                print(self.UserClassSelections)
                checkUserLastClassUpdate(user: (Auth.auth().currentUser?.uid)!, completion: { (result) in
                    if result {
                        updateUserClasses(originalClasses: self.originalUserClasses!, newClasses: self.UserClassSelections, completion: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        //Alert user, cannot update for another day
                        let alertController = UIAlertController(title: "Unable to Update Classes", message: "You may only update your classes once a day. Please try again later.", preferredStyle: .alert)
                        
                        let okAction = UIKit.UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                        alertController.addAction(okAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
            }
            
            let cancelAction = UIAlertAction(title: "No, cancel", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
            }
            
            // Add the actions
            alertController.addAction(affirmAction)
            alertController.addAction(cancelAction)
            
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}
