//
//  ChatConnectivity.swift
//  ChatiOS
//
//  Created by Varun Channi on 23/03/17.
//  Copyright © 2017 Codination. All rights reserved.
//

import Foundation
import XMPPFramework

class ChatConnectivity: NSObject {
    
    static let sharedConnectivity = ChatConnectivity()
    
    var xmppStream: XMPPStream!
    var isOpen: Bool!
    var password: String!
    
    //MARK:- Private Methods
    
    override init() {
        
    }
    
    private func setupStream () {
        self.xmppStream = XMPPStream()
        self.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        self.xmppStream.hostName = "varuns-macbook-pro.local"
    }
    
    func goOnline() {
        let presence = XMPPPresence()
        self.xmppStream.send(presence)
    }
    
    func goOffline() {
        let presence = XMPPPresence(type: "unavailable")
        self.xmppStream.send(presence)
    }
    
    func connect(withUsername username: String, andPassword password: String, completion: (_ success: Bool) -> Void) {
        
        self.setupStream()
        
        if xmppStream.isConnected() {
            completion(true)
        }
        
        self.xmppStream.myJID = XMPPJID(string: username)
        self.password = password
        self.xmppStream.hostPort = 5222
        self.xmppStream.enableBackgroundingOnSocket = true
        
        do {
            try self.xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
            isOpen = true
            completion(true)
        } catch {
            print("Something went wrong")
            isOpen = false
            completion(false)
        }
    }
    
    func disconnect() {
        self.goOffline()
        xmppStream.disconnect()
        
    }
    
    func xmppStreamDidConnect(sender: XMPPStream) {
        isOpen = true
        do {
            try self.xmppStream.authenticate(withPassword: password)
        } catch {
            print("Authentication not successful")
        }
    }
    
    func xmppDidAuthenticate(sender: XMPPStream) {
        self.goOnline()
    }
    
    func xmppStreamDidAuthenticate(sender: XMPPStream) {
        self.goOnline()
    }
}
