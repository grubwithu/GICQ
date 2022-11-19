//
//  NewViewController.swift
//  GICQ
//
//  Created by Mikhail Jax on 2022/11/8.
//

import Foundation
import UIKit

class NewViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    var chats : Chats!
    
    @IBOutlet weak var idText: UITextField!
    
    @IBOutlet weak var greetingText: UITextField!
    
    @IBAction func onTapGesturePressed(_ sender: Any) {
        if idText.isEditing {
            idText.endEditing(false)
        } else if greetingText.isEditing {
            greetingText.endEditing(false)
        }
    }
    
    let client = Client.getInstance()
    @IBAction func onSendPressed(_ sender: Any) {
        createChat()
        self.presentingViewController?.dismiss(animated: true)
    }
    
    private func createChat() {
        var chatExist : Bool = false
        for chat in chats.data {
            if chat.someoneID == idText.text! {
                let content = greetingText.text!
                if content == "" {
                    chat.messages.append(MessageItem(body: NSString(string: "Hello"), logo: "1234", date: NSDate(), mtype: .Mine))
                } else {
                    chat.messages.append(MessageItem(body: NSString(string: content), logo: "1234", date: NSDate(), mtype: .Mine))
                }
                let (success, info) = client.sendChat(id: idText.text!, content: greetingText.text!)
                if success {
                    
                } else {
                    showAlert(title: "Error", content: info) {
                        _ = "Hello World ^_^"
                    }
                }
                chatExist = true
            }
        }
        if !chatExist {
            if (idText.text! != "") {
                let (success, info) = client.sendChat(id: idText.text!, content: greetingText.text!)
                if success {
                    chats.data.append(ChatInfo(someoneID: idText.text!, someoneName: info, messages: [MessageItem(body: NSString(string: greetingText.text!), logo: "1234", date: NSDate(), mtype: .Mine)]))
                    print("Chats Number : \(chats.data.count)")
                } else {
                    showAlert(title: "Error", content: info) {
                        _ = "Hello World ^_^"
                    }
                }
            }
        }
    }
    func showAlert(title: String, content: String, end: @escaping (() -> Void)) {
        let alert:UIAlertController = UIAlertController(title: title, message: content, preferredStyle: UIAlertController.Style.alert)
        let yesAction = UIAlertAction(title: "OK", style: .cancel, handler: {
            action in
            end()
        })
        alert.addAction(yesAction)
        //以模态方式弹出
        self.present(alert, animated: true, completion: nil)
    }
}
