//
//  SettingsSelectionTableViewCell.swift
//  Scholarly
//
//  Created by Kyle Papili on 7/8/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit

class SettingsSelectionTableViewCell: UITableViewCell {
    //Outlets
    
    @IBOutlet var SelectionOutlet: UILabel!
    @IBOutlet var IconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
