//
//  StatusIndicatorView.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 5/22/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

@IBDesignable class StatusIndicatorView: UIView {

    @IBInspectable var daysSince: Int = 0
    @IBInspectable var daysUntil: Int = Int.max
    @IBInspectable var prevDate:String?
    @IBInspectable var nextDate:String?
    
    private struct Constants {
        static let lineThickness: CGFloat = 28.0
        static let leftRightPadding: CGFloat = 5.0
        static let verticalGap: CGFloat = 4.0
        
        static let timelinePadding: CGFloat = 20.0
        static let daysValueFontSize: CGFloat = 24.0
        
    }
    private let daysSinceString:String = "Days Since:"
    private let daysUntilString:String = "Days Until:"
    private let overdueString:String = "Overdue for:"
    
    private lazy var daysSinceTitleSize:CGSize = {
        let systemFont = UIFont.systemFont(ofSize: 16)
        let attributes = [NSAttributedString.Key.font: systemFont]
        return NSString(string: daysSinceString).size(withAttributes: attributes)
    }()

    private lazy var daysUntilTitleSize:CGSize = {
        let systemFont = UIFont.systemFont(ofSize: 16)
        let attributes = [NSAttributedString.Key.font: systemFont]
        return NSString(string: daysUntilString).size(withAttributes: attributes)
    }()

    private lazy var overdueTitleSize:CGSize = {
        let systemFont = UIFont.systemFont(ofSize: 16)
        let attributes = [NSAttributedString.Key.font: systemFont]
        return NSString(string: overdueString).size(withAttributes: attributes)
    }()

