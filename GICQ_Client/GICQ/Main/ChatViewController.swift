//
//  ChatViewController.swift
//  GICQ
//
//  Created by Mikhail Jax on 2022/11/10.
//

import Foundation
import UIKit

class ChatViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    let client = Client.getInstance()
    var textHeight : Double = 0.0
    var tableHeight : Double = 0.0
    var timer : Timer!
    @IBOutlet weak var text: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var table: TableView!
    @IBOutlet weak var navi : UINavigationItem!
    
    var chat : ChatInfo!
    var bubbleSection:Array<MessageItem> {
        return chat.messages
    }
    
    var targetRow : Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navi!.title = chat.someoneName
        textHeight = text.frame.origin.y
        tableHeight = table.frame.height
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDisShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDisHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ChatViewController.fresh), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        table.scrollToRow(at: IndexPath(row: bubbleSection.count, section: 0), at: .bottom, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "MsgCell"
        if(indexPath.row > 0)
        {
            var data =  self.bubbleSection[indexPath.row-1]
        
            var cell =  TableViewCell(data:data, reuseIdentifier:cellId)
        
            return cell
        }
        else
        {
            
            return UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellId)
        }
    }
    
    //用于保存所有消息
    
    //数据源，用于与 ViewController 交换数据
    var chatDataSource:ChatDataSource!
    
    required init(coder aDecoder: NSCoder) {
       
        super.init(coder: aDecoder)!
    }
    
    
    //第一个方法返回分区数，在本例中，就是1
    func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return 1
    }
    
    //返回指定分区的行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section >= self.bubbleSection.count)
        {
            return 1
        }
        
        return self.bubbleSection.count + 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0)
        {
            return 20.0
        }
        
        let data =  self.bubbleSection[indexPath.row - 1]
        
        return max(data.insets.top + data.view.frame.size.height + data.insets.bottom + 15, 65)
    }

    
    //返回自定义的 TableViewCell
    private func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
          
        let cellId = "MsgCell"
        if(indexPath.row > 0)
        {
            let data =  self.bubbleSection[indexPath.row-1]
        
            let cell =  TableViewCell(data:data, reuseIdentifier:cellId)
        
            return cell
        }
        else
        {
            
            return UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellId)
        }
    }
    
    
    @objc func handleKeyboardDisShow(notification: NSNotification) {
            //得到键盘frame
            let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let value = userInfo.object(forKey: UIResponder.keyboardFrameEndUserInfoKey)
            let keyboardRec = (value as AnyObject).cgRectValue

            let height = keyboardRec?.size.height

            //让textView bottom位置在键盘顶部
            UITextView.animate(withDuration: 0.1, animations: {
                var frame = self.text.frame
                frame.origin.y =
                 -UIApplication.shared.statusBarFrame.height -
                self.navi.accessibilityFrame.height +
                UIScreen.main.bounds.height - height!
                self.text.frame = frame
                
                frame = self.sendButton.frame
                frame.origin.y = -UIApplication.shared.statusBarFrame.height -
                self.navi.accessibilityFrame.height +
                UIScreen.main.bounds.height - height!
                self.sendButton.frame = frame
                
                frame = self.table.frame
                self.table.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: self.tableHeight - height!)
            })
        
        self.table.scrollToRow(at: IndexPath(row: bubbleSection.count, section: 0), at: .bottom, animated: true)

        }
    @objc func handleKeyboardDisHide(notification: NSNotification) {
            UITextView.animate(withDuration: 0.1, animations: {
                var frame = self.text.frame
                frame.origin.y = self.textHeight
                self.text.frame = frame
                frame = self.sendButton.frame
                frame.origin.y = self.textHeight
                self.sendButton.frame = frame
                self.table.frame = CGRect(x: self.table.frame.origin.x, y: self.table.frame.origin.y, width: self.table.frame.width, height: self.tableHeight)
            })
        
        self.table.scrollToRow(at: IndexPath(row: bubbleSection.count, section: 0), at: .bottom, animated: true)

        }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        text.endEditing(false)
        sendMessage()
        text.text = ""
        table.reloadData()
        table.scrollToRow(at: IndexPath(row: bubbleSection.count, section: 0), at: .bottom, animated: true)
        return true;
    }
    
    @IBAction func onSendPressed(_ sender: Any) {
        sendMessage()
        text.text = ""
        table.reloadData()
        table.scrollToRow(at: IndexPath(row: bubbleSection.count, section: 0), at: .bottom, animated: true)
    }
    func sendMessage() {
        if text!.text != "" {
            chat.messages.append(MessageItem(body: NSString(string: text!.text!), logo: "1234", date: NSDate(), mtype: .Mine))
            let (success, info) = client.sendChat(id: chat.someoneID, content: text!.text!)
            if !success {
                showAlert(title: "Error", content: info) {
                    _ = "Hello World"
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
    
    @objc func fresh() {
        table.reloadData()
    }
}
