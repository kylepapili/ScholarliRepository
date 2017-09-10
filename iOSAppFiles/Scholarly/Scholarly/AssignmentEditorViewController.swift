//
//  AssignmentEditorViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 7/7/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit

class AssignmentEditorViewController: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource , UITextViewDelegate {
    //Variables
    var assignmentArray : [String : String]? = nil
    var assignment : Assignment? = nil
    let assignmentTypes = ["Homework", "Essay", "Test", "Quiz", "Project"]
    let classes = UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.Classes) as String) as! [String]
    var classNamesArray = [""]
    var pickerSelection : String = ""
    var assignmentID : String = ""
    
    //Selector Enum
    enum selectorOption {
        case classSelection , assignmentType , dueDate , nothing
    }
    var currentSelection : selectorOption = .nothing
    
    //Outlets
    @IBOutlet var AssignmentTitleOutlet: UITextField!
    @IBOutlet var ClassOutlet: UIButton!
    @IBOutlet var AssignmentTypeOutlet: UIButton!
    @IBOutlet var DueDateOutlet: UIButton!
    @IBOutlet var AdditionalInfoOutlet: UITextView!
    @IBOutlet var DatePickerOutlet: UIDatePicker!
    @IBOutlet var PickerViewOutlet: UIPickerView!
    @IBOutlet var ErrorMessagelabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load ClassNamesArray
        ArrayOfClassesFor(arrayOfClassIDs: classes) { (classNamesArray) in
            self.classNamesArray = classNamesArray
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        
        let title = assignmentArray?["title"]
        let classTitle = assignmentArray?["classTitle"]
        let classID = assignmentArray?["classID"]
        let assignmentType = assignmentArray?["assignmentType"]
        let dueDateStr = assignmentArray?["dueDate"]
        let dueDate = dateFormatter.date(from: dueDateStr!)
        let additionalInfo = assignmentArray?["additionalInfo"]
        
        assignment = Assignment(title: title!, classTitle: classTitle!, classID: classID!, assignmentType: assignmentType!, dueDate: dueDate, additionalInfo: additionalInfo!)
        
        //Set Labels and such
        AssignmentTitleOutlet.text = assignment?.title as? String
        ClassOutlet.setTitle(assignment?.classTitle, for: .normal)
        AssignmentTypeOutlet.setTitle(assignment?.assignmentType, for: .normal)
        DueDateOutlet.setTitle(dueDateStr, for: .normal)
        if assignment?.additionalInfo != nil && assignment?.additionalInfo != "" {
            AdditionalInfoOutlet.text = assignment?.additionalInfo
        } else {
            AdditionalInfoOutlet.text = "Additional Info"
        }
        
        //Hide Pickers and Error Message
        PickerViewOutlet.isHidden = true
        DatePickerOutlet.isHidden = true
        ErrorMessagelabel.isHidden = true
    }

    /////////////////////////
    //Picker View Functions//
    /////////////////////////
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch currentSelection {
        case .assignmentType:
            return assignmentTypes[row]
            break
        case .classSelection:
            return classNamesArray[row]
            break
        case .nothing :
            return ""
            break
        case .dueDate :
            return ""
            break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //Nothing yet
        switch currentSelection {
        case .assignmentType:
            pickerSelection = assignmentTypes[PickerViewOutlet.selectedRow(inComponent: component)]
            AssignmentTypeOutlet.setTitle(pickerSelection, for: .normal)
            break
        case .classSelection:
            pickerSelection = classNamesArray[PickerViewOutlet.selectedRow(inComponent: component)]
            ClassOutlet.setTitle(pickerSelection, for: .normal)
            break
        case .dueDate:
            //Should never happen
            break
        case .nothing:
            //Should never happen
            break
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch currentSelection {
        case .assignmentType:
            return assignmentTypes.count
            break
        case .classSelection:
            return classNamesArray.count
            break
        case .nothing :
            return 1
            break
        case .dueDate :
            return 1
            break
        }
    }
    
    
    ////////////////////
    /////IB Actions/////
    ////////////////////
    @IBAction func ClassSelectorAction(_ sender: Any) {
        self.view.endEditing(true)
        AssignmentChange()
        currentSelection = .classSelection
        DatePickerOutlet.isHidden = true
        PickerViewOutlet.isHidden = false
        PickerViewOutlet.reloadAllComponents()
        if ClassOutlet.titleLabel?.text == "Class" {
            PickerViewOutlet.selectRow(0, inComponent: 0, animated: false)
        } else {
            PickerViewOutlet.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    @IBAction func AssignmentTypeAction(_ sender: Any) {
        self.view.endEditing(true)
        AssignmentChange()
        currentSelection = .assignmentType
        DatePickerOutlet.isHidden = true
        PickerViewOutlet.isHidden = false
        PickerViewOutlet.reloadAllComponents()
        if AssignmentTypeOutlet.titleLabel?.text == "Assignment Type" {
            PickerViewOutlet.selectRow(0, inComponent: 0, animated: false)
        } else {
            PickerViewOutlet.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    @IBAction func DueDateSelectorAction(_ sender: Any) {
        self.view.endEditing(true)
        AssignmentChange()
        currentSelection = .dueDate
        DatePickerOutlet.isHidden = false
        PickerViewOutlet.isHidden = true
        PickerViewOutlet.reloadAllComponents()
        DatePickerOutlet.datePickerMode = .date
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        AssignmentChange()
        currentSelection = .nothing
        DatePickerOutlet.isHidden = true
        PickerViewOutlet.isHidden = true
        if AdditionalInfoOutlet.text == "Additional Information" {
            AdditionalInfoOutlet.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if AdditionalInfoOutlet.text == "" {
            AdditionalInfoOutlet.text = "Additional Information"
        }
    }
    @IBAction func AssignmentTitleDidBeginEditing(_ sender: Any) {
        AssignmentChange()
        DatePickerOutlet.isHidden = true
        PickerViewOutlet.isHidden = true
        currentSelection = .nothing
    }
    @IBAction func DateSelectionChanged(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        dateFormatter.dateFormat = "MM-dd-yyyy"
        DueDateOutlet.setTitle(dateFormatter.string(from: DatePickerOutlet.date), for: .normal)
    }
    
    
    //////////////////////////////
    //Assignment Change Function//
    //////////////////////////////
    func AssignmentChange() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        
        switch currentSelection {
        case .assignmentType:
            let pickerViewSelection = PickerViewOutlet.description
            for var value in assignmentTypes {
                if pickerViewSelection == value {
                    assignment?.assignmentType = PickerViewOutlet.description
                    AssignmentTypeOutlet.setTitle(pickerSelection, for: .normal)
                    break
                }
            }
            break
        case .classSelection:
            let pickerViewSelection = PickerViewOutlet.description
            for var value in classNamesArray {
                if pickerViewSelection == value {
                    assignment?.classTitle = pickerViewSelection
                    assignment?.classID = classes[PickerViewOutlet.selectedRow(inComponent: 0)]
                    ClassOutlet.setTitle(pickerSelection, for: .normal)
                    break
                }
            }
            break
            
        case .dueDate:
            assignment?.dueDate = DatePickerOutlet.date
            dateFormatter.dateFormat = "MM-dd-yyyy"
            DueDateOutlet.setTitle( dateFormatter.string(from: DatePickerOutlet.date) , for: .normal)
            break
            
        case .nothing:
            //Do Nothing
            break
        }
    }
    
    /////////////////
    //Save Function//
    /////////////////
    @IBAction func SaveButtonAction(_ sender: Any) {
        
        //Check to see all necessary fields are filled out
        var errorMessage : String? = nil
        if AssignmentTitleOutlet.text == nil || AssignmentTitleOutlet.text == "" {
            errorMessage = "Assignment Must Have a Title."
        }
        if ClassOutlet.titleLabel?.text == "Class" {
            if errorMessage == nil {
                errorMessage = "A class must be specified for the assignment."
            } else {
                errorMessage = errorMessage! + " A class must be specified for the assignment."
            }
        }
        if AssignmentTypeOutlet.titleLabel?.text == "Assignment Type" {
            if errorMessage == nil {
                errorMessage = "Assignment type must be specified."
            } else {
                errorMessage = errorMessage! + " Assignment type must be specified."
            }
        }
        if errorMessage != nil {
            ErrorMessagelabel.text = errorMessage
            ErrorMessagelabel.isHidden = false
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.05
            animation.repeatCount = 3
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: self.ErrorMessagelabel.center.x - 8, y: self.ErrorMessagelabel.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: self.ErrorMessagelabel.center.x + 8, y: self.ErrorMessagelabel.center.y))
            self.ErrorMessagelabel.layer.add(animation, forKey: "position")
            return
        }
        
        
        //Populate assignment object
        let classTitle = ClassOutlet.titleLabel?.text //ClassTitle
        let indexOfClassID = classNamesArray.index(of: classTitle!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        let classID = classes[indexOfClassID!] //ClassID
        let title = AssignmentTitleOutlet.text! //Title
        let assignmentType = (AssignmentTypeOutlet.titleLabel?.text)! //Assignment Type
        var dueDate : Date? = nil
        if !(DueDateOutlet.titleLabel?.text == "Due Date") {
            dueDate = dateFormatter.date(from: (DueDateOutlet.titleLabel?.text)!)! //Due Date
        }
        let additionalInfo = AdditionalInfoOutlet.text //AdditionalInfo
        
        assignment = Assignment(title: title, classTitle: classTitle!, classID: classID, assignmentType: assignmentType, dueDate: dueDate, additionalInfo: additionalInfo!)
        
        //Database Write
        updateAssignment(assignment: assignment!, assignmentID: self.assignmentID) {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
}
