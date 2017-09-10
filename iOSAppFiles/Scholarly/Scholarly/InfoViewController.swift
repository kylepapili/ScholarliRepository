//
//  InfoViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/29/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet var tableview: UITableView!
    
    var UserDataDict : [[String : String]]? = nil
    var classID : String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard let classIDSafe = self.classID as? String else {
            print("Error in InfoVC")
            return
        }
        
        getClassMemberIDsFor(classID: classIDSafe) { (memberIDs) in
            print("Made it here")
            //Get Array of Dictionaries of User Info for Each Class Member
            getUserInfoFor(memberIDs: memberIDs, completionHandler: { (userInfo) in
                self.UserDataDict = userInfo
                self.tableview.reloadData()
            })
        }
        
    }
    
    //Table View Functions
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentInfoCell", for: indexPath) as! InfoTableViewCell
        
        guard let usersDict = self.UserDataDict else {
            cell.StudentNameOutlet.text = "Loading..."
            return cell
        }
        cell.StudentNameOutlet.text = "\((usersDict[indexPath.row]["FirstName"])!) \((usersDict[indexPath.row]["LastName"])!)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let usersDict = self.UserDataDict else {
            return 1
        }
        return (usersDict.count)
    }
    
}
