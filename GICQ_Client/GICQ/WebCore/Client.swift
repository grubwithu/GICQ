//
//  Client.swift
//  GICQ
//
//  Created by Mikhail Jax on 2022/10/11.
//

import Foundation
import CocoaAsyncSocket

class Client: NSObject, GCDAsyncSocketDelegate {
    
    static var _self: Client? = nil
    
    private let msgBegin = Character(UnicodeScalar(2))
    private let msgEnd = Character(UnicodeScalar(3))
    
    private var ip: String = ""
    private var port: UInt16 = 0
    private var message: String = ""
    private var socket: GCDAsyncSocket?
    var connected: Bool = false
    
    var logined = false
    var id : String = ""
    var name : String = ""
    var registerDate : String = ""
    
    static func getInstance() -> Client {
        if _self == nil {
            _self = Client()
        }
        return _self!
    }
    
    private override init() {
        super.init()
        
    }
    
    func createSocket(ip: String, port: UInt16) {
        self.ip = ip
        self.port = port
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.init(label: "SOCKET"))
    }
    
    func connectionEstablish() -> Bool {
        
        do {
             try socket?.connect(toHost: ip, onPort: UInt16(port), withTimeout: 3)
        } catch _ {
            return false
        }
        return true
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        connected = true
        self.socket!.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        message = String(data: data, encoding: .utf8)!
        print(message)
        self.socket!.readData(withTimeout: -1, tag: 0)
    }
    
    private func connectionBreak() {
        if connected {
            socket?.disconnect()
            connected = false
        }
    }
    
    private func sendMessage(message: String) {
        if connected {
            socket?.write(message.data(using: .utf8), withTimeout: -1, tag: 0)
        }
    }
    
    func login(account: String, password: String) -> (success: Bool, errCode: String) {
        sendMessage(message: msgToStr(list: [
            ("LOGIN","LOGIN"),
            ("ACCOUNT",account),
            ("PASSWORD",password)]))
        let later = Date.init(timeIntervalSinceNow: 5)
        while true {
            self.socket!.readData(withTimeout: -1, tag: 0)
            let respon = strToMsg(str: message)
            message = ""
            if later.compare(Date.init()) == .orderedAscending {
                return (false, "Time Out Error")
            }
            if respon.count == 0 {
                continue
            }
            if respon[0].0 != "LOGIN" {
                continue
            }
            switch (respon[0].1) {
            case "SUCCESS":
                logined = true
                return (true, "")
            case "FAILED": return (false, respon[1].1)
            default: continue
            }
        }
    }
    
    func sendChat(id: String, content: String) -> (success: Bool, info: String) {
        sendMessage(message: msgToStr(list: [
            ("CHAT", "SEND"),
            ("ACCOUNT", id),
            ("CONTENT", content)]))
        let later = Date.init(timeIntervalSinceNow: 3)
        while true {
            self.socket!.readData(withTimeout: -1, tag: 0)
            let respon = strToMsg(str: message)
            message = ""
            if later.compare(Date.init()) == .orderedAscending {
                return (false, "Time Error")
            }
            if respon.count == 0 {
                continue
            }
            if respon[0].0 != "CHAT" {
                continue
            }
            switch (respon[0].1) {
            case "SUCCESS":
                return (true, respon[1].1)
            case "FAILED":
                return (false, respon[1].1)
            default: continue
            }
        }
    }
    
    func register(id: String, pwd: String, name: String) -> (success: Bool, errCode: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: Date())
        sendMessage(message: msgToStr(list: [
            ("REGISTER", "REGISTER"),
            ("ACCOUNT", id),
            ("PASSWORD", pwd),
            ("NAME", name),
            ("TIME", myString)]))
        let later = Date.init(timeIntervalSinceNow: 3)
        while true {
            self.socket!.readData(withTimeout: -1, tag: 0)
            let respon = strToMsg(str: message)
            message = ""
            if later.compare(Date.init()) == .orderedAscending {
                return (false, "Time Out Error")
            }
            if respon.count == 0 {
                continue
            }
            if respon[0].0 != "REGISTER" {
                continue
            }
            switch (respon[0].1) {
            case "SUCCESS":
                return (true, "")
            case "FAILED":
                return (false, respon[1].1)
            default: continue
            }
        }
    }
    
    func getChat(chats: Chats) -> (success: Bool, errCode: String) {
        sendMessage(message: msgToStr(list: [
            ("GETCHAT", "GETCHAT")]))
        let later = Date.init(timeIntervalSinceNow: 3)
        while true {
            self.socket!.readData(withTimeout: -1, tag: 0)
            let respon = strToMsg(str: message)
            message = ""
            if later.compare(Date.init()) == .orderedAscending {
                return (false, "Time Out Error")
            }
            if respon.count == 0 {
                continue
            }
            if respon[0].0 != "GETCHAT" {
                continue
            }
            switch (respon[0].1) {
            case "RETURN":
                let num = Int(respon[1].1)!
                if num * 3 + 2 != respon.count {
                    return (false, "Other Error")
                }
                if num != 0 {
                    for i in 0...num-1 {
                        let id = respon[2 + i * 3].1
                        var exist : Bool = false
                        for chat in chats.data {
                            if chat.someoneID == id {
                                chat.messages.append(MessageItem(body: NSString(string: respon[4 + i * 3].1), logo: "1234", date: NSDate(), mtype: .Someone))
                                exist = true
                                break
                            }
                        }
                        if !exist {
                            chats.data.append(ChatInfo(someoneID: id, someoneName: respon[3 + i * 3].1, messages: [MessageItem(body: NSString(string: respon[4 + i * 3].1), logo: "1234", date: NSDate(), mtype: .Someone)]))
                        }
                    }
                }
                return (true, "")
            case "FAILED":
                return (false, respon[1].1)
            default: continue
            }
        }
        
    }
    
