//
//  ChatConnectivity.swift
//  ChatiOS
//
//  Created by Varun Channi on 23/03/17.
//  Copyright © 2017 Codination. All rights reserved.
//

import Foundation
import XMPPFramework

let hostName = "amrits-macbook-pro.local"

class ChatConnectivity: NSObject, XMPPStreamDelegate, XMPPRoomDelegate {
    
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
        self.xmppStream.hostName = hostName
        
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
        
//        self.xmppRoster.subscribePresence(toUser: XMPPJID(string: "channi@varuns-macbook-pro.local"))
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
    
    func getAllFriends() -> [AnyObject] {
        
        var friends_Arc = [AnyObject]()
        
        if let moc = self.xmppRosterStorage.mainThreadManagedObjectContext {
            
            let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPUserCoreDataStorageObject", in: moc)
            
            let sort1 = NSSortDescriptor(key: "sectionNum", ascending: true)
            let sort2 = NSSortDescriptor(key: "displayName", ascending: true)
            
            let predicateFrmt = "ask == nil"
            let predicate = NSPredicate(format: predicateFrmt)
            
            let request = NSFetchRequest<NSFetchRequestResult>()
            request.sortDescriptors = [sort1, sort2]
            request.predicate = predicate
            request.entity = entityDescription
            
            do {
                friends_Arc = try moc.fetch(request) as [AnyObject]
            } catch {
                print("Unable to fetch message")
            }
        }
        
        for friend in friends_Arc {
            let friendObject = friend as! XMPPUserCoreDataStorageObject
            print(friendObject.nickname)
            print(friendObject.displayName)
            print(friendObject.sectionName)
        }
        
        return friends_Arc
    }
    
    func getChatRooms() {
        
        let serverJID = XMPPJID(string: "conference.\(hostName)")
        let iq = XMPPIQ(type: "get", to: serverJID)
        iq?.addAttribute(withName: "id", stringValue: "chatroom_list")
        iq?.addAttribute(withName: "from", stringValue: xmppStream.myJID.full())
        let query = DDXMLElement(name: "query")
        query.addAttribute(withName: "xmlns", stringValue: "http://jabber.org/protocol/disco#items")
        iq?.addChild(query)
        xmppStream.send(iq)

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
    
    func sendMessageToGroup(_ msg: String, toUser userId: String, completion:@escaping (Bool) -> Void) {
        
        if let range: Range<String.Index> = userId.range(of: "@") {
            let name = userId.substring(to: range.lowerBound)
            let senderJID = XMPPJID(string: "\(name)@conference.\(hostName)")
            let message = XMPPMessage(type: "chat", to: senderJID)
            
            message?.addBody(msg)
            xmppRoom?.send(message)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                completion(true)
            }
        }
    }
    
    func addBuddy(userId: String, groups: [String]) {
        let newBuddy = XMPPJID(string: userId)
        self.xmppRoster.addUser(newBuddy, withNickname: userId, groups: groups, subscribeToPresence: true)
        self.xmppRoster.subscribePresence(toUser: newBuddy)
    }
    
    func createOrJoinChatRoom(_ roomName: String) {
        
        let roomStorage = XMPPRoomMemoryStorage()
        
        let roomJid = XMPPJID(string: "\(roomName)@conference.\(hostName)")
        xmppRoom = XMPPRoom(roomStorage: roomStorage, jid: roomJid, dispatchQueue: DispatchQueue.main)
        xmppRoom?.activate(self.xmppStream)
        xmppRoom?.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppRoom?.join(usingNickname: self.xmppStream.myJID.user, history: nil)
    }
    
