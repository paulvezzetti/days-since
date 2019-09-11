//
//  JSONWriter.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 9/9/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation


class JSONWriter {
    
    private var output:String = "";
    
    private var currentPropertyCountStack:[Int] = []
    
    
    func writeJSON() -> String {
        return "{\(output)}";
    }
    
    
    func addArray(name:String, writables:[JSONWritable]) {
        output += "\"\(name)\":["
        for (index, writable) in writables.enumerated() {
            addObject(writable: writable)
            if index < writables.count - 1 {
                output += ","
            }
        }
        output += "]"
    }
    
    func addPropertyArray(name:String, writables:[JSONWritable]) {
        incrementPropertyCount()
        addArray(name: name, writables: writables)
    }

    func addObject(writable:JSONWritable) {
        output += "{"
        currentPropertyCountStack.append(0);
        writable.writeToJSON(writer: self)
        let _ = currentPropertyCountStack.popLast();
        output += "}"
    }
    
    func addPropertyObject(name:String, writable:JSONWritable) {
//        let lastPropertyCount = currentPropertyCountStack.popLast() ?? 0
//        if lastPropertyCount > 0 {
//            output += ","
//        }
//        currentPropertyCountStack.append(lastPropertyCount + 1)
        incrementPropertyCount()
        output += "\"\(name)\":"
        addObject(writable: writable)
    }
    
    func addProperty<T: CustomStringConvertible>(name:String, property:T) {
//        let lastPropertyCount = currentPropertyCountStack.popLast() ?? 0
//        if lastPropertyCount > 0 {
//            output += ","
//        }
        incrementPropertyCount()
        
        let description = property.description
        var encoded = description.replacingOccurrences(of: "\\n", with: "\\\\n", options: .regularExpression)
//        encoded = encoded.replacingOccurrences(of: "{", with: "\\{", options: .regularExpression)
//        encoded = encoded.replacingOccurrences(of: "}", with: "\\}", options: .regularExpression)
//        encoded = encoded.replacingOccurrences(of: "[", with: "\\[", options: .regularExpression)
//        encoded = encoded.replacingOccurrences(of: "]", with: "\\]", options: .regularExpression)
//        encoded = encoded.replacingOccurrences(of: "\"", with: "\\\"", options: .regularExpression)
        output += "\"\(name)\":\"\(encoded)\""
//        currentPropertyCountStack.append(lastPropertyCount + 1)
    }
    
    private func incrementPropertyCount() {
        let lastPropertyCount = currentPropertyCountStack.popLast() ?? 0
        if lastPropertyCount > 0 {
            output += ","
        }
        let nextPropertyCount = lastPropertyCount + 1
        currentPropertyCountStack.append(nextPropertyCount)
//        return nextPropertyCount
    }
}
