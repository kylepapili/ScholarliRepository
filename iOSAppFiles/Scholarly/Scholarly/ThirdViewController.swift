//
//  ThirdViewController.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/24/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {

    var leaderboardData = [UserDisplayData]()
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        latestLeaderboard { (result) in
            print("BIG RESULT: \(result)")
            lytLeaderBoardChecked()
            self.leaderboardData = result
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if leaderboardData.count > 0 {
            if leaderboardData.count > 10 {
                return 10
            } else {
                return leaderboardData.count
            }
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LeaderboardTableViewCell
        
        if leaderboardData.count > 0 {
            cell.ScoreLabel.text = "\(leaderboardData[indexPath.row].score) Points"
            cell.UserNameLabel.text = "\(indexPath.row + 1). \(leaderboardData[indexPath.row].userFullName)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
