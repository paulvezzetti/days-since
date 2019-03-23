//
//  ActivityTableHeaderView.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 3/22/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class ActivityTableHeaderView: UITableViewHeaderFooterView {

    
    @IBOutlet var headerTitleLabel: UILabel!
    
    @IBOutlet var chevronImage: UIImageView!

    var delegate: CollapsibleTableViewHeaderDelegate?
    var section: Int = 0
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHeader(gestureRecognizer:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHeader(gestureRecognizer:))))
    }
    
    @objc
    func tapHeader(gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? ActivityTableHeaderView else {
            return
        }
        delegate?.toggleSection(header: self, section: cell.section)
    }
    
    func setCollapsed(collapsed: Bool) {
        let angle = collapsed ? -90.0 * .pi / 180.0 : 0.0
        UIView.animate(withDuration: 10.0, animations: {
            self.chevronImage.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
        })
        
    }
    
}
