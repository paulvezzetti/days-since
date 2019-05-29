//
//  NoActivityViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 5/29/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class NoActivityViewController: UIViewController {

    var dataManager: DataModelManager? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addActivity" {
            let controller = segue.destination as! AddActivityTableViewController
            controller.dataManager = dataManager
        }
     }

}
