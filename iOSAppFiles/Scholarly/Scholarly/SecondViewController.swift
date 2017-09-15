//
//  SecondViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/20/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import Firebase

class SecondViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    var assignmentArray : [[String : String]]? = nil
    var assignmentIDS : [String]? = nil
    var hasAssignments : Bool = false
    
    @IBOutlet var TableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        prepareAssignmentArray {
            self.TableView.reloadData()
        }
        self.TableView.reloadData()
    }
    
    //////////
    //Table View Functions
    //////////
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AgendaCell", for: indexPath) as! AgendaTableViewCell
        if let unwrapped = assignmentArray {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
            dateFormatter.locale = Locale.init(identifier: "en_GB")
            
            cell.AssignmentTitleOutlet.text = unwrapped[indexPath.row]["title"]
            cell.ClassTitleOutlet.text = unwrapped[indexPath.row]["classTitle"]
            cell.AssignmentTypeOutlet.text = unwrapped[indexPath.row]["assignmentType"]
            cell.DueDateOutlet.text = unwrapped[indexPath.row]["dueDate"]
            
            
            let date = dateFormatter.date(from: unwrapped[indexPath.row]["dueDate"]!)
            let cal = Calendar.current
            let today = cal.startOfDay(for: Date())
            let dayAndMonth = cal.dateComponents([.day, .month], from: date!)
            let nextBirthDay = cal.nextDate(after: today, matching: dayAndMonth, matchingPolicy: .nextTimePreservingSmallerComponents)!
            let diff = cal.dateComponents([.day], from: today, to: nextBirthDay)
            if diff.day! == 1 {
                cell.DueDateOutlet.textColor = UIColor.orange
            } else {
                cell.DueDateOutlet.textColor = UIColor.black
            }
        } else {
            cell.AssignmentTitleOutlet.text = "No assignments Yet"
            cell.AssignmentTypeOutlet.text = ""
            cell.ClassTitleOutlet.text = ""
            cell.DueDateOutlet.text = ""
            cell.DueDateOutlet.textColor = UIColor.black
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let unwrapped = assignmentArray {
            return unwrapped.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Nothing yet...
        //Proceed to Assignment Editor VC
        if hasAssignments {
            self.performSegue(withIdentifier: "AssignmentEditorSegue", sender: self)
        }
        TableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if hasAssignments {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            self.assignmentArray!.remove(at: indexPath.item)
            self.assignmentIDS!.remove(at: indexPath.item)
            updateUserAssignmentsFor(assignmentArray: assignmentArray!, completion: {
                tableView.deleteRows(at: [indexPath], with: .automatic)
                lytAgendaItemDeleted()
            })
        }
    }
    
    ///////////////////
    //PrepareForSegue//
    ///////////////////
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AssignmentEditorSegue" {
            let editorVC = segue.destination as! AssignmentEditorViewController
            editorVC.assignmentArray = self.assignmentArray?[(TableView.indexPathForSelectedRow?.row)!]
            print("ASSIGNMENT ARRAY: \(self.assignmentArray?[(TableView.indexPathForSelectedRow?.row)!])")
            editorVC.assignmentID = (self.assignmentIDS?[(TableView.indexPathForSelectedRow?.row)!])!
        }
    }
    
    
    //////////////
    //Initialize TableView Function
    /////////////
    func prepareAssignmentArray(completion: @escaping () -> Void) {
        let AgendaRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("Agenda")
        
        AgendaRef.observe(.value, with: { (Snapshot) in
            if !(Snapshot.value is NSNull) {
                let data = Snapshot.value as! [String : [String : String]]
                self.assignmentIDS = Array(data.keys)
                self.assignmentArray = Array(data.values)
                
                self.assignmentArray?.sort(by: { (item1, item2) -> Bool in
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy"
                    dateFormatter.locale = Locale.init(identifier: "en_GB")
                    
                    let itemOneDate = dateFormatter.date(from: item1["dueDate"]!)
                    let itemTwoDate = dateFormatter.date(from: item2["dueDate"]!)
                    
                    if itemOneDate! < itemTwoDate! {
                        return true
                    } else {
                        return false
                    }
                })
                self.hasAssignments = true
                completion()
            } else {
                self.hasAssignments = false
            }
            self.TableView.reloadData()
        })
    }
}

