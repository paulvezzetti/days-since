//
//  ImportTableViewCell.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 9/15/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class ImportTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