    private lazy var daysSinceTitleLabel:UILabel = {
        let measuredTextSize = self.daysSinceTitleSize

        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: measuredTextSize.width, height: measuredTextSize.height))
        label.text = daysSinceString
        label.textAlignment = NSTextAlignment.left
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        
        return label
    }()

    private lazy var daysUntilTitleLabel:UILabel = {
        let measuredTextSize = self.daysUntilTitleSize
        
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: measuredTextSize.width, height: measuredTextSize.height))
        label.text = daysUntilString
        label.textAlignment = NSTextAlignment.left
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        
        return label
    }()

    private lazy var overdueTitleLabel:UILabel = {
        let measuredTextSize = self.daysUntilTitleSize
        
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: measuredTextSize.width, height: measuredTextSize.height))
        label.text = overdueString
        label.textAlignment = NSTextAlignment.left
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        
        return label
    }()

    private lazy var daysSinceValueLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        label.text = String(daysSince)
        label.textAlignment = NSTextAlignment.left
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = UIColor.black
        
        return label

    }()

    private lazy var daysUntilValueLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        label.text = String(daysUntil)
        label.textAlignment = NSTextAlignment.left
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = UIColor.black
        
        return label
        
    }()

    private lazy var lastDateLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
        label.text = ""
        label.textAlignment = NSTextAlignment.left
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.black
        
        return label
    }()

    private lazy var nextDateLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
        label.text = ""
        label.textAlignment = NSTextAlignment.left
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.black
        
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(daysSinceTitleLabel)
        addSubview(daysSinceValueLabel)
        addSubview(daysUntilTitleLabel)
        addSubview(daysUntilValueLabel)
        addSubview(overdueTitleLabel)
        addSubview(lastDateLabel)
        addSubview(nextDateLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(daysSinceTitleLabel)
        addSubview(daysSinceValueLabel)
        addSubview(daysUntilTitleLabel)
        addSubview(daysUntilValueLabel)
        addSubview(overdueTitleLabel)
        addSubview(lastDateLabel)
        addSubview(nextDateLabel)
    }

    
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        if daysUntil == Int.max {
            // This is the case of an unlimited activity
            daysUntilTitleLabel.text = ""
            daysUntilTitleLabel.frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
            daysUntilValueLabel.text = ""
            daysUntilValueLabel.frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
            overdueTitleLabel.text = ""
            overdueTitleLabel.frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
            var yPos:CGFloat = Constants.verticalGap
            daysSinceTitleLabel.frame = CGRect(x: rect.minX + Constants.leftRightPadding, y: yPos, width: daysSinceTitleSize.width, height: daysSinceTitleSize.height)
            yPos += daysSinceTitleSize.height
            yPos += Constants.verticalGap
            
            if let prev = prevDate {
                // yPos += Constants.lineThickness / 2.0
                // yPos += 2
                lastDateLabel.text = prevDate
                let lastDateLabelSize = measureText(label: prev, fontSize: 12.0)
                lastDateLabel.frame = CGRect(x: rect.minX + Constants.leftRightPadding * 2.0, y: yPos, width: lastDateLabelSize.width, height: lastDateLabelSize.height)
                
                yPos += lastDateLabelSize.height
                yPos += Constants.verticalGap
                
            }
            nextDateLabel.text = ""

            
//            let daysSinceValueString = String(daysSince)
//            let daysSinceValueStringSize = measureText(label: daysSinceValueString, fontSize: 24)
//
//            daysSinceValueLabel.frame = CGRect(x: rect.maxX - Constants.leftRightPadding - daysSinceValueStringSize.width, y: yPos, width: daysSinceValueStringSize.width, height: daysSinceValueStringSize.height)
//            daysSinceValueLabel.text = daysSinceValueString
//            yPos += daysSinceValueStringSize.height
//            yPos += 2
//            yPos += Constants.lineThickness / 2.0
            
            yPos += Constants.lineThickness / 2.0
            let linePath = CGMutablePath()
            linePath.move(to: CGPoint(x: rect.minX + Constants.timelinePadding, y: yPos))
            linePath.addLine(to: CGPoint(x: rect.maxX - Constants.timelinePadding - Constants.lineThickness / 2.0, y: yPos))
            
            let clipPath = UIBezierPath(rect: CGRect(x: rect.minX + Constants.timelinePadding, y: yPos - Constants.lineThickness / 2.0, width: rect.width - Constants.timelinePadding, height: Constants.lineThickness))
            clipPath.addClip()
            
            let timeline = UIBezierPath(cgPath: linePath)
            timeline.lineCapStyle = CGLineCap.round
            timeline.lineWidth = Constants.lineThickness
            let lapisLazuli = UIColor(red: 36.0/255.0, green: 123.0/255.0, blue: 160.0/255.0, alpha: 1.0)
            lapisLazuli.setStroke()

            timeline.stroke()
            
            let daysSinceValueString = String(daysSince)
            let daysSinceValueStringSize = measureText(label: daysSinceValueString, fontSize: Constants.daysValueFontSize)
            
            daysSinceValueLabel.frame = CGRect(x: rect.minX + Constants.timelinePadding + 5.0, y: yPos - Constants.lineThickness / 2.0, width: daysSinceValueStringSize.width, height: daysSinceValueStringSize.height)
            daysSinceValueLabel.text = daysSinceValueString
            daysSinceValueLabel.textColor = UIColor.white
            //yPos += daysSinceValueStringSize.height
            //yPos += 2
            //yPos += Constants.lineThicknessWide / 2.0

            
            
        }
        else if daysUntil >= 0 {
            // This is on-time with a next date
            overdueTitleLabel.text = ""
            overdueTitleLabel.frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)

            
            var yPos:CGFloat = Constants.verticalGap
            // Place the labels for "Day Since" and "Days Until" in the same row.
            daysSinceTitleLabel.frame = CGRect(x: rect.minX + Constants.leftRightPadding, y: yPos, width: daysSinceTitleSize.width, height: daysSinceTitleSize.height)
            
            daysUntilTitleLabel.frame = CGRect(x: rect.maxX - Constants.leftRightPadding - daysUntilTitleSize.width, y: yPos, width: daysUntilTitleSize.width, height: daysUntilTitleSize.height)
            yPos += daysSinceTitleSize.height
            yPos += Constants.verticalGap
            
            // Place the previous and next dates in the next row
            var dateLabelHeight: CGFloat = 0.0
            if let prev = prevDate {
                lastDateLabel.text = prev
                let lastDateLabelSize = measureText(label: prev, fontSize: 12.0)
                lastDateLabel.frame = CGRect(x: rect.minX + Constants.leftRightPadding * 2.0, y: yPos, width: lastDateLabelSize.width, height: lastDateLabelSize.height)
                dateLabelHeight = lastDateLabelSize.height
            }
            if let next = nextDate {
                nextDateLabel.text = next
                let nextDateLabelSize = measureText(label: next, fontSize: 12)
                nextDateLabel.frame = CGRect(x: rect.maxX - Constants.leftRightPadding * 2.0 - nextDateLabelSize.width, y: yPos, width: nextDateLabelSize.width, height: nextDateLabelSize.height)
                dateLabelHeight = max(dateLabelHeight, nextDateLabelSize.height)
            }

            yPos += dateLabelHeight
            yPos += Constants.verticalGap
            // Measure the size of the DaysSince and DaysUntil value labels. Need to decide if one of them needs to
            // be placed outside of the timeline. If so, the timeline width will need to be adjusted.
            let daysSinceValueString = String(daysSince)
            let daysSinceValueStringSize = measureText(label: daysSinceValueString, fontSize: Constants.daysValueFontSize)

            let daysUntilValueString = String(daysUntil)
            let daysUntilValueStringSize = measureText(label: daysUntilValueString, fontSize: Constants.daysValueFontSize)
            
            var availableWidth = rect.width - (2 * Constants.timelinePadding)  //- Constants.lineThickness / 2.0
            let percentComplete = Double(daysSince) / Double(daysSince + daysUntil)
            
            let daysSinceLength = availableWidth * CGFloat(percentComplete)
            
            var isDaysSinceValueInside = true
            var timelineStartX = rect.minX + Constants.timelinePadding
            var timelineEndX = timelineStartX + availableWidth
            
            if daysSinceLength < daysSinceValueStringSize.width + Constants.lineThickness / 2.0 {
                // Not enough room to fit the days since text. Move it outside.
                isDaysSinceValueInside = false
                timelineStartX = rect.minX + (2.0 * Constants.leftRightPadding) + daysSinceValueStringSize.width + 2.0
                availableWidth = timelineEndX - timelineStartX
            }

            var isDaysUntilValueInside = true
            let daysUntilLength = availableWidth * (1.0 - CGFloat(percentComplete))
            if daysUntilLength < daysUntilValueStringSize.width + Constants.lineThickness / 2.0 {
                // Not enough room to fit the days until text. Move it outside.
                isDaysUntilValueInside = false
                timelineEndX = rect.maxX - (2.0 * Constants.leftRightPadding) - daysUntilValueStringSize.width - 2.0
                availableWidth = timelineEndX - timelineStartX
            }

            // Draw a background track
            yPos += Constants.lineThickness / 2.0
            
            let backgroundPath = CGMutablePath()
            backgroundPath.move(to: CGPoint(x: timelineStartX, y: yPos))
            backgroundPath.addLine(to: CGPoint(x: timelineEndX, y: yPos))
            
            let background = UIBezierPath(cgPath: backgroundPath)
            background.lineWidth = Constants.lineThickness
            let lightYellow = UIColor(red: 250.0/255.0, green: 212.0/255.0, blue: 142.0/255.0, alpha: 1.0)
            lightYellow.setStroke()
            
            background.stroke()

            
            let lineLength = (availableWidth * CGFloat(percentComplete)) - Constants.lineThickness / 2.0

            let percentTimePath = CGMutablePath()
            percentTimePath.move(to: CGPoint(x: timelineStartX, y: yPos))
            percentTimePath.addLine(to: CGPoint(x: timelineStartX + lineLength, y: yPos))
            
            let percentTimeLine = UIBezierPath(cgPath: percentTimePath)
            percentTimeLine.lineCapStyle = CGLineCap.round
            
            percentTimeLine.lineWidth = Constants.lineThickness
            let lapisLazuli = UIColor(red: 36.0/255.0, green: 123.0/255.0, blue: 160.0/255.0, alpha: 1.0)
            lapisLazuli.setStroke()
            
            let clipPath = UIBezierPath(rect: CGRect(x: timelineStartX, y: yPos - Constants.lineThickness / 2.0, width: timelineEndX - timelineStartX, height: Constants.lineThickness))
            clipPath.addClip()
            
            percentTimeLine.stroke()
            
            yPos -= Constants.lineThickness / 2.0
            let daysSinceX:CGFloat = (isDaysSinceValueInside) ? timelineStartX + 5.0 : Constants.leftRightPadding * 2.0
            
            daysSinceValueLabel.frame = CGRect(x: daysSinceX, y: yPos, width: daysSinceValueStringSize.width, height: daysSinceValueStringSize.height)
            daysSinceValueLabel.text = daysSinceValueString
            daysSinceValueLabel.textColor = isDaysSinceValueInside ? UIColor.white : UIColor.black
            
            let daysUntilX: CGFloat = isDaysUntilValueInside ? timelineEndX - daysUntilValueStringSize.width - 5.0 : rect.maxX - Constants.leftRightPadding * 2.0 - daysUntilValueStringSize.width
            
            daysUntilValueLabel.frame = CGRect(x: daysUntilX, y: yPos, width: daysUntilValueStringSize.width, height: daysUntilValueStringSize.height)
            daysUntilValueLabel.text = daysUntilValueString
        } else {
            // This is overdue
            daysUntilTitleLabel.text = ""
            daysUntilTitleLabel.frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)

            var yPos:CGFloat = Constants.verticalGap
            // Place the labels for "Day Since" and "Days Until" in the same row.
            daysSinceTitleLabel.frame = CGRect(x: rect.minX + Constants.leftRightPadding, y: yPos, width: daysSinceTitleSize.width, height: daysSinceTitleSize.height)
            
            overdueTitleLabel.frame = CGRect(x: rect.maxX - Constants.timelinePadding - overdueTitleSize.width, y: yPos, width: overdueTitleSize.width, height: overdueTitleSize.height)
            yPos += overdueTitleSize.height
            yPos += Constants.verticalGap
            
            // Place the previous and next dates in the next row
            var dateLabelHeight: CGFloat = 0.0
            if let prev = prevDate {
                lastDateLabel.text = prev
                let lastDateLabelSize = measureText(label: prev, fontSize: 12.0)
                lastDateLabel.frame = CGRect(x: rect.minX + Constants.leftRightPadding * 2.0, y: yPos, width: lastDateLabelSize.width, height: lastDateLabelSize.height)
                dateLabelHeight = lastDateLabelSize.height
            }
            
            yPos += dateLabelHeight
            yPos += Constants.verticalGap

            
            let daysSinceValueString = String(daysSince)
            let daysSinceValueStringSize = measureText(label: daysSinceValueString, fontSize: Constants.daysValueFontSize)
            
            let daysUntilValueString = String(abs(daysUntil))
            let daysUntilValueStringSize = measureText(label: daysUntilValueString, fontSize: Constants.daysValueFontSize)

            
            var availableWidth = rect.width - (2 * Constants.timelinePadding)  //- Constants.lineThickness / 2.0
            let percentOnTime = Double(daysSince - abs(daysUntil)) / Double(daysSince)
            
            let onTimeLength = availableWidth * CGFloat(percentOnTime)
            
            var isOnTimeValueInside = true
            var timelineStartX = rect.minX + Constants.timelinePadding
            var timelineEndX = timelineStartX + availableWidth
            let gradPercent : CGFloat = 0.1
            var gradDistance = gradPercent * availableWidth
            
            if onTimeLength - gradDistance < daysSinceValueStringSize.width {
                // Not enough room to fit the days since text. Move it outside.
                isOnTimeValueInside = false
                timelineStartX = rect.minX + (2.0 * Constants.leftRightPadding) + daysSinceValueStringSize.width + 2.0
                availableWidth = timelineEndX - timelineStartX
                gradDistance = gradPercent * availableWidth
            }
            
            var isOverdueValueInside = true
            let overdueLength = availableWidth * (1.0 - CGFloat(percentOnTime))
            if overdueLength - gradDistance < daysUntilValueStringSize.width {
                // Not enough room to fit the days until text. Move it outside.
                isOverdueValueInside = false
                timelineEndX = rect.maxX - (2.0 * Constants.leftRightPadding) - daysUntilValueStringSize.width - 2.0
                availableWidth = timelineEndX - timelineStartX
            }

            let timelinePath = CGMutablePath()
            let startX = timelineStartX // rect.minX + Constants.timelinePadding
            let minY = yPos
            let maxY = yPos + Constants.lineThickness
            let midY = yPos + Constants.lineThickness / 2.0
            let endX = timelineEndX - Constants.lineThickness / 2.0// rect.maxX - Constants.timelinePadding - Constants.lineThickness / 2.0
            
            timelinePath.move(to: CGPoint(x: startX, y: minY))
            timelinePath.addLine(to: CGPoint(x: startX, y: maxY))
            timelinePath.addLine(to: CGPoint(x: endX, y: maxY))
            timelinePath.addArc(center: CGPoint(x: endX, y: midY), radius: Constants.lineThickness / 2.0, startAngle: CGFloat(3.0 * Double.pi / 2.0) , endAngle: CGFloat(Double.pi / 2.0), clockwise: false)
            timelinePath.addLine(to: CGPoint(x: endX, y: minY))
            timelinePath.closeSubpath()

            let vividAuburn = UIColor(red: 165.0/255.0, green: 36.0/255.0, blue: 36.0/255.0, alpha: 1.0)
