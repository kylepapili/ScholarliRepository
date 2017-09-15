//
//  ChatMessageTableViewCell.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/27/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


protocol ChatMessageTableViewCellDelegator {
    func callSegueFromCell(message: Message)
}


class ChatMessageTableViewCell: UITableViewCell {
    
    
    @IBOutlet var MessageText: UITextView!
    @IBOutlet var UserNameOutlet: UITextView!
    @IBOutlet var ProfileImage: UIImageView!
    @IBOutlet var LikeButton: UIButton!
    @IBOutlet var FlagButton: UIButton!
    
    var message : Message = Message()
    var delegate : ChatMessageTableViewCellDelegator?

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func awakeFromNib() {
        if let image = UIImage(named: "DefaultProfilePicture") {
            ProfileImage.image = image
        }
        if message.flagged {
            FlagButton.setImage(#imageLiteral(resourceName: "FilledFlag"), for: .normal)
        } else {
            FlagButton.setImage(#imageLiteral(resourceName: "EmptyFlag"), for: .normal)
        }
    }
    
    func PrepareCellForDisplay() {
        self.MessageText.text = self.message.message
        
        self.MessageText.sizeToFit()
        
        self.MessageText.isEditable = false
        
        self.MessageText.dataDetectorTypes = UIDataDetectorTypes.all;
        
        self.MessageText.textContainerInset = UIEdgeInsets.zero
        
        self.UserNameOutlet.text = "\(self.message.userFirstName) \(self.message.userLastName)"
        
        self.UserNameOutlet.isEditable = false
        
        self.UserNameOutlet.textContainerInset = UIEdgeInsets.zero
        
        if self.message.liked {
            self.LikeButton.setImage(#imageLiteral(resourceName: "RedHeart"), for: .normal)
        } else {
            self.LikeButton.setImage(#imageLiteral(resourceName: "GrayHeart"), for: .normal)
        }
    }
    
    
    @IBAction func Flagged(_ sender: Any) {
        if(self.delegate != nil){
            self.delegate?.callSegueFromCell(message: message)
        }
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
