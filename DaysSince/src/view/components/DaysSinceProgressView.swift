//
//  DaysSinceProgressView.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 5/20/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit
import CoreGraphics

@IBDesignable class DaysSinceProgressView: UIView {

    var daysSince: Int?
    var daysUntil: Int?
    
    override func draw(_ rect: CGRect) {

        for subview in self.subviews {
            subview.removeFromSuperview()
        }

        let sideLen = min(rect.width, rect.height)
        
        let startAngle = daysUntil != nil ? CGFloat(2.0 * Double.pi / 3.0) : 0.0
        let endAngle = daysUntil != nil ? CGFloat(Double.pi / 3.0) : CGFloat(2.0 * Double.pi)
        
        let backgroundPath = UIBezierPath(arcCenter: CGPoint(x: rect.midX, y: rect.midY), radius: sideLen / 2.0 - 5.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        backgroundPath.lineWidth = 10.0
        if daysUntil != nil {
            if (daysUntil! >= 0) {
                UIColor.lightGray.setStroke()
            } else {
                UIColor.red.setStroke()
            }
        } else {
            UIColor.blue.setStroke()
        }
        backgroundPath.stroke()
        
        guard let days = daysSince else {
            return
        }
        
        let labelText = String(days)
        let fontSizeCalc = calculateFontSize(labelText: labelText, availableWidth: rect.width - 25.0)
        
        let label = UILabel(frame: CGRect(x: rect.midX - fontSizeCalc.measuredWidth / 2.0, y: rect.midY - fontSizeCalc.measuredHeight / 2.0, width: fontSizeCalc.measuredWidth, height: fontSizeCalc.measuredHeight))
        label.text = labelText
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: fontSizeCalc.fontSize)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.black
        addSubview(label)

        if daysUntil != nil {
            // Draw a progression around
            if daysUntil! >= 0 {
                let percentComplete = Double(days) / Double(days + daysUntil! + 1)
                let radians = percentComplete * ((2.0 * Double.pi) - (Double.pi / 3.0))
                
                let completedPath = UIBezierPath(arcCenter: CGPoint(x: rect.midX, y: rect.midY), radius: sideLen / 2.0 - 5.0, startAngle: startAngle, endAngle: startAngle + CGFloat(radians), clockwise: true)
                completedPath.lineWidth = 10.0
                UIColor.blue.setStroke()
                completedPath.stroke()
            }
        }
        
    }
    
    func calculateFontSize(labelText:String, availableWidth:CGFloat) -> (fontSize:CGFloat, measuredWidth:CGFloat, measuredHeight: CGFloat) {
        var fontSize: CGFloat = 32.0
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0

        repeat {
            let systemFont = UIFont.systemFont(ofSize: fontSize)
            let attributes = [NSAttributedString.Key.font: systemFont]
            let measuredTextSize = NSString(string: labelText).size(withAttributes: attributes)
            width = measuredTextSize.width
            height = measuredTextSize.height
            fontSize -= 2
            
        } while (width > availableWidth)
        
        return (fontSize: fontSize, measuredWidth: width, measuredHeight: height)
    }

}
