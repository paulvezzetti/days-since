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
    
    private enum TextAnchor {
        case TopLeft, TopCenter, TopRight, MiddleLeft, MiddleCenter, MiddleRight, BottomLeft, BottomCenter, BottomRight
    }

    private struct Constants {
        static let leftRightPadding: CGFloat = 10.0
        static let topBottomPadding: CGFloat = 3.0
        static let pointRadius: CGFloat = 4.0
        static let pointDiameter: CGFloat = Constants.pointRadius * 2.0
        static let triangleHeight: CGFloat = 7.0
        static let triangleWidth: CGFloat = 5.0
    }
    
    var intervals:[Double]? {
        didSet {
           self.setNeedsDisplay()
        }
    }
    
    
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
        
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
        let background = UIBezierPath(roundedRect: rect, cornerRadius: 12)
        let backColor = UIColor(named: "Header")
        backColor?.setFill()
        background.fill()
        
        let minMaxAvg = calculateMinMaxAvg()
        if minMaxAvg.min == 0.0 && minMaxAvg.max == 0.0 && minMaxAvg.2 == 0 {
            // Special case for no data. Just show a label with an error message
            placeLabel("No interval data available", x: paddedRect.midX, y: paddedRect.midY, textAnchor: .MiddleCenter, fontSize: 16.0, textColor: UIColor.blue, textAlignment: NSTextAlignment.center)
        } else if minMaxAvg.min == minMaxAvg.max && minMaxAvg.max == minMaxAvg.avg {
            // In this case, there is data, but they are all the same, non-zero value
            // Draw a single dot, with the value below it.
            let pointRect = CGRect(x: paddedRect.midX - Constants.pointRadius, y: paddedRect.midY - Constants.pointRadius, width: Constants.pointDiameter, height: Constants.pointDiameter)
            let path = UIBezierPath(ovalIn: pointRect)
            UIColor.blue.setFill()
            path.fill()
            
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 1
            
            let minValueText = numberFormatter.string(for: (minMaxAvg.min / TimeConstants.SECONDS_PER_DAY))
            placeLabel(minValueText!, x: paddedRect.midX, y: paddedRect.midY + Constants.pointRadius + 6, textAnchor: .TopCenter, fontSize: 16, textColor: UIColor.blue, textAlignment: NSTextAlignment.center)
            placeLabel(minValueText!, x: paddedRect.midX, y: paddedRect.midY - Constants.pointRadius - Constants.triangleHeight - 4, textAnchor: .BottomCenter, fontSize: 16, textColor: UIColor.red, textAlignment: NSTextAlignment.center)

            // Avg triangle
            let trianglePath = CGMutablePath()
            trianglePath.move(to: CGPoint(x: paddedRect.midX - Constants.triangleWidth, y: paddedRect.midY - Constants.pointRadius - Constants.triangleHeight - 4) )
            trianglePath.addLine(to: CGPoint(x: paddedRect.midX + Constants.triangleWidth, y: paddedRect.midY - Constants.triangleHeight - Constants.pointRadius - 4) )
            trianglePath.addLine(to: CGPoint(x: paddedRect.midX, y: paddedRect.midY - Constants.pointRadius - 4) )
            trianglePath.closeSubpath()

            let triangle = UIBezierPath(cgPath: trianglePath)
            UIColor.red.setFill()
            triangle.fill()


        } else {
            
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 1
            
            let minValueText = numberFormatter.string(for: (minMaxAvg.min / TimeConstants.SECONDS_PER_DAY))
            let minLabelRect = placeLabel(minValueText!, x: paddedRect.minX, y: paddedRect.midY + Constants.pointRadius + 4, textAnchor: .TopLeft, fontSize: 16, textColor: UIColor.blue, textAlignment: NSTextAlignment.left)
            
            let maxValueText = numberFormatter.string(for: (minMaxAvg.max / TimeConstants.SECONDS_PER_DAY))
            let maxLabelRect = placeLabel(maxValueText!, x: paddedRect.maxX, y: paddedRect.midY + Constants.pointRadius + 4, textAnchor: .TopRight, fontSize: 16, textColor: UIColor.blue, textAlignment: NSTextAlignment.left)
            
            let availableWidth = paddedRect.width
            let usableWidth = availableWidth - (minLabelRect.width / 2.0) - (maxLabelRect.width / 2.0) // - 10.0 // add some space for margin

            
            let intervalRange = minMaxAvg.max - minMaxAvg.min
            let ptPerPixel = usableWidth / CGFloat(intervalRange)
            
            let dotBorder = CGRect(x: Constants.leftRightPadding + (minLabelRect.width / 2.0) - 6, y: paddedRect.midY - 6, width: usableWidth + 12, height: 12)
            let dotBorderCurve = UIBezierPath(rect: dotBorder)
            dotBorderCurve.lineWidth = 1.0
            UIColor.blue.setStroke()
            dotBorderCurve.stroke()
            
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
            
            placeLabel(avgValueText!, x: avgX, y: paddedRect.midY - Constants.pointRadius - Constants.triangleHeight - 4, textAnchor: .BottomCenter, fontSize: 16, textColor: UIColor.red, textAlignment: NSTextAlignment.center)
            
            // Avg triangle
            let path = CGMutablePath()
            path.move(to: CGPoint(x: avgX - Constants.triangleWidth, y: paddedRect.midY - Constants.pointRadius - Constants.triangleHeight - 4) )
            path.addLine(to: CGPoint(x: avgX + Constants.triangleWidth, y: paddedRect.midY - Constants.pointRadius - Constants.triangleHeight - 4) )
            path.addLine(to: CGPoint(x: avgX, y: paddedRect.midY - Constants.pointRadius - 4) )
            path.closeSubpath()

            let triangle = UIBezierPath(cgPath: path)
            UIColor.red.setFill()
            triangle.fill()

        }
        
    }
    
    @discardableResult
    private func placeLabel(_ text:String, x: CGFloat, y: CGFloat, textAnchor:TextAnchor = TextAnchor.BottomLeft, fontSize:CGFloat = 16.0, textColor:UIColor = UIColor.blue, textAlignment:NSTextAlignment = NSTextAlignment.left) -> CGRect {
        let systemFont = UIFont.systemFont(ofSize: fontSize)
        let attributes = [NSAttributedString.Key.font: systemFont]
        let textSize = NSString(string: text).size(withAttributes: attributes)
        
        let location = calculateXY(x: x, y: y, size: textSize, textAnchor: textAnchor)
        
        let label = UILabel(frame: CGRect(x: location.xPos, y: location.yPos, width: textSize.width, height: textSize.height))
        label.text = text
        label.textAlignment = textAlignment
        label.font = systemFont
        label.textColor = textColor
        addSubview(label)
        
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

    
    private func padRect(_ rect:CGRect) -> CGRect {
        
        return CGRect(x: rect.minX + Constants.leftRightPadding, y: rect.minY + Constants.topBottomPadding, width: rect.width - (2 * Constants.leftRightPadding), height: rect.height - (2 * Constants.topBottomPadding))
    }
}