//            vividAuburn.setFill()
            let lapisLazuli = UIColor(red: 36.0/255.0, green: 123.0/255.0, blue: 160.0/255.0, alpha: 1.0)
//            lapisLazuli.setStroke()

            

            if let context = UIGraphicsGetCurrentContext() {
                context.saveGState()

                let timeline = UIBezierPath(cgPath: timelinePath)
                timeline.addClip()

                let colors = [lapisLazuli.cgColor, vividAuburn.cgColor]
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                
                let gradStart = max(0.0, CGFloat(percentOnTime) - gradPercent / 2.0)
                let gradEnd = min(1.0, CGFloat(percentOnTime) + gradPercent / 2.0)
                
                let colorLocations: [CGFloat] = [gradStart, gradEnd]
                let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)!
                context.drawLinearGradient(gradient, start: CGPoint(x: startX, y: midY), end: CGPoint(x: endX + Constants.lineThickness / 2.0, y: midY), options: [])
                
                context.restoreGState()
            }
            
            let onTimeMarkerPath = CGMutablePath()
            onTimeMarkerPath.move(to: CGPoint(x: timelineStartX + (availableWidth * CGFloat(percentOnTime)), y: minY - 1.0))
            onTimeMarkerPath.addLine(to: CGPoint(x: timelineStartX + (availableWidth * CGFloat(percentOnTime)), y: maxY + 3.0))
            
            let onTimeMarkerLine = UIBezierPath(cgPath: onTimeMarkerPath)
            onTimeMarkerLine.lineWidth = 2.0
            
            UIColor.black.setStroke()
            onTimeMarkerLine.stroke()
            
            
