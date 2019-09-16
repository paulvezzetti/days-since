//
//  JSONImportManager.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 9/15/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

class JSONImportManager {
    
    
    func buildBaseModel(from url:URL) -> BaseModel? {
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let result = try decoder.decode(BaseModel.self, from: jsonData)
            if result.activities.count > 0 {
                return result
            }
            
        } catch {
            
        }
        
        return nil
    }
    
    
}
