//
//  TarBarViewController.swift
//  GICQ
//
//  Created by Mikhail Jax on 2022/10/17.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    
    @IBOutlet weak var tabbar: UITabBar!
    
    var loaded: Bool = false
    
    var client = Client.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabbar.items![0].image = UIImage.init(systemName: "message")
        tabbar.items![1].image = UIImage.init(systemName: "person")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !loaded {
            performSegue(withIdentifier: "Loading", sender: self)
            loaded = true
        }
        
    }
}
