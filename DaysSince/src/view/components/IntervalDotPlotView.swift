//
//  IntervalDotPlotView.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 5/17/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit
import CoreGraphics

@IBDesignable class IntervalDotPlotView: UIView {
    
//    private enum TextAnchor {
//        case TopLeft, TopCenter, TopRight, MiddleLeft, MiddleCenter, MiddleRight, BottomLeft, BottomCenter, BottomRight
//    }

    private struct Constants {
        static let leftRightPadding: CGFloat = 10.0
        static let topBottomPadding: CGFloat = 3.0
        static let pointRadius: CGFloat = 4.0
        static let pointDiameter: CGFloat = Constants.pointRadius * 2.0
        static let triangleHeight: CGFloat = 7.0
        static let triangleWidth: CGFloat = 5.0
        static let pointsBoxHeight: CGFloat = Constants.pointDiameter + 4.0
    }
    
    var intervals:[Double]? {
        didSet {
           self.setNeedsDisplay()
        }
    }
    
    private var minValueLabel:UILabel?
    private var maxValueLabel:UILabel?
    private var avgValueLabel:UILabel?
    
    
    private func calculateMinMaxAvg() -> (min: Double, max: Double, avg: Double) {
        guard let intervalValues = intervals else {
            return (0.0, 0.0, 0.0)
        }
        let count = intervalValues.count
        if count <= 0 {
            return (0.0, 0.0, 0.0)
        }
        // min() and max() should only return nil if there are no elements
        let min:Double = intervalValues.min()!
        let max:Double = intervalValues.max()!
        var sum:Double = 0.0
        for interval in intervalValues {
            sum += interval
        }
        let avg = sum / Double(intervalValues.count)
        return (min, max, avg)
    }
    
    override func draw(_ rect: CGRect) {
        let paddedRect = padRect(rect)
        // Drawing code
        
//        for subview in self.subviews {
//            subview.removeFromSuperview()
//        }
        
        let background = UIBezierPath(roundedRect: rect, cornerRadius: 12)
        let backColor = UIColor(named: "Header")
        backColor?.setFill()
        background.fill()
        
        let minMaxAvg = calculateMinMaxAvg()
        if minMaxAvg.min == 0.0 && minMaxAvg.max == 0.0 && minMaxAvg.avg == 0 {
            // Special case for no data. Just show a label with an error message
            clearLabel(maxValueLabel)
            clearLabel(avgValueLabel)
            if minValueLabel == nil {
                minValueLabel = initLabel()
            }
            configureLabel(minValueLabel!, text: "No interval data available", x: paddedRect.midX, y: paddedRect.midY, textAnchor: .MiddleCenter, fontSize: 16.0, textColor: UIColor.black, textAlignment: NSTextAlignment.center)
        } else if minMaxAvg.min == minMaxAvg.max && minMaxAvg.max == minMaxAvg.avg {
            // In this case, there is data, but they are all the same, non-zero value

            drawBox(x: paddedRect.minX + 10, y: paddedRect.midY - Constants.pointsBoxHeight / 2.0, width: paddedRect.width - 20, height: Constants.pointsBoxHeight)

            // Draw a single dot, with the value below it.
            let pointRect = CGRect(x: paddedRect.midX - Constants.pointRadius, y: paddedRect.midY - Constants.pointRadius, width: Constants.pointDiameter, height: Constants.pointDiameter)
            let path = UIBezierPath(ovalIn: pointRect)
            UIColor.blue.setFill()
            path.fill()
            
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 1
            
            clearLabel(maxValueLabel)
            if minValueLabel == nil {
                minValueLabel = initLabel()
            }
            if avgValueLabel == nil {
                avgValueLabel = initLabel()
            }
            
            let minValueText = numberFormatter.string(for: (minMaxAvg.min / TimeConstants.SECONDS_PER_DAY))
            configureLabel(minValueLabel!, text: minValueText!, x: paddedRect.midX, y: paddedRect.midY + Constants.pointRadius + 6, textAnchor: .TopCenter, fontSize: 16, textColor: UIColor.black, textAlignment: NSTextAlignment.center)
            configureLabel(avgValueLabel!, text: minValueText!, x: paddedRect.midX, y: paddedRect.midY - Constants.pointRadius - Constants.triangleHeight - 4, textAnchor: .BottomCenter, fontSize: 16, textColor: UIColor.blue, textAlignment: NSTextAlignment.center)

            // Avg triangle
            drawTriangle(x: paddedRect.midX, y: paddedRect.midY - Constants.pointRadius - 4)

        } else {
            if minValueLabel == nil {
                minValueLabel = initLabel()
            }
            if maxValueLabel == nil {
                maxValueLabel = initLabel()
            }
            if avgValueLabel == nil {
                avgValueLabel = initLabel()
            }

            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 1
            
            let minValueText = numberFormatter.string(for: (minMaxAvg.min / TimeConstants.SECONDS_PER_DAY))
            let minLabelRect = configureLabel(minValueLabel!, text: minValueText!, x: paddedRect.minX, y: paddedRect.midY + Constants.pointRadius + 4, textAnchor: .TopLeft, fontSize: 16, textColor: UIColor.black, textAlignment: NSTextAlignment.left)
            
            let maxValueText = numberFormatter.string(for: (minMaxAvg.max / TimeConstants.SECONDS_PER_DAY))
            let maxLabelRect = configureLabel(maxValueLabel!, text: maxValueText!, x: paddedRect.maxX, y: paddedRect.midY + Constants.pointRadius + 4, textAnchor: .TopRight, fontSize: 16, textColor: UIColor.black, textAlignment: NSTextAlignment.left)
            
            let availableWidth = paddedRect.width
            let usableWidth = availableWidth - (minLabelRect.width / 2.0) - (maxLabelRect.width / 2.0) // - 10.0 // add some space for margin

            
            let intervalRange = minMaxAvg.max - minMaxAvg.min
            let ptPerPixel = usableWidth / CGFloat(intervalRange)
            
            drawBox(x: Constants.leftRightPadding + (minLabelRect.width / 2.0) - Constants.pointsBoxHeight / 2.0, y: paddedRect.midY - Constants.pointsBoxHeight / 2.0, width: usableWidth + 12, height: Constants.pointsBoxHeight)
            
            // Assume this is oldest to newest. // TODO: Verify
            // Last one should be full
            var alpha:CGFloat = 0.1
            let alphaDelta:CGFloat = 0.9 / CGFloat(intervals!.count - 1)
            
            for intervalValue in intervals! {
                let x = Constants.leftRightPadding + (minLabelRect.width / 2.0) + CGFloat(intervalValue - minMaxAvg.min) * ptPerPixel
                let pointRect = CGRect(x: x - Constants.pointRadius, y: paddedRect.midY - Constants.pointRadius, width: Constants.pointDiameter, height: Constants.pointDiameter)
                let path = UIBezierPath(ovalIn: pointRect)
                UIColor.blue.setFill()
                path.fill(with: .normal, alpha: alpha)
                alpha += alphaDelta
            }

            let avgValueText = numberFormatter.string(for: minMaxAvg.avg / TimeConstants.SECONDS_PER_DAY)
            let avgX = Constants.leftRightPadding + (minLabelRect.width / 2.0) + CGFloat(minMaxAvg.avg - minMaxAvg.min) * ptPerPixel
            
            configureLabel(avgValueLabel!, text: avgValueText!, x: avgX, y: paddedRect.midY - Constants.pointRadius - Constants.triangleHeight - 4, textAnchor: .BottomCenter, fontSize: 16, textColor: UIColor.blue, textAlignment: NSTextAlignment.center)
            
            // Avg triangle
            drawTriangle(x: avgX, y: paddedRect.midY - Constants.pointRadius - 4)
        }
        
    }
    
