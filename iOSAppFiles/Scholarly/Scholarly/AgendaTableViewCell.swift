//
//  AgendaTableViewCell.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/29/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit

class AgendaTableViewCell: UITableViewCell {
    //Observers
    @IBOutlet var AssignmentTitleOutlet: UILabel!
    @IBOutlet var ClassTitleOutlet: UILabel!
    @IBOutlet var DueDateOutlet: UILabel!
    @IBOutlet var AssignmentTypeOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
