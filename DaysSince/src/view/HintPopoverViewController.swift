//
//  HintPopoverViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 6/18/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class HintPopoverViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let label:UILabel = UILabel()
        label.text = "My Popover Hint"
        //let view = UIView()
        self.view.addSubview(label)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
