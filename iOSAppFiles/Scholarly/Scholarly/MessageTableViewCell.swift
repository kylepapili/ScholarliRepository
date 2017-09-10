//
//  MessageTableViewCell.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/24/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet var ClassNameText: UILabel!
    @IBOutlet var LastMessageText: UILabel!
    @IBOutlet var DateText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
