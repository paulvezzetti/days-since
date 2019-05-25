//
//  UILabelExtension.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 5/24/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    enum TextAnchor {
        case TopLeft, TopCenter, TopRight, MiddleLeft, MiddleCenter, MiddleRight, BottomLeft, BottomCenter, BottomRight
    }

    func configure(text:String, font: UIFont, color: UIColor, alignment:NSTextAlignment) {
        self.text = text
        self.font = font
        self.textColor = color
        self.textAlignment = alignment
    }
    
    @discardableResult
    func updateFrame(x: CGFloat, y: CGFloat, textAnchor:TextAnchor = TextAnchor.BottomLeft) -> CGRect {
        guard let labelText = self.text else {
            return CGRect.zero
        }
        let attributes = [NSAttributedString.Key.font: self.font]
        let textSize = NSString(string: labelText).size(withAttributes: attributes as [NSAttributedString.Key : Any])
        
        let location = calculateXY(x: x, y: y, size: textSize, textAnchor: textAnchor)
        
        self.frame = CGRect(x: location.xPos, y: location.yPos, width: textSize.width, height: textSize.height)
        return CGRect(x: location.xPos, y: location.yPos, width: textSize.width, height: textSize.height)
    }
    

    private func calculateXY(x:CGFloat, y: CGFloat, size:CGSize, textAnchor:TextAnchor) -> (xPos: CGFloat, yPos: CGFloat) {
        var xPos = x
        var yPos = y
        switch textAnchor {
        case .BottomCenter:
            xPos = x - size.width / 2.0
            yPos = y - size.height
        case .TopLeft:
            break
        case .TopCenter:
            xPos = x - size.width / 2.0
        case .TopRight:
            xPos = x - size.width
        case .MiddleLeft:
            yPos = y - size.height / 2.0
        case .MiddleCenter:
            yPos = y - size.height / 2.0
            xPos = x - size.width / 2.0
        case .MiddleRight:
            yPos = y - size.height / 2.0
            xPos = x - size.width
        case .BottomLeft:
            yPos = y - size.height
        case .BottomRight:
            xPos = x - size.width
            yPos = y - size.height
        }
        return (xPos, yPos)
    }

    
}
