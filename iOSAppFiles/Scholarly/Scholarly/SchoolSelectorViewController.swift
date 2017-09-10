//
//  SchoolSelectorViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/21/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import Firebase
class SchoolSelectorViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    let ref = Database.database().reference()
    var schools : Array = [""]
    var currentSelection: String = ""
    var varToPass : [[String : Any]]? = nil
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return schools[row] as! String
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return schools.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //Nothing to do yet
        self.currentSelection = schools[row] as! String
    }
    
    
    @IBAction func ContinueAction(_ sender: Any) {
        //Record Users School under user ID
        ref.child("users").child((Auth.auth().currentUser?.uid)!).child("info").child("School").setValue("\(currentSelection)")
        UserDefaults.standard.set(currentSelection, forKey: String(describing: UserDefaultKeys.School))
        //Record Users School under School
        ref.child("SchoolData").child("\(currentSelection)").child("students").child((Auth.auth().currentUser?.uid)!).setValue("TRUE")
        
        //Fetch Class List For Class Selector View
        _ = self.ref.child("SchoolData").child("\(currentSelection)").child("classes").observe(DataEventType.value, with: { (FIRDataSnapshot) in
            
            if let dataDict = FIRDataSnapshot.value as? [String : [String : Any]] {
                let dataArray = Array(dataDict.values)
                self.varToPass = dataArray
                self.performSegue(withIdentifier: "classSelectorSegue", sender: self)
            }
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        let navVC = segue.destination as? UINavigationController
        
        let tableVC = navVC?.viewControllers.first as! ClassSelectorViewController
        
        tableVC.classes = self.varToPass!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.currentSelection = self.schools[0]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
