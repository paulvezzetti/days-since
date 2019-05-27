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
    
    private struct Constants {
        static let leftRightPadding: CGFloat = 10.0
        static let topBottomPadding: CGFloat = 3.0
        static let verticalSpacing: CGFloat = 2.0
        static let pointRadius: CGFloat = 6.0
        static let pointDiameter: CGFloat = Constants.pointRadius * 2.0
        static let triangleHeight: CGFloat = 9.0
        static let triangleWidth: CGFloat = 6.0
        static let pointsBoxHeight: CGFloat = Constants.pointDiameter + 4.0
        
        static let numberFontSize: CGFloat = 20.0
    }
    
    static let lapisLazuli:UIColor = UIColor(red: 36.0/255.0, green: 123.0/255.0, blue: 160.0/255.0, alpha: 1.0)
    
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
        
//        let background = UIBezierPath(roundedRect: rect, cornerRadius: 12)
//        let backColor = UIColor(named: "Header")
//        backColor?.setFill()
//        background.fill()
        
        let minMaxAvg = calculateMinMaxAvg()
        if minMaxAvg.min == 0.0 && minMaxAvg.max == 0.0 && minMaxAvg.avg == 0 {
            // Special case for no data. Just show a label with an error message
            clearLabel(maxValueLabel)
            clearLabel(avgValueLabel)
            if minValueLabel == nil {
                minValueLabel = initLabel()
            }
            configureLabel(minValueLabel!, text: "No interval data available", x: paddedRect.midX, y: paddedRect.midY, textAnchor: .MiddleCenter, fontSize: Constants.numberFontSize, textColor: UIColor.black, textAlignment: NSTextAlignment.center)
        } else if minMaxAvg.min == minMaxAvg.max && minMaxAvg.max == minMaxAvg.avg {
            // In this case, there is data, but they are all the same, non-zero value
            
            var yPos = Constants.topBottomPadding

            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 1
            let minValueText = numberFormatter.string(for: (minMaxAvg.min / TimeConstants.SECONDS_PER_DAY))

            clearLabel(maxValueLabel)
            if avgValueLabel == nil {
                avgValueLabel = initLabel()
            }
            let avgLabelSize = configureLabel(avgValueLabel!, text: minValueText!, x: paddedRect.midX, y: yPos /*paddedRect.midY - Constants.pointRadius - Constants.triangleHeight - 4*/, textAnchor: .TopCenter, fontSize: Constants.numberFontSize, textColor: IntervalDotPlotView.lapisLazuli, textAlignment: NSTextAlignment.center)

            yPos += avgLabelSize.height
            //yPos += Constants.verticalSpacing
            // Avg triangle
            drawTriangle(x: paddedRect.midX, y: yPos)

            yPos += Constants.triangleHeight
            yPos += Constants.verticalSpacing
            yPos += Constants.pointsBoxHeight / 2.0
            drawBox(x: paddedRect.minX + 10, y: yPos, width: paddedRect.width - 20, height: Constants.pointsBoxHeight)

            // Draw a single dot, with the value below it.
            let pointRect = CGRect(x: paddedRect.midX - Constants.pointRadius, y: yPos - Constants.pointRadius, width: Constants.pointDiameter, height: Constants.pointDiameter)
            let path = UIBezierPath(ovalIn: pointRect)
//            UIColor.blue.setFill()
            IntervalDotPlotView.lapisLazuli.setFill()
            path.fill()
            
            yPos += Constants.pointsBoxHeight / 2.0 + Constants.verticalSpacing
            if minValueLabel == nil {
                minValueLabel = initLabel()
            }

            configureLabel(minValueLabel!, text: minValueText!, x: paddedRect.midX, y: yPos, textAnchor: .TopCenter, fontSize: Constants.numberFontSize, textColor: UIColor.black, textAlignment: NSTextAlignment.center)


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
            let maxValueText = numberFormatter.string(for: (minMaxAvg.max / TimeConstants.SECONDS_PER_DAY))
            let avgValueText = numberFormatter.string(for: minMaxAvg.avg / TimeConstants.SECONDS_PER_DAY)

            let availableWidth = paddedRect.width
            let minValueTextSize = measureText(label: minValueText!, fontSize: Constants.numberFontSize)
            let maxValueTextSize = measureText(label: maxValueText!, fontSize: Constants.numberFontSize)
            
            let usableWidth = availableWidth - (minValueTextSize.width / 2.0) - (maxValueTextSize.width / 2.0)
            let intervalRange = minMaxAvg.max - minMaxAvg.min
            let ptPerPixel = usableWidth / CGFloat(intervalRange)

            let avgX = paddedRect.minX + (minValueTextSize.width / 2.0) + CGFloat(minMaxAvg.avg - minMaxAvg.min) * ptPerPixel
            
            var yPos = Constants.topBottomPadding
            
            let avgLabelSize = configureLabel(avgValueLabel!, text: avgValueText!, x: avgX, y: yPos, textAnchor: .TopCenter, fontSize: Constants.numberFontSize, textColor: IntervalDotPlotView.lapisLazuli, textAlignment: NSTextAlignment.center)
            
            yPos += avgLabelSize.height
            // Avg triangle
            drawTriangle(x: avgX, y: yPos)

            yPos += Constants.triangleHeight
            yPos += Constants.verticalSpacing
            yPos += Constants.pointsBoxHeight / 2.0
            
            drawBox(x: paddedRect.minX + (minValueTextSize.width / 2.0) - Constants.pointsBoxHeight / 2.0, y: yPos, width: usableWidth + Constants.pointsBoxHeight, height: Constants.pointsBoxHeight)

            // Last one should be full
            var alpha:CGFloat = 0.1
            let alphaDelta:CGFloat = 0.9 / CGFloat(intervals!.count - 1)
            
            for intervalValue in intervals! {
                let x = paddedRect.minX + (minValueTextSize.width / 2.0) + CGFloat(intervalValue - minMaxAvg.min) * ptPerPixel
                let pointRect = CGRect(x: x - Constants.pointRadius, y: yPos - Constants.pointRadius, width: Constants.pointDiameter, height: Constants.pointDiameter)
                let path = UIBezierPath(ovalIn: pointRect)
//                UIColor.blue.setFill()
                IntervalDotPlotView.lapisLazuli.setFill()
                path.fill(with: .normal, alpha: alpha)
                alpha += alphaDelta
            }

            yPos += Constants.pointsBoxHeight / 2.0 + Constants.verticalSpacing
            
            configureLabel(minValueLabel!, text: minValueText!, x: paddedRect.minX, y: yPos, textAnchor: .TopLeft, fontSize: Constants.numberFontSize, textColor: UIColor.black, textAlignment: NSTextAlignment.left)
            configureLabel(maxValueLabel!, text: maxValueText!, x: paddedRect.maxX, y: yPos, textAnchor: .TopRight, fontSize: Constants.numberFontSize, textColor: UIColor.black, textAlignment: NSTextAlignment.left)
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
    
    private func measureText(label:String, fontSize: CGFloat, bold:Bool = false) -> CGSize {
        let systemFont = createFont(fontSize: fontSize, bold: bold)
        let attributes = [NSAttributedString.Key.font: systemFont]
        return NSString(string: label).size(withAttributes: attributes)
    }
    
    
    @discardableResult
    private func configureLabel(_ label:UILabel, text:String, x: CGFloat, y: CGFloat, textAnchor:UILabel.TextAnchor = .BottomLeft, fontSize:CGFloat = 16.0, textColor:UIColor = UIColor.blue, textAlignment:NSTextAlignment = NSTextAlignment.left) -> CGRect {
        let systemFont = createFont(fontSize: fontSize, bold: false)
        label.configure(text: text, font: systemFont, color: textColor, alignment: textAlignment)
        return label.updateFrame(x: x, y: y, textAnchor: textAnchor)
    }
    
    private func drawTriangle(x:CGFloat, y: CGFloat) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: x - Constants.triangleWidth, y: y) )
        path.addLine(to: CGPoint(x: x + Constants.triangleWidth, y: y ) )
        path.addLine(to: CGPoint(x: x, y: y + Constants.triangleHeight) )
        path.closeSubpath()
        
        let triangle = UIBezierPath(cgPath: path)
