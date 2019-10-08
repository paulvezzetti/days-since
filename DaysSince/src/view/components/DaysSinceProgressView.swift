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
    let daysSinceLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        label.text = "0"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor(named: "SubLabelColor") // UIColor.black
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(daysSinceLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(daysSinceLabel)
    }
    
    override func draw(_ rect: CGRect) {
        let sideLen = min(rect.width, rect.height)
        
        let startAngle = daysUntil != nil ? CGFloat(2.0 * Double.pi / 3.0) : 0.0
        let endAngle = daysUntil != nil ? CGFloat(Double.pi / 3.0) : CGFloat(2.0 * Double.pi)
        
        let backgroundPath = UIBezierPath(arcCenter: CGPoint(x: rect.midX, y: rect.midY), radius: sideLen / 2.0 - 5.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        backgroundPath.lineWidth = 10.0
        if daysUntil != nil {
            if (daysUntil! >= 0) {
                let lightYellow = UIColor(named: "LightYellow") ?? UIColor(red: 250.0/255.0, green: 212.0/255.0, blue: 142.0/255.0, alpha: 1.0)
                lightYellow.setStroke()
//                UIColor.lightGray.setStroke()
            } else {
                let vividAuburn = UIColor(named: "VividAuburn") ?? UIColor(red: 165.0/255.0, green: 36.0/255.0, blue: 36.0/255.0, alpha: 1.0)
                vividAuburn.setStroke()
                //UIColor.red.setStroke()
            }
        } else {
            let lapisLazuli = UIColor(named: "LapisBlue") ?? UIColor(red: 36.0/255.0, green: 123.0/255.0, blue: 160.0/255.0, alpha: 1.0)
            lapisLazuli.setStroke()
//            UIColor.blue.setStroke()
        }
        backgroundPath.stroke()
        
        guard let days = daysSince else {
            return
        }
        
        let labelText = String(days)
        let fontSizeCalc = calculateFontSize(labelText: labelText, availableWidth: rect.width - 25.0)
        
        daysSinceLabel.frame = CGRect(x: rect.midX - fontSizeCalc.measuredWidth / 2.0, y: rect.midY - fontSizeCalc.measuredHeight / 2.0, width: fontSizeCalc.measuredWidth, height: fontSizeCalc.measuredHeight)
        daysSinceLabel.text = labelText
        daysSinceLabel.font = UIFont.systemFont(ofSize: fontSizeCalc.fontSize)
        

        if daysUntil != nil {
            // Draw a progression around
            var percentComplete = 0.0
            if daysUntil! >= 0 {
                percentComplete = Double(days) / Double(days + daysUntil!)
            } else {
                let daysOverdue = abs(daysUntil!)
                percentComplete = Double(days - daysOverdue) / Double(days)
            }
            let radians = percentComplete * ((2.0 * Double.pi) - (Double.pi / 3.0))
            
            let completedPath = UIBezierPath(arcCenter: CGPoint(x: rect.midX, y: rect.midY), radius: sideLen / 2.0 - 5.0, startAngle: startAngle, endAngle: startAngle + CGFloat(radians), clockwise: true)
            completedPath.lineWidth = 10.0
            let lapisLazuli = UIColor(named: "LapisBlue") ?? UIColor(red: 36.0/255.0, green: 123.0/255.0, blue: 160.0/255.0, alpha: 1.0)
            lapisLazuli.setStroke()

//            UIColor.blue.setStroke()
            completedPath.stroke()
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
            fontSize -= 2.0
            
        } while (width > availableWidth)
        
        return (fontSize: fontSize, measuredWidth: width, measuredHeight: height)
    }

}
