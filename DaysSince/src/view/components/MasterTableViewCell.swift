//
//  MasterTableViewCell.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/21/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class MasterTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!

    @IBOutlet var nextDateLabel: UILabel!
    
    @IBOutlet var lastDateLabel: UILabel!

    @IBOutlet var nextLabel: UILabel!
    
    @IBOutlet var lastLabel: UILabel!
    
    @IBOutlet weak var progressView: DaysSinceProgressView!
}
