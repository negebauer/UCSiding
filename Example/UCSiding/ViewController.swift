//
//  ViewController.swift
//  UCSiding
//
//  Created by negebauer on 07/12/2016.
//  Copyright (c) 2016 negebauer. All rights reserved.
//

import UIKit
import UCSiding

class ViewController: UIViewController {

    @IBOutlet weak var user: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var text: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func login(_ sender: AnyObject) {
        guard let user = user.text, let pass = pass.text, user != "" && pass != "" else {
            return text.text = "Faltan datos"
        }
        let session = UCSSession(username: user, password: pass)
        session.login({
            self.text.text = "Login exitoso"
            }, failure: { error in
            self.text.text = error?.localizedDescription
        })
    }
}

