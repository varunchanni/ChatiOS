//
//  ChatDelegate.swift
//  ChatiOS
//
//  Created by Varun Channi on 28/03/17.
//  Copyright © 2017 Codination. All rights reserved.
//

import Foundation

protocol ChatDelegate {
    
    func newBuddyOnline(buddyName: String)
    func buddyWentOffline(buddyName: String)
//    func didDisconnect()
}