//        UIColor.blue.setFill()
        IntervalDotPlotView.lapisLazuli.setFill()
        triangle.fill()

    }
    
    private func drawBox(x:CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let dotBorder = CGRect(x: x, y: y - height / 2.0, width: width, height: height)
        let dotBorderCurve = UIBezierPath(rect: dotBorder)
        dotBorderCurve.lineWidth = 1.0
        UIColor.lightGray.setStroke()
//        let lightYellow = UIColor(red: 250.0/255.0, green: 212.0/255.0, blue: 142.0/255.0, alpha: 1.0)
//        lightYellow.setFill()
        dotBorderCurve.stroke()
//        dotBorderCurve.fill()
    }
    
    private func createFont(fontSize: CGFloat, bold:Bool) -> UIFont {
        var descriptor = UIFontDescriptor(name: "Avenir", size: fontSize)
        if bold {
            descriptor = descriptor.withSymbolicTraits(.traitBold) ?? descriptor
        }
        return UIFont(descriptor: descriptor, size: fontSize)
    }

    
    private func padRect(_ rect:CGRect) -> CGRect {
        
        return CGRect(x: rect.minX + Constants.leftRightPadding, y: rect.minY + Constants.topBottomPadding, width: rect.width - (2 * Constants.leftRightPadding), height: rect.height - (2 * Constants.topBottomPadding))
    }
}
