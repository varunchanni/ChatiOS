//
//  ChatConnectivity.swift
//  ChatiOS
//
//  Created by Varun Channi on 23/03/17.
//  Copyright © 2017 Codination. All rights reserved.
//

import Foundation
import XMPPFramework

private let hostname = "10.175.172.52"

class ChatConnectivity: NSObject, XMPPStreamDelegate {
    
    static let sharedConnectivity = ChatConnectivity()
    
    var xmppStream: XMPPStream!
    
    var xmppRoster: XMPPRoster!
    var xmppRosterStorage = XMPPRosterCoreDataStorage()

    
    var xmppIncomingFileTransfer:XMPPIncomingFileTransfer?
    var xmppvCardStorage:XMPPvCardCoreDataStorage?
    var xmppMUC:XMPPMUC?
    var xmppReconnect:XMPPReconnect?
    var xmppvCardTempModule:XMPPvCardTempModule?
    var xmppMessageDeliveryRecipts:XMPPMessageDeliveryReceipts?
    var xmppvCardAvatarModule:XMPPvCardAvatarModule?
    var xmppCapabilities:XMPPCapabilities?
    var xmppCapabilitiesStorage:XMPPCapabilitiesCoreDataStorage?
    var xmppUserCoreDataStorageObject:XMPPUserCoreDataStorageObject?
    var xmppRoom:XMPPRoom?
    var xmppMessageArchivingStorage:XMPPMessageArchivingCoreDataStorage?
    var xmppMessageArchivingStorageModule:XMPPMessageArchiving?
    var arrayFriendRequest:NSMutableArray?
    var isFriendRequest:Bool = false
    var isLogin: Bool = false
    var isXmppConnected = false
    var allowSelfSignedCertificates = false
    var allowSSLHostNameMismatch = false
    
    var password: String!
    
    var chatDelegate: ChatDelegate!
    var messageDelegate: MessageDelegate!
    
    //MARK:- Private Methods
    
    override init() {
        
    }
    
    private func setupStream () {
        self.xmppStream = XMPPStream()
        
        #if !TARGET_IPHONE_SIMULATOR
            self.xmppStream.enableBackgroundingOnSocket = true;
        #endif
        self.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        self.xmppStream.hostName = hostname
        
        self.xmppMUC = XMPPMUC(dispatchQueue: DispatchQueue.main)
        self.xmppMUC?.activate(xmppStream)
        self.xmppMUC?.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        self.xmppReconnect = XMPPReconnect()
        self.xmppReconnect?.activate(xmppStream)
        
        self.xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
        self.xmppRoster?.autoFetchRoster = true
        self.xmppRoster?.autoAcceptKnownPresenceSubscriptionRequests = true
        self.xmppRoster?.activate(xmppStream)
        self.xmppRoster?.addDelegate(self, delegateQueue: DispatchQueue.main)
        self.xmppRoster?.autoClearAllUsersAndResources = false
        
        self.xmppRosterStorage = XMPPRosterCoreDataStorage(inMemoryStore: ())
        
        self.xmppvCardStorage = XMPPvCardCoreDataStorage.sharedInstance()
        self.xmppvCardTempModule = XMPPvCardTempModule(vCardStorage: xmppvCardStorage)
        self.xmppvCardAvatarModule = XMPPvCardAvatarModule(vCardTempModule: xmppvCardTempModule)
        
        self.xmppCapabilitiesStorage = XMPPCapabilitiesCoreDataStorage.sharedInstance()
        self.xmppCapabilities = XMPPCapabilities(capabilitiesStorage: xmppCapabilitiesStorage)
        self.xmppCapabilities?.autoFetchHashedCapabilities = true;
        self.xmppCapabilities?.autoFetchNonHashedCapabilities = false;
        self.xmppCapabilities?.activate(xmppStream)
        
        self.xmppMessageArchivingStorage = XMPPMessageArchivingCoreDataStorage.sharedInstance()
        self.xmppMessageArchivingStorageModule = XMPPMessageArchiving(messageArchivingStorage: xmppMessageArchivingStorage)
        self.xmppMessageArchivingStorageModule?.clientSideMessageArchivingOnly = true
        self.xmppMessageArchivingStorageModule?.activate(xmppStream)
        
        self.xmppMessageDeliveryRecipts = XMPPMessageDeliveryReceipts.init(dispatchQueue: DispatchQueue.main)
        self.xmppMessageDeliveryRecipts?.autoSendMessageDeliveryReceipts = true
        self.xmppMessageDeliveryRecipts?.autoSendMessageDeliveryRequests = true
        self.xmppMessageDeliveryRecipts?.activate(xmppStream)
        
        self.xmppvCardTempModule?.activate(xmppStream)
        self.xmppvCardAvatarModule?.activate(xmppStream)
        //self.xmppRoster.subscribePresence(toUser: XMPPJID(string: "channi@v\(hostname)"))
        
        allowSelfSignedCertificates = true;
        allowSSLHostNameMismatch    = false;
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
        let myJid = XMPPJID(string:"\(username)@\(hostname)")
        self.xmppStream.myJID = myJid
        self.password = password
        self.xmppStream.hostPort = 5222
        self.xmppStream.hostName = hostname
        self.xmppStream.enableBackgroundingOnSocket = true
        
        do {
            try self.xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
            self.isXmppConnected = true
            completion(true)
        } catch {
            print("Something went wrong")
            self.isXmppConnected = false
            completion(false)
        }
    }
    
