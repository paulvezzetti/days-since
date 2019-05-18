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
        static let pointRadius: CGFloat = 4.0
    }
    
    var intervals:[Double]?
    
    
    private func calculateMinMaxAvg() -> (Double, Double, Double) {
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
        
        let background = UIBezierPath(roundedRect: rect, cornerRadius: 12)
        let backColor = UIColor(named: "Header")
        backColor?.setFill()
        background.fill()
        
        let minMaxAvg = calculateMinMaxAvg()
        if minMaxAvg.0 == 0.0 && minMaxAvg.1 == 0.0 && minMaxAvg.2 == 0 {
            // Special case for no data
            // Draw a single dot in the center with text below stating
            // that there a no points
            // TODO: Check that point isn't bigger than 'rect'
            let pointRect = CGRect(x: paddedRect.midX - 4, y: paddedRect.midY - 4, width: 8, height: 8)
            let path = UIBezierPath(ovalIn: pointRect)
            UIColor.blue.setFill()
            path.fill()
            
//            let textLayer = CATextLayer()
//            textLayer.frame = CGRect(x: rect.maxX - 40, y: 0, width: 100, height: rect.height)
//            textLayer.font = UIFont.systemFont(ofSize: 0.25)
//            textLayer.foregroundColor = UIColor.black.cgColor
//            textLayer.string = "min"
//            textLayer.contentsScale = UIScreen.main.scale
//            self.layer.addSublayer(textLayer)
            
            let label = UILabel(frame: CGRect(x: paddedRect.minX + 5, y: paddedRect.maxY - 20, width: paddedRect.width - 5, height: 10))
            label.text = "min"
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor.blue
            addSubview(label)

        } else if minMaxAvg.0 == minMaxAvg.1 && minMaxAvg.1 == minMaxAvg.2 {
            // In this case, there is data, but they are all the same, non-zero value
            // Draw a single dot, with the value below it.
            let pointRect = CGRect(x: paddedRect.midX - 4, y: paddedRect.midY - 4, width: 8, height: 8)
            let path = UIBezierPath(ovalIn: pointRect)
            UIColor.blue.setFill()
            path.fill()
        } else {
            let availableWidth = paddedRect.width
            let usableWidth = availableWidth // - 10.0 // add some space for margin
         //   let availableHeight = rect.height
         //   let usableHeight = availableHeight - 5.0 // Margin
            
            let intervalRange = minMaxAvg.1 - minMaxAvg.0
            let ptPerPixel = usableWidth / CGFloat(intervalRange)
            
            // Assume this is oldest to newest. // TODO: Verify
            // Last one should be full
            var alpha:CGFloat = 0.1
            let alphaDelta:CGFloat = 0.9 / CGFloat(intervals!.count - 1)
            
            for intervalValue in intervals! {
                let x = Constants.leftRightPadding + CGFloat(intervalValue - minMaxAvg.0) * ptPerPixel
                let pointRect = CGRect(x: x - 4, y: paddedRect.midY - 4, width: 8, height: 8)
                let path = UIBezierPath(ovalIn: pointRect)
                UIColor.blue.setFill()
                path.fill(with: .normal, alpha: alpha)
                alpha += alphaDelta
            }
            
//            let textLayer = CATextLayer()
//            textLayer.frame = CGRect(x: rect.maxX - 20, y: 0, width: 30, height: rect.height)
//            textLayer.font = UIFont.systemFont(ofSize: 8)
//            textLayer.foregroundColor = UIColor.black.cgColor
//            textLayer.string = "min"
//            textLayer.contentsScale = UIScreen.main.scale
//            self.layer.addSublayer(textLayer)
            
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 1
            
            let minValueText = numberFormatter.string(for: (minMaxAvg.0 / TimeConstants.SECONDS_PER_DAY))
            let systemFont = UIFont.systemFont(ofSize: 12)
            let attributes = [NSAttributedString.Key.font: systemFont]
            let minSize = NSString(string: minValueText!).size(withAttributes: attributes)
            
            let minLabel = UILabel(frame: CGRect(x: paddedRect.minX, y: paddedRect.maxY - minSize.height, width: minSize.width, height: minSize.height))
            minLabel.text = minValueText //numberFormatter.string(for: (minMaxAvg.0 / TimeConstants.SECONDS_PER_DAY))
            minLabel.font = systemFont
            minLabel.textColor = UIColor.blue
            addSubview(minLabel)

            let maxValueText = numberFormatter.string(for: (minMaxAvg.1 / TimeConstants.SECONDS_PER_DAY))
            let maxSize = NSString(string: maxValueText!).size(withAttributes: attributes)
            let maxLabel = UILabel(frame: CGRect(x: paddedRect.maxX - maxSize.width, y: paddedRect.maxY - maxSize.height, width: maxSize.width, height: maxSize.height))
            maxLabel.text = maxValueText
            maxLabel.font = UIFont.systemFont(ofSize: 12)
            maxLabel.textColor = UIColor.blue
            maxLabel.textAlignment = NSTextAlignment.right
            addSubview(maxLabel)

            let avgValueText = numberFormatter.string(for: minMaxAvg.2 / TimeConstants.SECONDS_PER_DAY)
            let avgSize = NSString(string: avgValueText!).size(withAttributes: attributes)
            let avgX = 5 + CGFloat(minMaxAvg.2 - minMaxAvg.0) * ptPerPixel
            let avgLabel = UILabel(frame: CGRect(x: avgX - avgSize.width / 2, y: 0, width: avgSize.width, height: avgSize.height))
            avgLabel.text = avgValueText
            avgLabel.font = UIFont.systemFont(ofSize: 12)
            avgLabel.textColor = UIColor.red
            addSubview(avgLabel)
            
            // Avg triangle
            let path = CGMutablePath()
            path.move(to: CGPoint(x: avgX - 4, y: avgSize.height + 2) )
            path.addLine(to: CGPoint(x: avgX + 4, y: avgSize.height + 2) )
            path.addLine(to: CGPoint(x: avgX, y: avgSize.height + 6) )
            path.closeSubpath()
            
            let triangle = UIBezierPath(cgPath: path)
            UIColor.red.setFill()
            triangle.fill()
            
        }
        
    }

    
    func padRect(_ rect:CGRect) -> CGRect {
        
        return CGRect(x: rect.minX + Constants.leftRightPadding, y: rect.minY + Constants.topBottomPadding, width: rect.width - (2 * Constants.leftRightPadding), height: rect.height - (2 * Constants.topBottomPadding))
    }
}
