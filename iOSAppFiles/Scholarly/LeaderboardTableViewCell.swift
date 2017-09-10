//
//  LeaderboardTableViewCell.swift
//  Scholarly
//
//  Created by Kyle Papili on 7/16/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    @IBOutlet var ProfileImage: UIImageView!
    @IBOutlet var UserNameLabel: UILabel!
    @IBOutlet var ScoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if let image = UIImage(named: "DefaultProfilePicture") {
            ProfileImage.image = image
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
