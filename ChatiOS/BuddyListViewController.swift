//
//  BuddyListViewController.swift
//  ChatiOS
//
//  Created by Varun Channi on 23/03/17.
//  Copyright © 2017 Codination. All rights reserved.
//

import UIKit

class BuddyListViewController: UIViewController {

    @IBOutlet weak var buddyTableView: UITableView!
    
    var onlineFriends: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if !ChatConnectivity.sharedConnectivity.isOpen {
            self.performSegue(withIdentifier: "showLoginScreenId", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
