//
//  ChatImageTableViewCell.swift
//  Scholarly
//
//  Created by Kyle Papili on 7/10/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import Firebase

class ChatImageTableViewCell: UITableViewCell {

    //Outlets
    @IBOutlet var UserNameOutlet: UILabel!
    @IBOutlet var ImageViewOutlet: UIImageView!
    @IBOutlet var LikeButton: UIButton!
    @IBOutlet var ProfileImage: UIImageView!
    @IBOutlet var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var FlagButton: UIButton!
    
    //Variables
    var message : Message = Message()
    
    override func awakeFromNib() {
        if let image = UIImage(named: "DefaultProfilePicture") {
            ProfileImage.image = image
        }
        ActivityIndicator.startAnimating()
        ActivityIndicator.isHidden = false
        ActivityIndicator.layer.zPosition = 1
    }
    
    
    @IBAction func Liked(_ sender: Any) {
        
        if (self.message.uid == Auth.auth().currentUser?.uid) {
            //Cannot like your own message
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 3
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: self.LikeButton.center.x - 8, y: self.LikeButton.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: self.LikeButton.center.x + 8, y: self.LikeButton.center.y))
            self.LikeButton.layer.add(animation, forKey: "position")
        } else {
            checkMessageForLike(id: message.messageID, classID: message.classID!) { (isLiked) in
                if (!(isLiked)) {
                    print("LIKED")
                    //Post was NOT already liked, LIKE IT
                    if let image = UIImage(named: "RedHeart") {
                        self.LikeButton.setImage(image, for: .normal)
                        likeMessage(id: self.message.messageID, classID: self.message.classID!, uid: self.message.uid)
                    }
                } else {
                    if let image = UIImage(named: "GrayHeart") {
                        
                        print("UNLIKED")
                        self.LikeButton.setImage(image, for: .normal)
                        dislikeMessage(id: self.message.messageID, classID: self.message.classID!, uid: self.message.uid)
                    }
                }
            }
        }
    }

}
