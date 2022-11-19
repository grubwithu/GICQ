//
//  RegisterViewController.swift
//  GICQ
//
//  Created by Mikhail Jax on 2022/11/14.
//

import Foundation
import UIKit

class RegisterViewController : UIViewController, UITextFieldDelegate {
    @IBOutlet weak var id : UITextField!
    @IBOutlet weak var pwd : UITextField!
    @IBOutlet weak var pwd2 : UITextField!
    @IBOutlet weak var name : UITextField!
    
    let client = Client.getInstance()
    
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        for str in string {
            if alphaCheck(str) == false {
                return false
            }
        }
        return true
    }
    @IBAction func dissmissKeyboard(_ sender: Any) {
        if id.isEditing {
            id.endEditing(false)
        } else if pwd.isEditing {
            pwd.endEditing(false)
        } else if pwd2.isEditing {
            pwd2.endEditing(false)
        }
    }
    
    @IBAction func upScreen(_ sender: Any) {
        self.view.transform = CGAffineTransform(translationX: 0, y: -70)
    }
    @IBAction func downScreen(_ sender: Any) {
        self.view.transform = CGAffineTransform(translationX: 0, y: 0)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.restorationIdentifier! == "id" {
            id.endEditing(true)
            pwd.becomeFirstResponder()
        } else if textField.restorationIdentifier! == "pwd" {
            pwd.endEditing(false)
            pwd2.becomeFirstResponder()
        } else if textField.restorationIdentifier! == "pwd2" {
            pwd2.endEditing(false)
        }
        return true;
    }
    @IBAction func onSignUpPressed(_ sender: Any) {
        if (id.text! != "" &&
            (pwd.text! == pwd2.text!) &&
            pwd.text! != "") {
            let (success, errCode) = client.register(id: id.text!, pwd: pwd.text!, name: name.text!)
            if success {
                self.presentingViewController!.dismiss(animated: true)
            } else {
                showAlert(title: "Error", content: errCode) {
                    exit(-1)
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
