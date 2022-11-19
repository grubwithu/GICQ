//
//  ChatInfo.swift
//  GICQ
//
//  Created by Mikhail Jax on 2022/11/3.
//

import Foundation
import UIKit

class ChatInfo : ChatDataSource {
    var messages : [MessageItem] = []
    var someoneName : String
    var someoneID : String
    
    
    init(someoneID: String, someoneName: String, messages: [MessageItem]) {
        self.someoneID = someoneID
        self.messages = messages
        self.someoneName = someoneName
    }
    
    func latestMessage() -> MessageItem {
        return messages[messages.count - 1]
    }
    
    func rowsForChatTable(tableView: TableView) -> Int {
        return messages.count
    }
    
    func chatTableView(tableView: TableView, dataForRow: Int) -> MessageItem {
        return messages[dataForRow]
    }
    
    
}
