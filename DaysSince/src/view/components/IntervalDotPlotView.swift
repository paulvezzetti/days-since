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
        static let LeftRightPadding: CGFloat = 10.0
        static let TopBottomPadding: CGFloat = 3.0
        static let VerticalSpacing: CGFloat = 2.0
        static let PointRadius: CGFloat = 6.0
        static let PointDiameter: CGFloat = Constants.PointRadius * 2.0
        static let TriangleHeight: CGFloat = 9.0
        static let TriangleWidth: CGFloat = 6.0
        static let DotPlotVerticalPadding: CGFloat = 2.0
        static let DotPlotBoxHeight: CGFloat = Constants.PointDiameter + 2.0 * Constants.DotPlotVerticalPadding
        static let HalfDotPlotBoxHeight: CGFloat = Constants.DotPlotBoxHeight / 2.0
        
        static let NumberFontSize: CGFloat = 20.0
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
    private var minLabel:UILabel?
    private var maxLabel:UILabel?
    
    
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
        
//        let background = UIBezierPath(roundedRect: rect, cornerRadius: 12)
//        let backColor = UIColor(named: "Header")
//        backColor?.setFill()
//        background.fill()
        
        let minMaxAvg = calculateMinMaxAvg()
        if minMaxAvg.min == 0.0 && minMaxAvg.max == 0.0 && minMaxAvg.avg == 0 {
            // Special case for no data. Just show a label with an error message
            clearLabel(maxValueLabel)
            clearLabel(avgValueLabel)
            clearLabel(minLabel)
            clearLabel(maxLabel)
            if minValueLabel == nil {
                minValueLabel = initLabel()
            }
            configureLabel(minValueLabel!, text: "No interval data available", x: paddedRect.midX, y: paddedRect.midY, textAnchor: .MiddleCenter, fontSize: Constants.NumberFontSize, textColor: UIColor.black, textAlignment: NSTextAlignment.center)
        } else if minMaxAvg.min == minMaxAvg.max && minMaxAvg.max == minMaxAvg.avg {
            // In this case, there is data, but they are all the same, non-zero value
            
            var yPos = Constants.TopBottomPadding

            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 1
            let minValueText = numberFormatter.string(for: (minMaxAvg.min / TimeConstants.SECONDS_PER_DAY))

            clearLabel(maxValueLabel)
            clearLabel(minLabel)
            clearLabel(maxLabel)
            if avgValueLabel == nil {
                avgValueLabel = initLabel()
            }
            let avgLabelSize = configureLabel(avgValueLabel!, text: minValueText!, x: paddedRect.midX, y: yPos, textAnchor: .TopCenter, fontSize: Constants.NumberFontSize, textColor: IntervalDotPlotView.lapisLazuli, textAlignment: NSTextAlignment.center)
            yPos += avgLabelSize.height

            // Avg triangle
            drawTriangle(x: paddedRect.midX, y: yPos)

            yPos += Constants.TriangleHeight + Constants.VerticalSpacing + Constants.HalfDotPlotBoxHeight
            
            drawBox(x: paddedRect.minX + Constants.LeftRightPadding, y: yPos, width: paddedRect.width - (2.0 * Constants.LeftRightPadding), height: Constants.DotPlotBoxHeight)

            // Draw a single dot, with the value below it.
            drawDot(x: paddedRect.midX, y: yPos)
            
            yPos += Constants.HalfDotPlotBoxHeight + Constants.VerticalSpacing
            if minValueLabel == nil {
                minValueLabel = initLabel()
            }

            configureLabel(minValueLabel!, text: minValueText!, x: paddedRect.midX, y: yPos, textAnchor: .TopCenter, fontSize: Constants.NumberFontSize, textColor: UIColor.black, textAlignment: NSTextAlignment.center)


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
            if minLabel == nil {
                minLabel = initLabel()
            }
            if maxLabel == nil {
                maxLabel = initLabel()
            }
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 1

            let minValueText = numberFormatter.string(for: (minMaxAvg.min / TimeConstants.SECONDS_PER_DAY))
            let maxValueText = numberFormatter.string(for: (minMaxAvg.max / TimeConstants.SECONDS_PER_DAY))
            let avgValueText = numberFormatter.string(for: minMaxAvg.avg / TimeConstants.SECONDS_PER_DAY)

            let availableWidth = paddedRect.width
            let minValueTextSize = measureText(label: minValueText!, fontSize: Constants.NumberFontSize)
            let maxValueTextSize = measureText(label: maxValueText!, fontSize: Constants.NumberFontSize)
            
            let usableWidth = availableWidth - (minValueTextSize.width / 2.0) - (maxValueTextSize.width / 2.0)
            let intervalRange = minMaxAvg.max - minMaxAvg.min
            let ptPerPixel = usableWidth / CGFloat(intervalRange)

            let avgX = paddedRect.minX + (minValueTextSize.width / 2.0) + CGFloat(minMaxAvg.avg - minMaxAvg.min) * ptPerPixel
            
            var yPos = Constants.TopBottomPadding
            
            let avgLabelSize = configureLabel(avgValueLabel!, text: avgValueText!, x: avgX, y: yPos, textAnchor: .TopCenter, fontSize: Constants.NumberFontSize, textColor: IntervalDotPlotView.lapisLazuli, textAlignment: NSTextAlignment.center)
            
            yPos += avgLabelSize.height
            // Avg triangle
            drawTriangle(x: avgX, y: yPos)

            yPos += Constants.TriangleHeight + Constants.VerticalSpacing + Constants.HalfDotPlotBoxHeight
            
            drawBox(x: paddedRect.minX + (minValueTextSize.width / 2.0) - Constants.HalfDotPlotBoxHeight, y: yPos, width: usableWidth + Constants.DotPlotBoxHeight, height: Constants.DotPlotBoxHeight)

            // Last one should be full
            var alpha:CGFloat = 0.1
            let alphaDelta:CGFloat = 0.9 / CGFloat(intervals!.count - 1)
            
            for intervalValue in intervals! {
                let x = paddedRect.minX + (minValueTextSize.width / 2.0) + CGFloat(intervalValue - minMaxAvg.min) * ptPerPixel
                drawDot(x: x, y: yPos, alpha: alpha)
                alpha += alphaDelta
            }

            yPos += Constants.HalfDotPlotBoxHeight + Constants.VerticalSpacing
            
            let minValueLabelSize = configureLabel(minValueLabel!, text: minValueText!, x: paddedRect.minX, y: yPos, textAnchor: .TopLeft, fontSize: Constants.NumberFontSize, textColor: UIColor.black, textAlignment: NSTextAlignment.left)
            let maxValueLabelSize = configureLabel(maxValueLabel!, text: maxValueText!, x: paddedRect.maxX, y: yPos, textAnchor: .TopRight, fontSize: Constants.NumberFontSize, textColor: UIColor.black, textAlignment: NSTextAlignment.left)
            
            yPos += max(minValueLabelSize.height, maxValueLabelSize.height)
            configureLabel(minLabel!, text: "(min)", x: paddedRect.minX, y: yPos, textAnchor: .TopLeft, fontSize: 12.0, textColor: UIColor.gray, textAlignment: NSTextAlignment.left)
            configureLabel(maxLabel!, text: "(max)", x: paddedRect.maxX, y: yPos, textAnchor: .TopRight, fontSize: 12.0, textColor: UIColor.gray, textAlignment: NSTextAlignment.left)
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
        path.move(to: CGPoint(x: x - Constants.TriangleWidth, y: y) )
        path.addLine(to: CGPoint(x: x + Constants.TriangleWidth, y: y ) )
        path.addLine(to: CGPoint(x: x, y: y + Constants.TriangleHeight) )
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
    
    func drawDot(x:CGFloat, y: CGFloat, alpha: CGFloat = 1.0) {
        let pointRect = CGRect(x: x - Constants.PointRadius, y: y - Constants.PointRadius, width: Constants.PointDiameter, height: Constants.PointDiameter)
        let path = UIBezierPath(ovalIn: pointRect)
        IntervalDotPlotView.lapisLazuli.setFill()
        path.fill(with: .normal, alpha: alpha)
    }
    
    private func createFont(fontSize: CGFloat, bold:Bool) -> UIFont {
        var descriptor = UIFontDescriptor(name: "Avenir", size: fontSize)
        if bold {
            descriptor = descriptor.withSymbolicTraits(.traitBold) ?? descriptor
        }
        return UIFont(descriptor: descriptor, size: fontSize)
    }

    
    private func padRect(_ rect:CGRect) -> CGRect {
        
        return CGRect(x: rect.minX + Constants.LeftRightPadding, y: rect.minY + Constants.TopBottomPadding, width: rect.width - (2 * Constants.LeftRightPadding), height: rect.height - (2 * Constants.TopBottomPadding))
    }
}
