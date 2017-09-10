//
//  ImageDisplayViewController.swift
//  Scholarli
//
//  Created by Kyle Papili on 8/9/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit

class ImageDisplayViewController: UIViewController , UIScrollViewDelegate {

    @IBOutlet var ImageView: UIImageView!
    @IBOutlet var SavedLabel: UILabel!
    @IBOutlet var LabelView: UIView!
    @IBOutlet var ScrollView: UIScrollView!
    
    var image : UIImage = UIImage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ImageView.image = image
        self.LabelView.isHidden = true
        
        self.ScrollView.minimumZoomScale=1.0
        self.ScrollView.maximumZoomScale=6.0
        self.ScrollView.contentSize=self.ImageView.intrinsicContentSize
        self.ScrollView.delegate = self
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.ImageView
    }

    @IBAction func SaveAction(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        self.completedSave()
    }
    
    func completedSave() {
        print("Saved successfully")
        self.LabelView.isHidden = false
        let animationDuration = 0.25
        let delay : TimeInterval = 2.5
        let noDelay : TimeInterval = 0
        
        // Fade in the view
        UIView.animate(withDuration: animationDuration, delay: noDelay, options: .curveEaseOut, animations: { () -> Void in
            self.LabelView.alpha = CGFloat(1)
        }) { (Bool) -> Void in
            
            // After the animation completes, fade out the view after a delay
            
            UIView.animate(withDuration: animationDuration, delay: delay, options: .curveEaseOut, animations: { () -> Void in
                self.LabelView.alpha = CGFloat(0)
            },completion: nil)
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
