//
//  Message.swift
//  ChatiOS
//
//  Created by Varun Channi on 29/03/17.
//  Copyright © 2017 Codination. All rights reserved.
//

import Foundation

class Message {
    var jid: String!
    var outgoing: Bool!
    var text: String!
    var timeStamp: Date!
    
    func initMessage(fromObject msgObj: AnyObject) {
        
        self.jid = msgObj.value(forKey: "bareJidStr")! as! String
        self.outgoing = msgObj.value(forKey: "outgoing")! as! Bool
        self.text = msgObj.value(forKey: "body")! as! String
        self.timeStamp = msgObj.value(forKey: "timestamp")! as! Date
    }
}
