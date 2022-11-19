//
//  ViewController.swift
//  GICQ
//
//  Created by Mikhail Jax on 2022/10/4.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    private func alphaCheck(_ str: Character) -> Bool {
        if (str >= "0" && str <= "9") {
            return true
        } else if (str >= "a" && str <= "z") {
            return true
        } else if (str == "_" || str == ".") {
            return true
        }
        return false
    }
    
    @IBOutlet weak var accountText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        for str in string {
            if alphaCheck(str) == false {
                return false
            }
        }
        return true
    }
    
    @IBAction func dissmissKeyboard(_ sender: Any) {
        if accountText.isEditing {
            accountText.endEditing(false)
        } else if passwordText.isEditing {
            passwordText.endEditing(false)
        }
    }
    @IBAction func upScreen(_ sender: Any) {
        self.view.transform = CGAffineTransform(translationX: 0, y: -70)
    }
    @IBAction func downScreen(_ sender: Any) {
        self.view.transform = CGAffineTransform(translationX: 0, y: 0)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.restorationIdentifier! == "account" {
            accountText.endEditing(true)
            passwordText.becomeFirstResponder()
        } else if textField.restorationIdentifier! == "password" {
            passwordText.endEditing(false)
        }
        return true;
    }
    
    @IBAction func onLoginButtonPressed(_ sender: UIButton) {
        if !accountText.text!.isEmpty && !passwordText.text!.isEmpty {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            let fileName = path! + "/Account.plist"
            let dic:NSDictionary = ["id": accountText.text!, "pwd": passwordText.text!]
            dic.write(toFile: fileName, atomically: true)
            self.presentingViewController!.dismiss(animated: true)
        }
    }
    
}

