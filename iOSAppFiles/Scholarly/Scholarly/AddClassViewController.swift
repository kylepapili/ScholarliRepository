//
//  AddClassViewController.swift
//  Scholarli
//
//  Created by Kyle Papili on 8/16/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit

class AddClassViewController: UIViewController , UITextFieldDelegate , UIPickerViewDelegate , UIPickerViewDataSource{
    
    //Outlets
    @IBOutlet var ExplanationText: UILabel!
    @IBOutlet var ClassNameText: UITextField!
    @IBOutlet var TeacherLastNameText: UITextField!
    @IBOutlet var TeacherTitleButton: UIButton!
    @IBOutlet var PeriodButton: UIButton!
    @IBOutlet var PickerView: UIPickerView!
    
    
    //Properties
    var currentSelection : Selection = .None
    var explanations : Explanations = Explanations()
    var Titles : Array = ["Mr.", "Mrs.", "Ms.", "Dr.", "Sra.", "Sr.", "Srta."]
    var Periods : Array = ["1", "2", "3", "4", "5", "6", "7", "8"]
    var PickerViewDataSource : Array = [""]
    var currentPeriod : String? = nil
    var currentTitle : String? = nil
    var sender : String? = nil
    
    //Structs / Enums
    struct Explanations {
        var ClassName = "Include level and official course title as printed on schedule.\n(e.g: HN U.S. History 2, IB Physics 1"
        var TeacherLastName = "Do NOT include the teacher title, only include  teacher's last name.\n(e.g: Johnson, Racz, Teitelbaum)"
        var TeacherTitle = "Select From the List of Available Options"
        var Period = "Select From the List of Available Options"
    }
    enum Selection {
        case ClassName, TeacherLastName, TeacherTitle, Period , None
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PickerView.isHidden = true
    }
    
    //Picker View Functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if PickerViewDataSource.count > 0 {
            return PickerViewDataSource.count
        } else {
            return 1
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if PickerViewDataSource.count > 0 {
            return PickerViewDataSource[row]
        } else {
            return "Error"
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch currentSelection {
        case .TeacherTitle:
            TeacherTitleButton.setTitle("Teacher Title: \(PickerViewDataSource[row])", for: .normal)
            currentTitle = PickerViewDataSource[row]
        case .Period:
            PeriodButton.setTitle("Period: \(PickerViewDataSource[row])", for: .normal)
            currentPeriod = PickerViewDataSource[row]
        default:
            break
        }
    }
    
    //Actions
    func textFieldDidBeginEditing(_ textField: UITextField) {
        PickerView.isHidden = true
        switch textField {
        case ClassNameText:
            currentSelection = .ClassName
            ExplanationText.text = explanations.ClassName
        case TeacherLastNameText:
            currentSelection = .TeacherLastName
            ExplanationText.text = explanations.TeacherLastName
        default: break
            //Nothing
        }
    }
    
    @IBAction func TeacherTitle(_ sender: Any) {
        self.view.endEditing(true)
        currentSelection = .TeacherTitle
        PickerViewDataSource = Titles
        PickerView.reloadAllComponents()
        PickerView.isHidden = false
        ExplanationText.text = explanations.TeacherTitle
    }
    
    
    @IBAction func Period(_ sender: Any) {
        self.view.endEditing(true)
        currentSelection = .Period
        PickerViewDataSource = Periods
        PickerView.reloadAllComponents()
        PickerView.isHidden = false
        ExplanationText.text = explanations.Period
    }
    
    
    //Add Class Action
    @IBAction func AddClass(_ sender: Any) {
        if ClassNameText.text != "" && ClassNameText.text != nil && TeacherLastNameText.text != "" && TeacherLastNameText.text != nil && TeacherTitleButton.titleLabel?.text != "Teacher Title" && PeriodButton.titleLabel?.text != "Period" && currentPeriod != nil && currentTitle != nil{
            //Values Filled in. Class can be added
            let ClassName = ClassNameText.text
            let TeacherLastName = TeacherLastNameText.text
            
            addClass(ClassName: ClassName!, TeacherLastName: TeacherLastName!, TeacherTitle: currentTitle!, Period: currentPeriod!, completion: {
                let alert = UIAlertController(title: "Class Added", message: "Thank you for your contribution. Your class has been added!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: { (alertAction) in
                    //Return to ClassSelector or to class editor
                    if self.sender != "editor" {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            })
            
        } else {
            ExplanationText.text = "All Fields must be completed"
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 3
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: self.ExplanationText.center.x - 8, y: self.ExplanationText.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: self.ExplanationText.center.x + 8, y: self.ExplanationText.center.y))
            self.ExplanationText.layer.add(animation, forKey: "position")
        }
    }
    
    
    
}