//    func login() -> Bool {
//        let respon = strToMsg(str: message)
//        if respon.count == 0 {
//            return false
//        }
//        if respon[0].0 != "LOGIN" {
//            return false
//        }
//        switch (respon[0].1) {
//        case "SUCCESS":
//            getUserInfo()
//            return true
//        case "FAILED": return false
//        default: return false
//        }
//    }
    
    func getUserInfo() -> (success: Bool, errCode: String) {
        sendMessage(message: msgToStr(list: [
            ("USERINFO", "GET")]))
        let later = Date.init(timeIntervalSinceNow: 3)
        while true {
            self.socket!.readData(withTimeout: -1, tag: 0)
            let respon = strToMsg(str: message)
            message = ""
            if later.compare(Date.init()) == .orderedAscending {
                return (false, "Time Out Error")
            }
            if respon.count == 0 {
                continue
            }
            if respon[0].0 != "USERINFO" || respon[0].1 != "RETURN" || respon.count != 4{
                return (false, "Other Error")
            }
            id = respon[1].1
            name = respon[2].1
            registerDate = respon[3].1
            return (true, "")
        }
    }
    
    private func msgToStr(list: [(String, String)]) -> String {
        var ans = String()
        for (head, tail) in list {
            ans.append("\\")
            ans.append(head)
            ans.append(msgBegin)
            ans.append(tail)
            ans.append(msgEnd)
        }
        return ans
    }
    
    private func strToMsg(str: String) -> [(String, String)] {
        if str == "" {
            return []
        }
        var index = str.startIndex
        var ans: [(String, String)] = []
        while index != str.endIndex {
            if str[index] == "\0" {
                break
            }
            assert(str[index] == "\\")
            var head = ""
            index = str.index(after: index)
            while str[index] != msgBegin {
                head.append(str[index])
                index = str.index(after: index)
            }
            var content = ""
            index = str.index(after: index)
            while str[index] != msgEnd {
                content.append(str[index])
                index = str.index(after: index)
            }
            index = str.index(after: index)
            ans.append((head, content))
        }
        return ans
    }
}
