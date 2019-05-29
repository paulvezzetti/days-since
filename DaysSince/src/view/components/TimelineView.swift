//
//  StatusIndicatorView.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 5/22/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

@IBDesignable class TimelineView: UIView {

    @IBInspectable var daysSince: Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var daysUntil: Int = Int.max {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var prevDate:String? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var nextDate:String? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    private struct Constants {
        static let TimelineThickness: CGFloat = 28.0
        static let HalfTimelineThickness: CGFloat = Constants.TimelineThickness / 2.0
        static let TimelineIndent: CGFloat = 20.0
        static let LeftRightPadding: CGFloat = 2.0
        static let DateLeftRightPadding: CGFloat = 10.0
        static let VerticalSpacing: CGFloat = 4.0
        static let OutsideDaysLabelSpacing: CGFloat = 2.0
        static let InsideDaysLabelPadding: CGFloat = 3.0
        static let DateMarkerHeight: CGFloat = 3.0
        static let DateMarkerLineWidth: CGFloat = 2.0
        
        static let DaysValueFontSize: CGFloat = 24.0
        static let DateLabelFontSize: CGFloat = 14.0
        static let DaysLabelFontSize: CGFloat = 16.0
        
        static let GradientWidth: CGFloat = 0.1
        
    }
    
    static let lightYellow:UIColor = UIColor(red: 250.0/255.0, green: 212.0/255.0, blue: 142.0/255.0, alpha: 1.0)
    static let lapisLazuli:UIColor = UIColor(red: 36.0/255.0, green: 123.0/255.0, blue: 160.0/255.0, alpha: 1.0)
    static let vividAuburn:UIColor = UIColor(red: 165.0/255.0, green: 36.0/255.0, blue: 36.0/255.0, alpha: 1.0)
    static let LightTimelineTextColor: UIColor = UIColor.white
    static let DarkTimelineTextColor: UIColor = UIColor.black
    
    private static let DaysSinceLocalized:String = NSLocalizedString("daysSince", value: "Days Since:", comment: "")
    private static let DaysUntilLocalized:String = NSLocalizedString("daysUntil", value: "Days Until:", comment: "")
    private static let OverdueForLocalized:String = NSLocalizedString("overdueFor", value: "Overdue For:", comment: "")
    
    private lazy var daysSinceTitleLabel:UILabel = {
        return UILabel(frame: CGRect.zero)
    }()

    private lazy var daysUntilTitleLabel:UILabel = {
        return UILabel(frame: CGRect.zero)
    }()

    private lazy var daysSinceValueLabel:UILabel = {
        return UILabel(frame: CGRect.zero)
    }()

    private lazy var daysUntilValueLabel:UILabel = {
        return UILabel(frame: CGRect.zero)
    }()

    private lazy var lastDateLabel:UILabel = {
        return UILabel(frame: CGRect.zero)
    }()

    private lazy var nextDateLabel:UILabel = {
        return UILabel(frame: CGRect.zero)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(daysSinceTitleLabel)
        addSubview(daysSinceValueLabel)
        addSubview(daysUntilTitleLabel)
        addSubview(daysUntilValueLabel)
        addSubview(lastDateLabel)
        addSubview(nextDateLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(daysSinceTitleLabel)
        addSubview(daysSinceValueLabel)
        addSubview(daysUntilTitleLabel)
        addSubview(daysUntilValueLabel)
        addSubview(lastDateLabel)
        addSubview(nextDateLabel)
    }

    
    override func draw(_ rect: CGRect) {
        // Drawing is based on the status of the activity: Unlimited, on-time, overdue.
        if daysUntil == Int.max {
            // This is the case of an unlimited activity
            drawAsUnlimited(rect)
        }
        else if daysUntil >= 0 {
            // In this case, the activity is on-time when X days since and Y days until.
            drawAsOntime(rect)
        } else {
            // Overdue
            drawAsOverdue(rect)
        }
    }
    
    private func drawAsUnlimited(_ rect: CGRect) {
        // Hide unused labels
        hideLabel(daysUntilTitleLabel)
        hideLabel(daysUntilValueLabel)
        hideLabel(nextDateLabel)
        
        var yPos:CGFloat = Constants.VerticalSpacing
        // Set the Days Since label
        let daysSinceTitleSize = configureLabel(daysSinceTitleLabel, text: TimelineView.DaysSinceLocalized, x: rect.minX + Constants.LeftRightPadding, y: yPos, textAnchor: .TopLeft, fontSize: Constants.DaysLabelFontSize, bold:
            true)
        
        yPos += daysSinceTitleSize.height
        yPos += Constants.VerticalSpacing
        // Set the previous date label
        if let prev = prevDate {
            let lastDateLabelSize = configureLabel(lastDateLabel, text: prev, x: rect.minX + Constants.DateLeftRightPadding, y: yPos, textAnchor: .TopLeft, fontSize: Constants.DateLabelFontSize)
            yPos += lastDateLabelSize.height
            yPos += Constants.VerticalSpacing
        }
        // Draw the timeline
        yPos += Constants.HalfTimelineThickness
        drawTimeline(from: rect.minX + Constants.TimelineIndent, to: rect.maxX - Constants.TimelineIndent, y: yPos, width: Constants.TimelineThickness, color: TimelineView.lapisLazuli)
        // Label the number of days since inside the timeline
        configureLabel(daysSinceValueLabel, text: String(daysSince), x: rect.minX + Constants.TimelineIndent + Constants.LeftRightPadding, y: yPos, textAnchor: .MiddleLeft, fontSize: Constants.DaysValueFontSize, textColor: TimelineView.LightTimelineTextColor)
    }
    
    private func drawAsOntime(_ rect: CGRect) {
        // This is on-time with a next date
        var yPos:CGFloat = Constants.VerticalSpacing
        // Place the labels for "Day Since" and "Days Until" in the same row.
        let daysSinceSize = configureLabel(daysSinceTitleLabel, text: TimelineView.DaysSinceLocalized, x: rect.minX + Constants.LeftRightPadding, y: yPos, textAnchor: .TopLeft, fontSize: Constants.DaysLabelFontSize, bold: true)
        
        let daysUntilSize = configureLabel(daysUntilTitleLabel, text: TimelineView.DaysUntilLocalized, x: rect.maxX - Constants.LeftRightPadding, y: yPos, textAnchor: .TopRight, fontSize: Constants.DaysLabelFontSize, bold: true)
        
        yPos += max(daysSinceSize.height, daysUntilSize.height)
        yPos += Constants.VerticalSpacing
        
        // Place the previous and next dates in the next row
        var dateLabelHeight: CGFloat = 0.0
        if let prev = prevDate {
            let lastDateSize = configureLabel(lastDateLabel, text: prev, x: rect.minX + Constants.DateLeftRightPadding, y: yPos, textAnchor: .TopLeft, fontSize: Constants.DateLabelFontSize)
            dateLabelHeight = lastDateSize.height
        }
        if let next = nextDate {
            let nextDateSize = configureLabel(nextDateLabel, text: next, x: rect.maxX - Constants.DateLeftRightPadding, y: yPos, textAnchor: .TopRight, fontSize: Constants.DateLabelFontSize)
            dateLabelHeight = max(dateLabelHeight, nextDateSize.height)
        }
        
        yPos += dateLabelHeight
        yPos += Constants.VerticalSpacing
        // Measure the size of the DaysSince and DaysUntil value labels. Need to decide if one of them needs to
        // be placed outside of the timeline. If so, the timeline width will need to be adjusted.
        let daysSinceValueString = String(daysSince)
        let daysSinceValueStringSize = measureText(label: daysSinceValueString, fontSize: Constants.DaysValueFontSize)
        
        let daysUntilValueString = String(daysUntil)
        let daysUntilValueStringSize = measureText(label: daysUntilValueString, fontSize: Constants.DaysValueFontSize)
        
        var availableWidth = rect.width - (2.0 * Constants.TimelineIndent) // Width is total width minus the indent value on right and left
        let percentComplete: CGFloat = CGFloat( Double(daysSince) / Double(daysSince + daysUntil) )
        
        var percentLength = availableWidth * percentComplete
        
        var isDaysSinceValueInside = true
        var timelineStartX = rect.minX + Constants.TimelineIndent
        var timelineEndX = timelineStartX + availableWidth
        
        if percentLength < daysSinceValueStringSize.width + (2.0 * Constants.InsideDaysLabelPadding) { // Space to draw is less than the lenght of the string plus padding
            // Not enough room to fit the days since text. Move it outside.
            isDaysSinceValueInside = false
            timelineStartX = rect.minX + Constants.DateLeftRightPadding + daysSinceValueStringSize.width + Constants.OutsideDaysLabelSpacing
            availableWidth = timelineEndX - timelineStartX
        }
        
        var isDaysUntilValueInside = true
        let daysUntilLength = availableWidth * (1.0 - percentComplete)
        if daysUntilLength < daysUntilValueStringSize.width + (2.0 * Constants.InsideDaysLabelPadding)  { // The actual available space for the label is less because of the rounded part of the timeline.
            // Not enough room to fit the days until text. Move it outside.
            isDaysUntilValueInside = false
            timelineEndX = rect.maxX - (Constants.DateLeftRightPadding + daysUntilValueStringSize.width + Constants.OutsideDaysLabelSpacing)
            availableWidth = timelineEndX - timelineStartX
        }
        
        // Draw a background track
        yPos += Constants.HalfTimelineThickness
        
        drawTimelineBackground(from: timelineStartX, to: timelineEndX, y: yPos, width: Constants.TimelineThickness, color: TimelineView.lightYellow)
        // Recalculate the percentLength since the timeline length may have changed due to labels being moved outside.
        percentLength = availableWidth * percentComplete
        drawTimeline(from: timelineStartX, to: timelineStartX + percentLength, y: yPos, width: Constants.TimelineThickness, color: TimelineView.lapisLazuli)
        
        //yPos -= Constants.HalfTimelineThickness
        let daysSinceX:CGFloat = (isDaysSinceValueInside) ? timelineStartX + Constants.InsideDaysLabelPadding : Constants.DateLeftRightPadding
        configureLabel(daysSinceValueLabel, text: daysSinceValueString, x: daysSinceX, y: yPos, textAnchor: .MiddleLeft, fontSize: Constants.DaysValueFontSize, textColor: isDaysSinceValueInside ? UIColor.white : UIColor.black)
        
        let daysUntilX: CGFloat = isDaysUntilValueInside ? timelineEndX - Constants.InsideDaysLabelPadding : rect.maxX - Constants.DateLeftRightPadding
        configureLabel(daysUntilValueLabel, text: daysUntilValueString, x: daysUntilX, y: yPos, textAnchor: .MiddleRight, fontSize: Constants.DaysValueFontSize)

    }
    
    func drawAsOverdue(_ rect:CGRect) {
        // This is overdue
        var yPos:CGFloat = Constants.VerticalSpacing
        // Place the labels for "Day Since" and "Days Until" in the same row.
        let daysSinceTitleSize = configureLabel(daysSinceTitleLabel, text: TimelineView.DaysSinceLocalized, x: rect.minX + Constants.LeftRightPadding, y: yPos, textAnchor: .TopLeft, fontSize: Constants.DaysLabelFontSize, bold: true)
        let daysOverdueTitleSize = configureLabel(daysUntilTitleLabel, text: TimelineView.OverdueForLocalized, x: rect.maxX - Constants.LeftRightPadding, y: yPos, textAnchor: .TopRight, fontSize: Constants.DaysLabelFontSize, bold: true)
        
        yPos += max(daysSinceTitleSize.height, daysOverdueTitleSize.height)
        yPos += Constants.VerticalSpacing
        
        // Place the previous and next dates in the next row
        var dateLabelHeight: CGFloat = 0.0
        if let prev = prevDate {
            let lastDateSize = configureLabel(lastDateLabel, text: prev, x: rect.minX + Constants.DateLeftRightPadding, y: yPos, textAnchor: .TopLeft, fontSize: Constants.DateLabelFontSize)
            dateLabelHeight = lastDateSize.height
        }
        
        yPos += dateLabelHeight
        yPos += Constants.VerticalSpacing
        
        let daysSinceValueString = String(daysSince)
        let daysSinceValueStringSize = measureText(label: daysSinceValueString, fontSize: Constants.DaysValueFontSize)
        
        let daysUntilValueString = String(abs(daysUntil))
        let daysUntilValueStringSize = measureText(label: daysUntilValueString, fontSize: Constants.DaysValueFontSize)
        
        var availableWidth = rect.width - (2 * Constants.TimelineIndent)
        let percentOnTime = CGFloat(Double(daysSince - abs(daysUntil)) / Double(daysSince))
        
        let onTimeLength = availableWidth * percentOnTime
        
        var isOnTimeValueInside = true
        var timelineStartX = rect.minX + Constants.TimelineIndent
        var timelineEndX = timelineStartX + availableWidth
        let gradPercent : CGFloat = Constants.GradientWidth
        var gradDistance = gradPercent * availableWidth
        
        if onTimeLength - gradDistance < daysSinceValueStringSize.width + (Constants.InsideDaysLabelPadding * 2.0) {
            // Not enough room to fit the days since text. Move it outside.
            isOnTimeValueInside = false
            timelineStartX = rect.minX + Constants.DateLeftRightPadding + daysSinceValueStringSize.width + Constants.OutsideDaysLabelSpacing
            availableWidth = timelineEndX - timelineStartX
            gradDistance = gradPercent * availableWidth
        }
        
        var isOverdueValueInside = true
        let overdueLength = availableWidth * (1.0 - percentOnTime)
        if overdueLength - gradDistance < daysUntilValueStringSize.width + (Constants.InsideDaysLabelPadding * 2.0)  {
            // Not enough room to fit the days until text. Move it outside.
            isOverdueValueInside = false
            timelineEndX = rect.maxX - (Constants.DateLeftRightPadding + daysUntilValueStringSize.width + Constants.OutsideDaysLabelSpacing)
            availableWidth = timelineEndX - timelineStartX
        }
        
        let startX = timelineStartX
        let minY = yPos
        let maxY = yPos + Constants.TimelineThickness
        let midY = yPos + Constants.HalfTimelineThickness
        let endX = timelineEndX
        
        let colors = [TimelineView.lapisLazuli.cgColor, TimelineView.vividAuburn.cgColor]
        
        drawTimeline(from: startX, to: endX, y: midY, width: Constants.TimelineThickness, colors: colors, inflectionPct: percentOnTime)
        
        let onTimeMarkerPath = CGMutablePath()
        onTimeMarkerPath.move(to: CGPoint(x: timelineStartX + (availableWidth * percentOnTime), y: minY - Constants.DateMarkerHeight))
        onTimeMarkerPath.addLine(to: CGPoint(x: timelineStartX + (availableWidth * percentOnTime), y: maxY + Constants.DateMarkerHeight))
        
        let onTimeMarkerLine = UIBezierPath(cgPath: onTimeMarkerPath)
        onTimeMarkerLine.lineWidth = Constants.DateMarkerLineWidth
        
        UIColor.black.setStroke()
        onTimeMarkerLine.stroke()
        
        let daysSinceX:CGFloat = (isOnTimeValueInside) ? timelineStartX + Constants.InsideDaysLabelPadding : Constants.DateLeftRightPadding
        configureLabel(daysSinceValueLabel, text: daysSinceValueString, x: daysSinceX, y: midY, textAnchor: .MiddleLeft, fontSize: Constants.DaysValueFontSize, textColor: isOnTimeValueInside ? TimelineView.LightTimelineTextColor : TimelineView.DarkTimelineTextColor)
        
        let daysUntilX: CGFloat = isOverdueValueInside ? timelineEndX - Constants.InsideDaysLabelPadding : rect.maxX - Constants.DateLeftRightPadding
        
        configureLabel(daysUntilValueLabel, text: daysUntilValueString, x: daysUntilX, y: midY, textAnchor: .MiddleRight, fontSize: Constants.DaysValueFontSize, textColor: isOverdueValueInside ? TimelineView.LightTimelineTextColor : TimelineView.DarkTimelineTextColor)
        
        if let next = nextDate {
            yPos = maxY + Constants.VerticalSpacing
            
            let nextDateLabelSize = measureText(label: next, fontSize: Constants.DateLabelFontSize)
            var nextDateX = timelineStartX + (availableWidth * percentOnTime) - nextDateLabelSize.width / 2.0
            nextDateX = max(rect.minX + Constants.LeftRightPadding, nextDateX)
            nextDateX = min(nextDateX, rect.maxX - nextDateLabelSize.width - Constants.LeftRightPadding)
            
            configureLabel(nextDateLabel, text: next, x: nextDateX, y: yPos, textAnchor: .TopLeft, fontSize: Constants.DateLabelFontSize)
        }
    }
    
    @discardableResult
    private func configureLabel(_ label:UILabel, text:String, x: CGFloat, y: CGFloat, textAnchor:UILabel.TextAnchor = .BottomLeft, fontSize:CGFloat = 16.0, textColor:UIColor = UIColor.black, bold:Bool = false, textAlignment:NSTextAlignment = NSTextAlignment.left) -> CGRect {
        let font = createFont(fontSize: fontSize, bold: bold)
        
        label.configure(text: text, font: font, color: textColor, alignment: textAlignment)
        return label.updateFrame(x: x, y: y, textAnchor: textAnchor)
    }
    
    
    private func hideLabel(_ label:UILabel) {
        label.text = ""
        label.frame = CGRect.zero
    }
    
    
    
    private func measureText(label:String, fontSize: CGFloat, bold:Bool = false) -> CGSize {
        let systemFont = createFont(fontSize: fontSize, bold: bold)
        let attributes = [NSAttributedString.Key.font: systemFont]
        return NSString(string: label).size(withAttributes: attributes)
    }
    
    private func createFont(fontSize: CGFloat, bold:Bool) -> UIFont {
        var descriptor = UIFontDescriptor(name: "Avenir", size: fontSize)
        if bold {
            descriptor = descriptor.withSymbolicTraits(.traitBold) ?? descriptor
        }
        return UIFont(descriptor: descriptor, size: fontSize)

    }

    
    private func drawTimelineBackground(from xStart:CGFloat, to xEnd:CGFloat, y: CGFloat, width: CGFloat, color: UIColor) {
        let background = CGMutablePath()
        let yLower: CGFloat = y - width / 2.0
        let yUpper: CGFloat = y + width / 2.0
        background.move(to: CGPoint(x: xStart, y: yLower))
        background.addLine(to: CGPoint(x: xEnd, y: yLower))
        background.addLine(to: CGPoint(x: xEnd, y: yUpper))
        background.addLine(to: CGPoint(x: xStart, y: yUpper))
        background.closeSubpath()
        
        let timeline = UIBezierPath(cgPath: background)
        color.setFill()
        timeline.fill()
    }
    
    private func drawTimeline(from xStart:CGFloat, to xEnd:CGFloat, y: CGFloat, width: CGFloat, color: UIColor) {
        let path = createTimelineProgressPath(from: xStart, to: xEnd, y: y, width: width)
        
        let timeline = UIBezierPath(cgPath: path)
        color.setFill()
        timeline.fill()
    }
    
    private func drawTimeline(from xStart:CGFloat, to xEnd:CGFloat, y: CGFloat, width: CGFloat, colors: [CGColor], inflectionPct: CGFloat) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.saveGState()
        let timelinePath = createTimelineProgressPath(from: xStart, to: xEnd, y: y, width: width)
        let timeline = UIBezierPath(cgPath: timelinePath)
        timeline.addClip()
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let gradStart = max(0.0, inflectionPct - 0.05)
        let gradEnd = min(1.0, inflectionPct + 0.05)
        
        let colorLocations: [CGFloat] = [gradStart, gradEnd]
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)!
        context.drawLinearGradient(gradient, start: CGPoint(x: xStart, y: y), end: CGPoint(x: xEnd, y: y), options: [])
        
        context.restoreGState()
    }
    
