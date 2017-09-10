//
//  InfoTableViewCell.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/29/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {
    
    @IBOutlet var ProfilePictureOutlet: UIImageView!
    @IBOutlet var StudentNameOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
