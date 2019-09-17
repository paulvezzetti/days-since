//
//  ImportHeaderView.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 9/15/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class ImportHeaderView: UITableViewHeaderFooterView {

    static let IMPORT_APPEND_NOTIFICATION: String = "importAppend"
    static let IMPORT_REPLACE_NOTIFICATION: String = "importReplace"
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func doAppendActivities(_ sender: Any) {
        print("Append clicked")
        NotificationCenter.default.post(name: Notification.Name(ImportHeaderView.IMPORT_APPEND_NOTIFICATION), object: nil, userInfo: nil)

    }
    
    
    @IBAction func onReplaceClicked(_ sender: Any) {
        print("Replace clicked")
        NotificationCenter.default.post(name: Notification.Name(ImportHeaderView.IMPORT_REPLACE_NOTIFICATION), object: nil, userInfo: nil)
    }
}
