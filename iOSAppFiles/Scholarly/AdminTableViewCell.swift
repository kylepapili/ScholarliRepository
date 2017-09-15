//
//  AdminTableViewCell.swift
//  Scholarli
//
//  Created by Kyle Papili on 9/14/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit

class AdminTableViewCell: UITableViewCell {

    //Outlets
    @IBOutlet var ImageView: UIImageView!
    @IBOutlet var Label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