//            vividAuburn.setFill()
//            timeline.fill()

            let daysSinceX:CGFloat = (isOnTimeValueInside) ? timelineStartX + 5.0 : Constants.leftRightPadding * 2.0

            daysSinceValueLabel.frame = CGRect(x: daysSinceX, y: midY - daysSinceValueStringSize.height / 2.0, width: daysSinceValueStringSize.width, height: daysSinceValueStringSize.height)
            daysSinceValueLabel.text = daysSinceValueString
            daysSinceValueLabel.textColor = isOnTimeValueInside ? UIColor.white : UIColor.black

            let daysUntilX: CGFloat = isOverdueValueInside ? timelineEndX - daysUntilValueStringSize.width - 5.0 : rect.maxX - Constants.leftRightPadding * 2.0 - daysUntilValueStringSize.width

            daysUntilValueLabel.frame = CGRect(x: daysUntilX, y: midY - daysUntilValueStringSize.height / 2.0, width: daysUntilValueStringSize.width, height: daysUntilValueStringSize.height)
            daysUntilValueLabel.text = daysUntilValueString
            daysUntilValueLabel.textColor = isOverdueValueInside ? UIColor.white : UIColor.black

            
            if let next = nextDate {
                yPos = maxY + Constants.verticalGap
                nextDateLabel.text = next
                let nextDateLabelSize = measureText(label: next, fontSize: 12)
                
                var nextDateX = timelineStartX + (availableWidth * CGFloat(percentOnTime)) - nextDateLabelSize.width / 2.0
                nextDateX = max(rect.minX + 5.0, nextDateX)
                nextDateX = min(nextDateX, rect.maxX - nextDateLabelSize.width - 5.0)
                
                
                nextDateLabel.frame = CGRect(x: nextDateX, y: yPos, width: nextDateLabelSize.width, height: nextDateLabelSize.height)
                //dateLabelHeight = max(dateLabelHeight, nextDateLabelSize.height)
            }

            
            // Draw a background track
