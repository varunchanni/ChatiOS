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
    @IBOutlet weak var imageBackground: UIImageView!
    
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

    func setImageSize(forOutgoing: Bool, messageStr: String) {
        
        let size = (messageStr as NSString).boundingRect(with: CGSize(width: self.message.frame.size.width, height: 200), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17)], context: nil)
        
        var x: CGFloat = 0
        let y: CGFloat = 0
        let width = size.width + 10
        let height: CGFloat = 30.0
        let edgeInsets = UIEdgeInsetsMake(12, 12, 12, 12)
        
        var imageName = ""
        
        if forOutgoing {
            x = self.message.frame.maxX - width + 5
            imageName = "myBubble"
        } else {
            x = self.message.frame.minX - 5
            imageName = "userBubble"
        }
        
        self.imageBackground.frame = CGRect(x: x, y: y, width: width, height: height)
        self.imageBackground.image = UIImage(named: imageName)?.resizableImage(withCapInsets: edgeInsets, resizingMode: .stretch)
    }
    
    func fillMessage(msg: Message) {
        
        self.messageObject = msg
        message.text = msg.text!
        
        if msg.outgoing {
            leadingConstraint.constant = 80
            trailingConstraint.constant = 15
            message.textAlignment = .right
        } else {
            leadingConstraint.constant = 15
            trailingConstraint.constant = 80
            message.textAlignment = .left
        }
        
        UIView.animate(withDuration: 0.05, animations: { 
            self.contentView.layoutIfNeeded()
        }) { (success) in
            self.setImageSize(forOutgoing: msg.outgoing, messageStr: msg.text!)
        }
    }
    
}
