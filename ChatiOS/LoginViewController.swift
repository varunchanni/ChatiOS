//
//  ViewController.swift
//  ChatiOS
//
//  Created by Varun Channi on 23/03/17.
//  Copyright © 2017 Codination. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginButtonAction(_ sender: Any) {
        
        ChatConnectivity.sharedConnectivity.connect(withUsername: usernameField.text!, andPassword: passwordField.text!) { (success) in
            
            if success {
                print("login ho gaya")
                UserDefaults.standard.set(usernameField.text!, forKey: "username")
                UserDefaults.standard.set(passwordField.text!, forKey: "password")
                UserDefaults.standard.synchronize()
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Error logging in")
            }
        }
    }

}

