//
//  ProfileViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 7/12/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    //MARK: - IBOutlets
    @IBOutlet var ProfileUIImageView: UIImageView!
    @IBOutlet var FullNameUILabel: UILabel!
    @IBOutlet var SchoolUILabel: UILabel!
    @IBOutlet var PhoneNumberUILabel: UILabel!
    @IBOutlet var TableView: UITableView!
    
    //MARK: - Properties
    var userData : UserData? = nil
    var classData : [[String: AnyObject]]? = nil
    var classIDsArray : [String]? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userData = prepareUserData() else {
            print("Error: Found nil in ProfileViewController")
            return
        }
        self.userData = userData
        self.classIDsArray = self.userData?.userClasses
        
        //Set Labels
        FullNameUILabel.text = userData.userFullName
        SchoolUILabel.text = userData.userSchool
        PhoneNumberUILabel.text = userData.userPhoneNumber
        
        //Profile Image
        ProfileUIImageView.image = #imageLiteral(resourceName: "DefaultProfilePicture")
        
        prepareClassInfoData { (classData) in
            self.classData = classData
            self.TableView.reloadData()
        }
    }
    
    
    
    //MARK: - Table View Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let classes = classIDsArray else {
            print("Error: Found nil in ProfileViewController 1")
            return 1
        }
        return classes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? ClassSelectorTableViewCell else {
            print("Error: Found nil in ProfileViewController 2")
            fatalError()
        }
        guard let classes = classIDsArray else {
            print("Error: Found nil in ProfileViewController 2.5")
            return cell
        }
        guard let currentClassData = self.classData?[indexPath.row] else {
            cell.ProfileClassLabel.text = "loading"
            return cell
        }
        
        guard let classTitle = (currentClassData["course"] as? String) else {
            print("Error: found nil in ProfileViewController 3")
            return cell
        }
        guard let period = (currentClassData["period"] as? String) else {
            print("Error: found nil in ProfileViewController 4")
            return cell
        }
        guard let teacherTitle = (currentClassData["teacherTitle"] as? String) else {
            print("Error: found nil in ProfileViewController 5")
            return cell
        }
        guard let teacherLastName = (currentClassData["teacherLastName"] as? String) else {
            print("Error: found nil in ProfileViewController 6")
            return cell
        }
        
        cell.ProfileTeacherLabel.text = "\(teacherTitle) \(teacherLastName)"
        cell.ProfilePeriodLabel.text = "Period: \(period)"
        cell.ProfileClassLabel.text = classTitle
        return cell
    }
    
    //MARK: - User Data Preparation Function
    func prepareUserData() -> UserData? {
        guard let userFirstName = UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.FirstName)) as? String else {
            print("Error: Found nil in ProfileViewController 7")
            return nil
        }
        guard let userLastName = UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.LastName)) as? String else {
            print("Error: Found nil in ProfileViewController 8")
            return nil
        }
        guard let userSchool = UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.School)) as? String else {
            print("Error: Found nil in ProfileViewController")
            return nil
        }
        guard let userPhoneNumber = UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.PhoneNumber)) as? String else {
            print("Error: Found nil in ProfileViewController")
            return nil
        }
        guard let userClasses = UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.Classes)) as? [String] else {
            print("Error: Found nil in ProfileViewController")
            return nil
        }
        
        let userData = UserData(userFirstName: userFirstName,
                                userLastName: userLastName,
                                userSchool: userSchool,
                                userPhoneNumber: userPhoneNumber,
                                userClasses: userClasses)
        return userData
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier as? String else {
            return
        }
        switch identifier {
            case "ClassEditorSegue":
            let destinationVC = segue.destination as! ClassEditorViewController
            //Nothing to do
        default:
            break
        }
    }
}