    private func initLabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
        addSubview(label)
        return label
    }
    
    private func clearLabel(_ label:UILabel?) {
        guard let oldLabel = label else {
            return
        }
        oldLabel.text = ""
        oldLabel.frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
    }
    
    @discardableResult
    private func configureLabel(_ label:UILabel, text:String, x: CGFloat, y: CGFloat, textAnchor:UILabel.TextAnchor = .BottomLeft, fontSize:CGFloat = 16.0, textColor:UIColor = UIColor.blue, textAlignment:NSTextAlignment = NSTextAlignment.left) -> CGRect {
//        let systemFont = UIFont.systemFont(ofSize: fontSize)
//        let attributes = [NSAttributedString.Key.font: systemFont]
//        let textSize = NSString(string: text).size(withAttributes: attributes)
//
//        let location = calculateXY(x: x, y: y, size: textSize, textAnchor: textAnchor)
//
//        label.frame = CGRect(x: location.xPos, y: location.yPos, width: textSize.width, height: textSize.height)
//        label.text = text
//        label.textAlignment = textAlignment
//        label.font = systemFont
//        label.textColor = textColor
//
//        return CGRect(x: location.xPos, y: location.yPos, width: textSize.width, height: textSize.height)
        
        let systemFont = UIFont.systemFont(ofSize: fontSize)
        label.text = text
        label.textAlignment = textAlignment
        label.font = systemFont
        label.textColor = textColor

        return label.updateFrame(x: x, y: y, textAnchor: textAnchor)
    }
    
    private func drawTriangle(x:CGFloat, y: CGFloat) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: x - Constants.triangleWidth, y: y - Constants.triangleHeight) )
        path.addLine(to: CGPoint(x: x + Constants.triangleWidth, y: y - Constants.triangleHeight ) )
        path.addLine(to: CGPoint(x: x, y: y) )
        path.closeSubpath()
        
        let triangle = UIBezierPath(cgPath: path)
        UIColor.blue.setFill()
        triangle.fill()

    }
    
    private func drawBox(x:CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let dotBorder = CGRect(x: x, y: y, width: width, height: height)
        let dotBorderCurve = UIBezierPath(rect: dotBorder)
        dotBorderCurve.lineWidth = 1.0
        UIColor.lightGray.setStroke()
        let lightYellow = UIColor(red: 250.0/255.0, green: 212.0/255.0, blue: 142.0/255.0, alpha: 1.0)
        lightYellow.setFill()
        dotBorderCurve.stroke()
        dotBorderCurve.fill()
    }
    
    private func calculateXY(x:CGFloat, y: CGFloat, size:CGSize, textAnchor:UILabel.TextAnchor) -> (xPos: CGFloat, yPos: CGFloat) {
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

    
    private func padRect(_ rect:CGRect) -> CGRect {
        
        return CGRect(x: rect.minX + Constants.leftRightPadding, y: rect.minY + Constants.topBottomPadding, width: rect.width - (2 * Constants.leftRightPadding), height: rect.height - (2 * Constants.topBottomPadding))
    }
}
