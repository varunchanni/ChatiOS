//
//  MessageDelegate.swift
//  ChatiOS
//
//  Created by Varun Channi on 28/03/17.
//  Copyright © 2017 Codination. All rights reserved.
//

import Foundation

protocol MessageDelegate {
    func newMessageReceived(messageContent: [String : String])
}
