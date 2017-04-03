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
    
    @IBOutlet weak var addBuddyView: UIView!
    @IBOutlet weak var addBuddyButton: UIBarButtonItem!
    @IBOutlet weak var buddyNameField: UITextField!
    @IBOutlet weak var groupNameField: UITextField!
    @IBOutlet weak var segmentChat: UISegmentedControl!
    @IBOutlet weak var buddyNameLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    
    var onlineBuddies: [String] = [String]()
    var allFriends: [AnyObject] = [AnyObject]()
    
    var onlineFriends: [String] = []
    var selectedUserId: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let sharedConnection = ChatConnectivity.sharedConnectivity
        
        if !sharedConnection.isXmppConnected {
            self.performSegue(withIdentifier: "showLoginScreenId", sender: self)
        } else {
            sharedConnection.chatDelegate = self
        }
        
        allFriends = sharedConnection.getAllFriends()
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
    
    @IBAction func segmentBarValueChanged(_ sender: UISegmentedControl) {
        
        var title = "Buddies"
        if sender.selectedSegmentIndex == 1 {
            title = "Chat Roms"
            ChatConnectivity.sharedConnectivity.getChatRooms()
            
            buddyNameLabel.text = "Chat Room"
            groupNameField.isHidden = true
            groupNameLabel.isHidden = true
        } else {
            
            buddyNameLabel.text = "Buddy Name"
            groupNameField.isHidden = false
            groupNameLabel.isHidden = false
        }
        self.title = title
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
    
    @IBAction func showAddBuddyView(_ sender: UIBarButtonItem) {
        
        if self.addBuddyView.alpha == 0.0 {
            self.addBuddyView.isHidden = false
        }
        
        UIView.animate(withDuration: 0.25,
                       animations: { 
                        self.addBuddyView.alpha = self.addBuddyView.alpha == 1.0 ? 0.0 : 1.0
        }) { (success) in
            
            let viewBarButton = self.addBuddyButton.value(forKey: "view") as! UIView
            let imageView = viewBarButton.subviews.first! as! UIImageView
            
            UIView.animate(withDuration: 0.10, animations: {
                if self.addBuddyView.alpha == 1.0 {
                    imageView.contentMode = .center
                    imageView.autoresizingMask = []
                    imageView.clipsToBounds = false
                    imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 4))
                    
                } else {
                    imageView.transform = CGAffineTransform.identity
                    self.addBuddyView.alpha = 0.0
                    self.addBuddyView.isHidden = true
                }
            })
        }
    }
    
    @IBAction func addBuddyButtonAction(_ sender: UIButton) {
        
        let sharedConnection = ChatConnectivity.sharedConnectivity
        if self.segmentChat.selectedSegmentIndex == 0 {
            sharedConnection.addBuddy(userId: self.buddyNameField.text!, groups: [self.groupNameField.text!])
        } else {
            sharedConnection.createChatRoom(buddyNameField.text!)
        }
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