    /**
     Creates a path to represent the timeline progress. This is a rectangle with a square left end and a round right end. The
     round end is draw such that it ends at the 'to' x value. In other words, the actual shape exactly the distance 'to' minus the 'from'
     including the rounded end.
     
     - Parameters:
     - from : x value to start from
     - to: x value to end the main part of the path. The rounded end will begin at this value.
     - y: y value of the middle of the path
     - width: width of path
     
     - Returns: CGPath for the progress path
 
     */
    private func createTimelineProgressPath(from xStart:CGFloat, to xEnd: CGFloat, y: CGFloat, width: CGFloat) -> CGMutablePath {
        let timelinePath = CGMutablePath()
        let halfWidth = width / 2.0
        let yLower = y - halfWidth
        let yUpper = y + halfWidth
        let xEndActual = max(xStart, xEnd - halfWidth)
        
        timelinePath.move(to: CGPoint(x: xStart, y: yLower))
        timelinePath.addLine(to: CGPoint(x: xStart, y: yUpper))
        timelinePath.addLine(to: CGPoint(x: xEndActual, y: yUpper))
        timelinePath.addArc(center: CGPoint(x: xEndActual, y: y), radius: halfWidth, startAngle: CGFloat(3.0 * Double.pi / 2.0) , endAngle: CGFloat(Double.pi / 2.0), clockwise: false)
        timelinePath.addLine(to: CGPoint(x: xEndActual, y: yLower))
        timelinePath.closeSubpath()

        return timelinePath
    }
    
}
