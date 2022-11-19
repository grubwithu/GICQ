//
//  ChatsViewController.swift
//  GICQ
//
//  Created by Mikhail Jax on 2022/10/17.
//

import Foundation
import UIKit

class Chats {
    var data : [ChatInfo] = []
}

class ChatsViewController: UITableViewController {
    var chats : Chats = Chats()
    
    let client :  Client = Client.getInstance()
    
    @IBOutlet var table: UITableView!
    var selectRow : Int = 0
    
    var timer : Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //chats.append(ChatInfo(someoneID: "123456", someoneName: "grub", messages: [MessageItem(body: NSString(string: "1234"), logo: "1234", date: NSDate(), mtype: .Mine)]))
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ChatsViewController.fresh), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chats.data.sort() {
            (a, b) -> Bool in
            return a.latestMessage().date.compare(b.latestMessage().date as Date) == .orderedAscending
        }
        table.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        table.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectRow = indexPath.row
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewChat" {
            let vc =  segue.destination as! NewViewController
            vc.chats = chats
            
        } else if segue.identifier == "EnterChat" {
            let vc = segue.destination as! ChatViewController
            vc.targetRow = selectRow
            print(selectRow)
            vc.chat = chats.data[selectRow]
        }
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.data.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell")
        cell?.textLabel?.text = chats.data[indexPath.row].someoneName
        cell?.detailTextLabel?.text = chats.data[indexPath.row].latestMessage().content
        return cell!
    }
    
    @objc func fresh() {
        if client.logined {
            print("fresh")
            let (success, errCode) = client.getChat(chats: chats)
            if success {
                table.reloadData()
                print("Reloading...")
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
