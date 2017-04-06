//
//  ChatViewController.swift
//  ChatiOS
//
//  Created by Varun Channi on 28/03/17.
//  Copyright © 2017 Codination. All rights reserved.
//

import UIKit
import XMPPFramework

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MessageDelegate {

    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var messageField: UITextField!
    var isGroup = false
    var chatUserId: String!
    var chatMessages: [Message] = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let range: Range<String.Index> = chatUserId.range(of: "@") {
            self.title = chatUserId.substring(to: range.lowerBound)
        }
        
        ChatConnectivity.sharedConnectivity.messageDelegate = self
        self.getAllMessages()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addGroupMember))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.chatMessages.count > 0 {
            self.chatTable.scrollToRow(at: IndexPath(row: self.chatMessages.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAllMessages () {
        chatMessages.removeAll()
        let chatUser = isGroup ? "\(self.title ?? "")@conference.\(hostName)" : "\(self.title ?? "")@\(hostName)"
        let messages = isGroup ? ChatConnectivity.sharedConnectivity.loadGroupMessageWithJid(jid: chatUser) : ChatConnectivity.sharedConnectivity.loadMessageWithJid(jid: chatUser)
        for message in messages {
            let chatMessage = Message()
            chatMessage.initMessage(fromObject: message)
            chatMessages.append(chatMessage)
        }
        DispatchQueue.main.async {
            self.chatTable.reloadData()
            if self.chatMessages.count > 0 {
                self.chatTable.scrollToRow(at: IndexPath(row: self.chatMessages.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    @IBAction func sendMessageAction(_ sender: Any) {
        if isGroup {
            ChatConnectivity.sharedConnectivity.sendMessageToGroup(messageField.text!, toUser: chatUserId, completion: { (sucess) in
                self.messageField.text = ""
                self.getAllMessages()
            })
        } else {
            ChatConnectivity.sharedConnectivity.sendMessage(messageField.text!, toUser: chatUserId) { (success) in
                self.messageField.text = ""
                self.getAllMessages()
            }

        }
    }
    
    func addGroupMember() {
        let alertController = UIAlertController.init(title: "Add User", message: "", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        let action = UIAlertAction.init(title: "Ok", style: .default) { (action) in
            if ((alertController.textFields?.count)! > 0) {
                let jid = XMPPJID(string: "\(alertController.textFields![0].text!)@\(hostName)")
                ChatConnectivity.sharedConnectivity.xmppRoom?.inviteUsers([jid!], withMessage: "Please join the room")
            }
        }
        alertController.addAction(action)
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }

    func newMessageReceived(messageContent: [String : String]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.getAllMessages()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell") as! ChatTableViewCell
        cell.isGroup = isGroup
        cell.fillMessage(msg: self.chatMessages[indexPath.row])
        return cell
    }

}