    func loadGroupMessageWithJid(jid: String) -> [AnyObject] {
        var messages_arc = [AnyObject]()
        let storage = XMPPMessageArchivingCoreDataStorage.sharedInstance()
        if let moc = storage?.mainThreadManagedObjectContext {
            let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc)
            let request = NSFetchRequest<NSFetchRequestResult>()
            let sort = NSSortDescriptor(key: "timestamp", ascending: true)
            request.sortDescriptors = [sort]
            let fromGroupMessage = "\(xmppRoom?.roomJID.user ?? "")@conference.\(hostName)/\(xmppStream.myJID.user ?? "")"
            let predicateFrmt = "bareJidStr like %@ && NOT (messageStr CONTAINS[cd] %@)"
            let predicate = NSPredicate(format: predicateFrmt, jid, fromGroupMessage)
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
    
    func loadMessageWithJid(jid: String) -> [AnyObject] {
        var messages_arc = [AnyObject]()
        let storage = XMPPMessageArchivingCoreDataStorage.sharedInstance()
        if let moc = storage?.mainThreadManagedObjectContext {
            let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc)
            let request = NSFetchRequest<NSFetchRequestResult>()
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
    
    /*func getAllFriends() -> [AnyObject] {
        var friends_arc = [AnyObject]()
        if let moc = xmppRosterStorage.mainThreadManagedObjectContext {
            let entity = NSEntityDescription.entity(forEntityName: "XMPPUserCoreDataStorageObject", in: moc)
            let sort1 = NSSortDescriptor.init(key: "sectionNum", ascending: true)
            let sort2 = NSSortDescriptor.init(key: "displayName", ascending: true)
            let sortDescriptors = [sort1, sort2]
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            let predicate = NSPredicate(format: "ask==nil")
            fetchRequest.predicate = predicate
            fetchRequest.entity = entity
            fetchRequest.sortDescriptors = sortDescriptors
            do {
                friends_arc = try moc.fetch(fetchRequest) as [AnyObject]
            } catch {
                print("Unable to fetch message")
            }
        }
        return friends_arc
    }*/
    
    //MARK:- Delegate Methods
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {
        sender.send(XMPPPresence())
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let navigation = appDelegate.window?.rootViewController as! UINavigationController
        if navigation.topViewController is BuddyListViewController {
            let blvc = navigation.topViewController as! BuddyListViewController
            blvc.authenticationUpdate(isAuthenticated: true)
        }
    }
    
    func xmppStream(_ sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let navigation = appDelegate.window?.rootViewController as! UINavigationController
        if navigation.topViewController is BuddyListViewController {
            let blvc = navigation.topViewController as! BuddyListViewController
            blvc.authenticationUpdate(isAuthenticated: false)
        }
    }
    
    func xmppStreamDidConnect(_ sender: XMPPStream!) {
        self.isXmppConnected = true
        do {
            try self.xmppStream.authenticate(withPassword: password)
        } catch {
            print("Authentication not successful")
        }
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive presence: XMPPPresence!) {
        let presenceType = presence.type()
        let username = sender.myJID.user
        let presenceFromUser = presence.from().user
        let rosterCoreData = XMPPRosterCoreDataStorage.sharedInstance()
        if let user = rosterCoreData?.user(for: presence.from(), xmppStream: xmppStream, managedObjectContext: xmppRosterStorage.mainThreadManagedObjectContext) {
            if presenceFromUser != username {
                user.update(with: presence, streamBareJidStr: presence.from().bare())
                if presenceType == "unsubscribed" {
                    xmppRoster.removeUser(presence.from())
                }
            }
        }
        if !presence.from().domain.contains("conference") {
            if presenceFromUser != username {
                if presenceType == "available" {
                    chatDelegate.newBuddyOnline(buddyName: "\(String(describing: presenceFromUser!))@\(hostName)")
                } else if presenceType == "unavailable" {
                    chatDelegate.buddyWentOffline(buddyName: "\(String(describing: presenceFromUser!))@\(hostName)")
                }
            }
        }
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive message: XMPPMessage!) {
        print(message)
        
        if message.isChatMessageWithBody() {
            if message.type() == "groupchat" {
                
                let msg = message.elements(forName: "body").first?.stringValue
                let from = message.elements(forName: "from").first?.stringValue
                
                let newMessage: [String : String] = ["msg" : msg!, "sender" : from!]
                messageDelegate.newMessageReceived(messageContent: newMessage)

            } else {
                let msg = message.elements(forName: "body").first?.stringValue
                let from = message.from().user
                let newMessage: [String : String] = ["msg" : msg!, "sender" : from!]
                messageDelegate.newMessageReceived(messageContent: newMessage)
            }
        } else {
            if let type = message.type() {
                if type == "groupchat" {
                    if let deleagte = messageDelegate {
                        if let msg = message.elements(forName: "body").first?.stringValue {
                            let from = message.from().user
                            let newMessage: [String : String] = ["msg" : msg, "sender" : from!]
                            deleagte.newMessageReceived(messageContent: newMessage)
                        }
                    }
                    
                    let arrSplitedVal = message.from().full().components(separatedBy: "/")
                    
                    if arrSplitedVal.count == 2 {
                        let strFrom = arrSplitedVal.last
                        
                        if self.xmppStream.myJID.user != strFrom {
                            if let _ = message.elements(forName: "composing").first?.stringValue {
                                print("is composing")
                            } else if let _ = message.elements(forName: "paused").first?.stringValue {
                                print("is composing")
                            } else if let _ = message.elements(forName: "gone").first?.stringValue {
                                print("is gone")
                            } else if let _ = message.elements(forName: "inactive").first?.stringValue {
                                print("is inactive")
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive iq: XMPPIQ!) -> Bool {
        print(iq.description)
        if iq.elementID() == "chatroom_list" {
            var chatRooms = [String]()
            if let array = iq.elements(forName: "query").first?.elements(forName: "item") {
                for item in array {
                    let name = item.attributeStringValue(forName: "jid")
                    chatRooms.append(name ?? "")
                }
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let navigation = appDelegate.window?.rootViewController as! UINavigationController
                if navigation.topViewController is BuddyListViewController {
                    let blvc = navigation.topViewController as! BuddyListViewController
                    blvc.groups = chatRooms
                }
            }
        }
        return true
    }
    
    //MARK:- Room Delegate Methods
    
    func xmppRoomDidCreate(_ sender: XMPPRoom!) {
        print("Room created \n\(sender)")
        sender.fetchConfigurationForm()
    }
    
    func xmppRoomDidJoin(_ sender: XMPPRoom!) {
        print("I joined room")
    }
    
    func xmppRoom(_ sender: XMPPRoom!, didReceive message: XMPPMessage!, fromOccupant occupantJID: XMPPJID!) {
        print(message)
    }
    
    func xmppRoom(_ sender: XMPPRoom!, didFetchConfigurationForm configForm: DDXMLElement!) {
        print(configForm)
        let newForm = configForm.copy() as! DDXMLElement
        for field in newForm.elements(forName: "field") {
            if let _var = field.attributeStringValue(forName: "var") {
                
                switch _var {
                case "muc#roomconfig_persistentroom":
                    field.remove(forName: "value")
                    field.addChild(DDXMLElement(name: "value", numberValue: 1))
                    
                default:
                    break
                }
            }
        }
        sender.configureRoom(usingOptions: newForm)
    }
}
