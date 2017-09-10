//
//  AboutViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 8/2/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit


class AboutViewController: UIViewController {

    //Outlets
    
    @IBOutlet var AboutImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AboutImage.layer.borderWidth = 0
        AboutImage.layer.masksToBounds = false
        AboutImage.layer.borderColor = UIColor.black.cgColor
        AboutImage.layer.cornerRadius = AboutImage.frame.height/2
        AboutImage.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
