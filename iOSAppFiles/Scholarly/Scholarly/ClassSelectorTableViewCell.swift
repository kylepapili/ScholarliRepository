//
//  ClassSelectorTableViewCell.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/21/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit

class ClassSelectorTableViewCell: UITableViewCell {
    //MARK: - First Time Setup Outlets
    @IBOutlet var CourseText: UILabel!
    @IBOutlet var TeacherText: UILabel!
    @IBOutlet var PeriodText: UILabel!
    @IBOutlet var ClassIDText: UILabel!
    
    
    //MARK: - Profile View Outlets
    @IBOutlet var ProfileClassLabel: UILabel!
    @IBOutlet var ProfileTeacherLabel: UILabel!
    @IBOutlet var ProfilePeriodLabel: UILabel!
    @IBOutlet var ProfileClassIDLabel: UILabel!
    
    //MARK: - Admin View Outlets
    @IBOutlet var AdminClassLabel: UILabel!
    @IBOutlet var AdminTeacherLabel: UILabel!
    @IBOutlet var AdminPeriodLabel: UILabel!
    @IBOutlet var AdminClassIDLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
