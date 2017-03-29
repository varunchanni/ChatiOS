//
//  ChatTableViewCell.swift
//  ChatiOS
//
//  Created by Varun Channi on 28/03/17.
//  Copyright © 2017 Codination. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    var messageObject: Message!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func fillMessage(msg: Message) {
        
        self.messageObject = msg
        message.text = msg.text!
        
        if msg.outgoing {
            leadingConstraint.constant = 80
            trailingConstraint.constant = 5
            message.textAlignment = .right
        } else {
            leadingConstraint.constant = 5
            trailingConstraint.constant = 80
            message.textAlignment = .left
        }
        
        UIView.animate(withDuration: 0.1) { 
            self.contentView.layoutIfNeeded()
        }
    }
    
}
