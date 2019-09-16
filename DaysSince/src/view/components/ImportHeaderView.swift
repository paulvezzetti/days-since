//
//  ImportHeaderView.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 9/15/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class ImportHeaderView: UITableViewHeaderFooterView {

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    //Select "Append" to add the activities to your current list of activities.
    //Select "Replace" to remove all current activities and replace with this list.
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func doAppendActivities(_ sender: Any) {
        print("Append clicked")
    }
    
    
    @IBAction func onReplaceClicked(_ sender: Any) {
        print("Replace clicked")
    }
}
