//
//  MeViewController.swift
//  GICQ
//
//  Created by Mikhail Jax on 2022/11/8.
//

import Foundation
import UIKit

class MeViewController : UIViewController {
    
    let client = Client.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel!.text = client.name
        idLabel?.text = client.id
        rtLabel?.text = client.registerDate
    }
    @IBOutlet weak var nameLabel : UILabel?
    @IBOutlet weak var idLabel: UILabel?
    @IBOutlet weak var rtLabel:
    UILabel?
    
    
    
}
