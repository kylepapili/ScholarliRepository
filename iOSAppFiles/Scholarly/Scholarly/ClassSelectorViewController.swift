//
//  ClassSelectorViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/21/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import Firebase
class ClassSelectorViewController: UIViewController, UITableViewDelegate , UITableViewDataSource, UISearchBarDelegate{
    var classes = [[String : Any]]()
    var UserClassSelections = [String]()
    var filteredData = [[String : Any]]()
    let ref = Database.database().reference()
    var isSearching = false
    var hasAddedClass : Bool = false
    
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
                self.performSegue(withIdentifier: "addClassSegue", sender: self)
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
    
    
    //////////
    //Cell For Row At
    //////////
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Create Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell", for: indexPath) as! ClassSelectorTableViewCell
        
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
                self.filteredData = sortByCourse(classesArray: filteredData)
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
            let userRef = ref.child("users").child((Auth.auth().currentUser?.uid)!).child("classes")
            for singleClass in UserClassSelections {
                //Post Selected Classes to Firebase Under User ID
                    userRef.child(singleClass).setValue(singleClass)
                //Post Selected Classes to Firebase Under ClassID
                //****NEED TO CHANGE HARD CODED WEST MORRIS MENDHAM TO THE USERS SCHOOL****
                    ref.child("SchoolData").child("West Morris Mendham").child("classMembers").child(singleClass).childByAutoId().setValue((Auth.auth().currentUser?.uid)!)
            }
            //Proceed to Next Screen
            
            //let FinalSetupViewController = self.storyboard?.instantiateViewController(withIdentifier:"FinalSetupViewController") as! FinalSetupViewController
            //self.present(FinalSetupViewController, animated: true, completion: nil)
            let destinationVC = storyboard?.instantiateViewController(withIdentifier: "FinalSetupVC") as! FinalSetupViewController
            self.present(destinationVC, animated: true, completion: nil)
        }
    }
    
    
}
