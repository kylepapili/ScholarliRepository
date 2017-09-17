//
//  AdminSettingsViewController.swift
//  Scholarli
//
//  Created by Kyle Papili on 9/14/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit

class AdminSettingsViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {

    //Properties
    let adminOptions = ["Edit Classes"]
    let adminOptionImages : [UIImage] = [#imageLiteral(resourceName: "About")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "adminCell") as? AdminTableViewCell else {
            return UITableViewCell()
        }
        cell.ImageView.image = adminOptionImages[indexPath.row]
        cell.Label.text = adminOptions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adminOptions.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Nothing
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            self.performSegue(withIdentifier: "AdminClassEditorSegue", sender: self)
        default:
            break
        }
    }
}
