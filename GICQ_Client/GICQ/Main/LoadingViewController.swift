//
//  MainViewController.swift
//  GICQ
//
//  Created by Mikhail Jax on 2022/10/10.
//

import UIKit

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    public var client = Client.getInstance()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !client.connected {
            client.createSocket(ip: "192.168.1.100", port: 9898)
            if !client.connectionEstablish() {
                showAlert(title: "Error", content: "Failed to connect server. Please check your network.") {
                    exit(-1)
                }
            }
        }
        loading.startAnimating()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var later = Date.init(timeIntervalSinceNow: 3)
        
        while !client.connected {
            
            if later.compare(Date.init()) == .orderedAscending {
                showAlert(title: "Error", content: "Failed to connect to server. Please check your network."){
                    exit(-1)
                }
                return
            }
        }
        
        let info:(String, String)? = getLocalUserInfo()
        
        if (info == nil || info?.0 == "" || info?.1 == "") {
            print("Enter into login")
            performSegue(withIdentifier: "Login", sender: self)
            return
        }
        
        let (success, errCode) = client.login(account: info!.0, password: info!.1)
        if !success {
            showAlert(title: "Error", content: errCode) {
                self.eraseLoacalUserInfo()
                exit(-1)
            }
        } else {
            print("Login Success!!!")
            let (success, errCode) = client.getUserInfo()
            if !success {
                showAlert(title: "Error", content: errCode) {
                    self.eraseLoacalUserInfo()
                    exit(-1)
                }
            } else {
                loading.stopAnimating()
                self.presentingViewController!.dismiss(animated: true)
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
    
    private func getLocalUserInfo() -> (String, String)? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let fileName = path! + "/Account.plist"
        let dic = NSDictionary(contentsOfFile: fileName)
        if dic == nil {
            return nil
        } else {
            return (dic!.value(forKey: "id")!, dic!.value(forKey: "pwd")!) as? (String, String)
        }
    }
    
    private func eraseLoacalUserInfo() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let fileName = path! + "/Account.plist"
        let dic:NSDictionary = ["id": "", "pwd": ""]
        dic.write(toFile: fileName, atomically: true)
    }
}


