//
//  FirstViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/20/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


var UniversalClassData: [[String: AnyObject]] = [["" : "" as AnyObject]]

class FirstViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    let ref = Database.database().reference()
    var ClassData = UniversalClassData
    var classID : String? = nil
    var className : String? = nil
    @IBOutlet var TableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        prepareClassData { (refreshedClassData) in
            self.ClassData = refreshedClassData
            let range = NSMakeRange(0, self.TableView.numberOfSections)
            let sections = NSIndexSet(indexesIn: range)
            self.TableView.reloadSections(sections as IndexSet, with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as? MessageTableViewCell else {
            print("Error: Found nil")
            fatalError()
        }
        guard let classNameText = ClassData[indexPath.row]["ClassName"] as? String else {
            print("Error: Found nil")
            fatalError()
        }
        
        guard let LastMessageText = ClassData[indexPath.row]["LastMessage"] as? String else {
            print("Error: Found nil")
            fatalError()
        }
        
        guard let dateText = ClassData[indexPath.row]["DateUpdated"] as? String else {
            print("Error: Found nil")
            fatalError()
        }
        
        cell.ClassNameText.text = classNameText
        cell.LastMessageText.text = LastMessageText
        let dateUpdated = dateText
        cell.DateText.text = (dateUpdated)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ClassData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //DeSelect Cell for Visual Effect
        TableView.deselectRow(at: indexPath, animated: true)
        
        guard let classID = ClassData[indexPath.row]["classID"] as? String else {
            print("Error: Found nil")
            fatalError()
        }
        
        guard let className = ClassData[indexPath.row]["ClassName"] as? String else {
            print("Error: Found nil")
            fatalError()
        }
        
        self.classID = classID
        self.className = className
        
        self.performSegue(withIdentifier: "ToChatLogVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Need to pass ChatLogVC the ClassId
        let destinationVC = segue.destination as! ChatLogViewController
        destinationVC.classID = self.classID!
        destinationVC.className = self.className!
    }
}

