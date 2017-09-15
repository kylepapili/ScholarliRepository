//
//  AdminEditClassViewController.swift
//  Scholarli
//
//  Created by Kyle Papili on 9/14/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import Firebase

class AdminEditClassViewController: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource{

    //Properties
    var PickerViewDataSource : [String]? = nil
    var classBeingEdited : courseData? = nil
    var classIDToEdit : String? = nil
    var Titles : Array = ["Mr.", "Mrs.", "Ms.", "Dr.", "Sra.", "Sr.", "Srta."]
    var Periods : Array = ["1", "2", "3", "4", "5", "6", "7", "8"]
    var currentSelection : Selection? = nil
    enum Selection {
        case period , title
    }
    
    //Outlets
    
    @IBOutlet var ClassID: UITextView!
    @IBOutlet var CourseTitle: UITextField!
    @IBOutlet var Period: UIButton!
    @IBOutlet var TeacherLastName: UITextField!
    @IBOutlet var TeacherTitle: UIButton!
    @IBOutlet var HidePickerButton: UIButton!
    @IBOutlet var PickerView: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.PickerView.isHidden = true
        self.HidePickerButton.isHidden = true
        self.ClassID.isEditable = false
        
        print(self.classIDToEdit)
        
        if let id = classIDToEdit {
            retrieveClassData(classID: id) {
                self.setupOutlets()
            }
        }
        
    }
    
    func setupOutlets() {
        print(self.classBeingEdited)
        self.ClassID.text = classBeingEdited?.classID
        self.CourseTitle.text = classBeingEdited?.course
        self.Period.titleLabel?.text = classBeingEdited?.period
        self.TeacherLastName.text = classBeingEdited?.teacherLastName
        self.TeacherTitle.titleLabel?.text = classBeingEdited?.teacherTitle
    }
    
    func retrieveClassData(classID: String, completion : @escaping () -> Void) {
        let classRef = Database.database().reference().child("SchoolData").child(UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.School)) as! String).child("classes").child(classID)
        
        classRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let classData = snapshot.value as? [String : Any] else {
                return
            }
            
            self.classBeingEdited = courseData(classID: classData["classID"] as! String, course: classData["course"] as! String, period: classData["period"] as! String, teacherLastName: classData["teacherLastName"] as! String, teacherTitle: classData["teacherTitle"] as! String)
            completion()
            
        })
        
    }
    
    
    @IBAction func TitleButtonAction(_ sender: Any) {
        self.currentSelection = .title
        self.PickerViewDataSource = self.Titles
        self.PickerView.isHidden = false
        self.HidePickerButton.isHidden = false
        self.PickerView.reloadAllComponents()
    }

    @IBAction func HidePicker(_ sender: Any) {
        self.PickerView.isHidden = true
        self.PickerViewDataSource = nil
        self.currentSelection = nil
    }
    
    @IBAction func PeriodButtonAction(_ sender: Any) {
        self.currentSelection = .period
        self.PickerViewDataSource = self.Periods
        self.PickerView.isHidden = false
        self.HidePickerButton.isHidden = false
        self.PickerView.reloadAllComponents()
    }
    
    
    //Picker View Functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let PickerViewDS = self.PickerViewDataSource as? [String] else {
            return 1
        }
        return PickerViewDS.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let PickerViewDS = self.PickerViewDataSource as? [String] else {
            return "Error"
        }
        if (PickerViewDS.count > 0){
            return PickerViewDataSource?[row]
        } else {
            return "Error"
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let safeSelection = currentSelection else {
            return
        }
        switch safeSelection {
        case .period:
            self.Period.titleLabel?.text = self.Periods[row]
        case .title:
            self.TeacherTitle.titleLabel?.text = self.Titles[row]
        default:
            print("default")
        }
    }
    
}
