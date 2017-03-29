//
//  BuddyListViewController.swift
//  ChatiOS
//
//  Created by Varun Channi on 23/03/17.
//  Copyright © 2017 Codination. All rights reserved.
//

import UIKit

class BuddyListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChatDelegate {

    @IBOutlet weak var buddyTableView: UITableView!
    var onlineBuddies: [String] = [String]()
    
    var onlineFriends: [String] = []
    var selectedUserId: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !ChatConnectivity.sharedConnectivity.isXmppConnected {
            self.performSegue(withIdentifier: "showLoginScreenId", sender: self)
        } else {
            ChatConnectivity.sharedConnectivity.chatDelegate = self
            self.getAllUsers()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = self.buddyTableView.indexPathForSelectedRow {
            self.buddyTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ChatViewStoryboardID" {
            let chatViewController = segue.destination as! ChatViewController
            chatViewController.chatUserId = self.selectedUserId
        }
    }
    
    func getAllUsers() {
        
    }
    
    //MARK:- Chat Delegates
    
    func newBuddyOnline(buddyName: String) {
        onlineBuddies.append(buddyName)
        self.buddyTableView.reloadData()
    }
    
    func buddyWentOffline(buddyName: String) {
        print("To be removed: \(buddyName)")
    }
    
    //MARK:- TableView Delegate & DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return onlineBuddies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCellID")
        let userLabel: UILabel = cell?.contentView.viewWithTag(10) as! UILabel
        userLabel.text = self.onlineBuddies[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedUserId = onlineBuddies[indexPath.row]
        self.performSegue(withIdentifier: "ChatViewStoryboardID", sender: self)
    }
}