//            let backgroundPath = CGMutablePath()
//            backgroundPath.move(to: CGPoint(x: rect.minX + Constants.timelinePadding, y: yPos + Constants.lineThickness / 2.0))
//            backgroundPath.addLine(to: CGPoint(x: rect.maxX - Constants.timelinePadding - Constants.lineThickness / 2.0, y: yPos + Constants.lineThickness / 2.0))
//
//
//
//            let background = UIBezierPath(cgPath: backgroundPath)
//            background.lineWidth = Constants.lineThickness
//            background.lineCapStyle = CGLineCap.round
//            let vividAuburn = UIColor(red: 165.0/255.0, green: 36.0/255.0, blue: 36.0/255.0, alpha: 1.0)
//            vividAuburn.setStroke()
//
//            background.stroke()

//            let availableWidth = rect.width - 2 * Constants.leftRightPadding
//            let percentComplete = Double(daysSince - abs(daysUntil)) / Double(daysSince)
//            let lineLength = (availableWidth * CGFloat(percentComplete)) - Constants.lineThickness / 2.0
//            let percentTimePath = CGMutablePath()
//            percentTimePath.move(to: CGPoint(x: rect.minX + Constants.leftRightPadding, y: rect.midY))
//            percentTimePath.addLine(to: CGPoint(x: rect.minX + Constants.leftRightPadding + lineLength, y: rect.midY))
//
//            let percentTimeLine = UIBezierPath(cgPath: percentTimePath)
//            percentTimeLine.lineCapStyle = CGLineCap.round
//
//            percentTimeLine.lineWidth = Constants.lineThickness
//            let lapisLazuli = UIColor(red: 36.0/255.0, green: 123.0/255.0, blue: 160.0/255.0, alpha: 1.0)
//            lapisLazuli.setStroke()
//
//            let clipPath = UIBezierPath(rect: CGRect(x: rect.minX + Constants.leftRightPadding, y: rect.midY - Constants.lineThickness / 2.0, width: rect.width - Constants.leftRightPadding, height: Constants.lineThickness))
//            clipPath.addClip()
//
//            percentTimeLine.stroke()

            
        }
    }
    
    private func measureText(label:String, fontSize: CGFloat) -> CGSize {
        let systemFont = UIFont.systemFont(ofSize: fontSize)
        let attributes = [NSAttributedString.Key.font: systemFont]
        return NSString(string: label).size(withAttributes: attributes)
    }

}
