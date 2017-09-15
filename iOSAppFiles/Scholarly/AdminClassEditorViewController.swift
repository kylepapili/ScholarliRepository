//
//  AdminClassEditorViewController.swift
//  Scholarli
//
//  Created by Kyle Papili on 9/14/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import Firebase

class AdminClassEditorViewController: UIViewController , UITableViewDataSource , UITableViewDelegate , UISearchBarDelegate {

    //Properties
    var classes = [[String : Any]]()
    var filteredData = [[String : Any]]()
    var isSearching = false
    var SelectedCellID : String = ""
    
    //Outlets
    @IBOutlet var TableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startObserver()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Create Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell", for: indexPath) as! ClassSelectorTableViewCell
        
        if isSearching {
            //If searching, populate cells from filteredData
            if let course = ((filteredData[indexPath.row]) as Dictionary?) {
                cell.AdminClassLabel.text = course["course"] as? String
            }
            
            if let period = ((filteredData[indexPath.row]) as Dictionary?) {
                cell.AdminPeriodLabel.text = "Period \(period["period"] as? String ?? "N/A")"
            }
            
            if let teacher = ((filteredData[indexPath.row]) as Dictionary?) {
                let teacherTitle = teacher["teacherTitle"] as? String
                let teacherLastName = teacher["teacherLastName"] as? String
                cell.AdminTeacherLabel.text = "\(teacherTitle ?? "") \(teacherLastName ?? "teacher")"
            }
            
            if let courseID = ((filteredData[indexPath.row]) as Dictionary?) {
                cell.AdminClassIDLabel.text = courseID["classID"] as? String
            }
        } else {
            //If NOT searching, populate cells from classes
            if let course = ((classes[indexPath.row]) as Dictionary?) {
                cell.AdminClassLabel.text = course["course"] as? String
            }
            
            if let period = ((classes[indexPath.row]) as Dictionary?) {
                cell.AdminPeriodLabel.text = "Period \(period["period"] as? String ?? "N/A")"
            }
            
            if let teacher = ((classes[indexPath.row]) as Dictionary?) {
                let teacherTitle = teacher["teacherTitle"] as? String
                let teacherLastName = teacher["teacherLastName"] as? String
                cell.AdminTeacherLabel.text = "\(teacherTitle ?? "") \(teacherLastName ?? "teacher")"
            }
            
            if let courseID = ((classes[indexPath.row]) as Dictionary?) {
                cell.AdminClassIDLabel.text = courseID["classID"] as? String
            }
        }
        //Return Cell
        return (cell)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.classes.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Do something
        guard let idToPass = self.classes[indexPath.row]["classID"] as? String else {
            return
        }
        self.SelectedCellID = idToPass
        self.performSegue(withIdentifier: "adminEditClassSegue", sender: self)
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
            self.TableView.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "adminEditClassSegue" {
            let destinationVC = segue.destination as? AdminEditClassViewController
            destinationVC?.classIDToEdit = self.SelectedCellID
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
            TableView.reloadData()
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
                TableView.reloadData()
            }
        }
    }
}
