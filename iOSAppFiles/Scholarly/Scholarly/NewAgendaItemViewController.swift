//
//  NewAgendaItemViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/30/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit

class NewAgendaItemViewController: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource , UITextViewDelegate {
    //Outlets
    @IBOutlet var AssignmentTitleTextField: UITextField!
    @IBOutlet var AdditionalInfoTextView: UITextView!
    @IBOutlet var ClassOutlet: UIButton!
    @IBOutlet var PickerViewOutlet: UIPickerView!
    @IBOutlet var DatePicker: UIDatePicker!
    @IBOutlet var AssignmentTypeOutlet: UIButton!
    @IBOutlet var DueDateOutlet: UIButton!
    @IBOutlet var AdditionalInfoOutlet: UITextView!
    @IBOutlet var ErrorMessagelabel: UILabel!
    
    //Variables
    var assignment : Assignment? = nil
    var pickerSelection : String = ""
    let classes = UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.Classes) as String) as! [String]
    var classNamesArray = [""]
    //Selector Enum
    enum selectorOption {
        case classSelection , assignmentType , dueDate , nothing
    }
    var currentSelection : selectorOption = .nothing
    
    //Assignment Types Array
    let assignmentTypes = ["Homework", "Essay", "Test", "Quiz", "Project"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Load ClassNamesArray
        ArrayOfClassesFor(arrayOfClassIDs: classes) { (classNamesArray) in
            self.classNamesArray = classNamesArray
        }
        //View Configuration
        PickerViewOutlet.isHidden = true
        DatePicker.isHidden = true
        DatePicker.datePickerMode = .date
        ErrorMessagelabel.isHidden = true
        
    }
    
    //Picker View Functions
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch currentSelection {
        case .classSelection:
            //Return Classes
            return classNamesArray[row]
            break
        case .assignmentType:
            //Return Assignment Type
            return assignmentTypes[row]
            break
        case .dueDate:
            //Return Date Selector (should never happen)
            return ""
            break
        case .nothing:
            return ""
            break        }
    }
    
    @IBAction func DateSelectionChanged(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        dateFormatter.dateFormat = "MM-dd-yyyy"
        DueDateOutlet.setTitle(dateFormatter.string(from: DatePicker.date), for: .normal)
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
        switch currentSelection {
        case .classSelection:
            //Return Classes
            return 1
            break
        case .assignmentType:
            //Return Assignment Type
            return 1
            break
        case .dueDate:
            //Return Date Selector (should never run)
            return 1
            break
        case .nothing:
            return 1
            break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch currentSelection {
        case .assignmentType:
            return assignmentTypes.count
            break
        case .classSelection:
            let classes = UserDefaults.standard.value(forKey: String(describing: UserDefaultKeys.Classes) as String) as! [String]
            return classes.count
            break
        case .dueDate:
            return 1
            break
        case .nothing:
            return 1
            break
        }
    }
    
    //IBActions
    @IBAction func ClassSelectorAction(_ sender: Any) {
        self.view.endEditing(true)
        PickerViewOutlet.reloadAllComponents()
        AssignmentChange()
        currentSelection = .classSelection
        DatePicker.isHidden = true
        PickerViewOutlet.isHidden = false
        PickerViewOutlet.reloadAllComponents()
        PickerViewOutlet.selectRow(0, inComponent: 0, animated: false)
        if ClassOutlet.titleLabel?.text == "Class" {
            PickerViewOutlet.selectRow(0, inComponent: 0, animated: false)
        } else {
//            let classTitle = assignment?.classTitle
//            let rollToScrollTo = classNamesArray.index(of: classTitle!)
//            PickerViewOutlet.selectRow(rollToScrollTo!, inComponent: 0, animated: false)
            PickerViewOutlet.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    @IBAction func AssignmentTypeAction(_ sender: Any) {
        self.view.endEditing(true)
        PickerViewOutlet.reloadAllComponents()
        AssignmentChange()
        currentSelection = .assignmentType
        DatePicker.isHidden = true
        PickerViewOutlet.isHidden = false
        PickerViewOutlet.reloadAllComponents()
        if AssignmentTypeOutlet.titleLabel?.text == "Assignment Type" {
            PickerViewOutlet.selectRow(0, inComponent: 0, animated: false)
        } else {
            //            let classTitle = assignment?.classTitle
            //            let rollToScrollTo = classNamesArray.index(of: classTitle!)
            //            PickerViewOutlet.selectRow(rollToScrollTo!, inComponent: 0, animated: false)
            PickerViewOutlet.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    @IBAction func DueDateSelectorAction(_ sender: Any) {
        self.view.endEditing(true)
        AssignmentChange()
        currentSelection = .dueDate
        DatePicker.isHidden = false
        PickerViewOutlet.isHidden = true
        PickerViewOutlet.reloadAllComponents()
        DatePicker.datePickerMode = .date
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        AssignmentChange()
        currentSelection = .nothing
        DatePicker.isHidden = true
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
        DatePicker.isHidden = true
        PickerViewOutlet.isHidden = true
        currentSelection = .nothing
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
            assignment?.dueDate = DatePicker.date
            dateFormatter.dateFormat = "MM-dd-yyyy"
            DueDateOutlet.setTitle( dateFormatter.string(from: DatePicker.date) , for: .normal)
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
        if AssignmentTitleTextField.text == nil || AssignmentTitleTextField.text == "" {
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
        let title = AssignmentTitleTextField.text! //Title
        let assignmentType = (AssignmentTypeOutlet.titleLabel?.text)! //Assignment Type
        var dueDate : Date? = nil
        if !(DueDateOutlet.titleLabel?.text == "Due Date") {
            dueDate = dateFormatter.date(from: (DueDateOutlet.titleLabel?.text)!)! //Due Date
        }
        let additionalInfo = AdditionalInfoOutlet.text //AdditionalInfo
        
        assignment = Assignment(title: title, classTitle: classTitle!, classID: classID, assignmentType: assignmentType, dueDate: dueDate, additionalInfo: additionalInfo!)
        
        //Database Write
        postAssignment(assignment: assignment!) {
            //Finished writing need to go back to first VC
            lytAgendaItemAdded()
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    
}