    func disconnect() {
        self.goOffline()
        xmppStream.disconnect()
        
    }
    
    func sendMessage(_ msg: String, toUser userId: String, completion:@escaping (Bool) -> Void) {
        
        let senderJID = XMPPJID(string: userId)
        let message = XMPPMessage(type: "chat", to: senderJID)
        
        message?.addBody(msg)
        xmppStream.send(message)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(true)
        }
    }
    
    func addBuddy(userId: String) {
        let newBuddy = XMPPJID(string: userId)
        self.xmppRoster.addUser(newBuddy, withNickname: "channi", groups: ["friends"], subscribeToPresence: true)
    }
    
    //MARK:- Delegate Methods
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {
        sender.send(XMPPPresence())
    }
    
    func xmppStream(_ sender: XMPPStream!, willSecureWithSettings settings: NSMutableDictionary!) {
        let expectedCertName:Any?
        let serverDomain = xmppStream.hostName;
        let virtualDomain = xmppStream.myJID.domain;
        
        if (serverDomain == nil)
        {
            expectedCertName = virtualDomain;
        }
        else
        {
            expectedCertName = serverDomain;
        }
        
        if ((expectedCertName) != nil)
        {
            settings.setObject(expectedCertName ?? "", forKey: kCFStreamSSLPeerName as! NSCopying)
        }
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive trust: SecTrust!, completionHandler: ((Bool) -> Void)!) {
        
    }
    
    func xmppStreamDidSecure(_ sender: XMPPStream!) {
        
    }
    
    func xmppStreamDidRegister(_ sender: XMPPStream!) {
        
    }
    
    func xmppStream(_ sender: XMPPStream!, didNotRegister error: DDXMLElement!) {
        
    }
    
    func xmppStreamDidConnect(_ sender: XMPPStream!) {
        self.isXmppConnected = true
        do {
            try self.xmppStream.authenticate(withPassword: password!)
        } catch {
            print("Authentication not successful")
        }
    }
    
    func xmppStream(_ sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
        print("Authentication not successful")
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive presence: XMPPPresence!) {
        
        let presenceType = presence.type()
        let username = sender.myJID.user
        let presenceFromUser = presence.from().user
        
        if presenceFromUser != username {
            if presenceType == "available" {
                chatDelegate.newBuddyOnline(buddyName: "\(String(describing: presenceFromUser!))@\(hostname)")
            } else if presenceType == "unavailable" {
                chatDelegate.buddyWentOffline(buddyName: "\(String(describing: presenceFromUser!))@\(hostname)")
            }
        }
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive message: XMPPMessage!) {
    
        let msg = String(describing: message.body()!)
        let from = String(describing: message.from()!)
        
        let newMessage: [String : String] = ["msg" : msg, "sender" : from]
        messageDelegate.newMessageReceived(messageContent: newMessage)
    }
    
    func loadMessageWithJid(jid: String) -> [AnyObject] {
        var messages_arc = [AnyObject]()
        let storage = XMPPMessageArchivingCoreDataStorage.sharedInstance()
        if let moc = storage?.mainThreadManagedObjectContext {
            let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc)
            let request = NSFetchRequest<NSFetchRequestResult>()
            //request.fetchLimit = 10
            let sort = NSSortDescriptor(key: "timestamp", ascending: true)
            request.sortDescriptors = [sort]
            let predicateFrmt = "bareJidStr like %@ "
            let predicate = NSPredicate(format: predicateFrmt, jid)
            request.predicate = predicate
            request.entity = entityDescription
            do {
                messages_arc = try moc.fetch(request) as [AnyObject]
            } catch {
                print("Unable to fetch message")
            }
        }
        
        return messages_arc
    }
}
