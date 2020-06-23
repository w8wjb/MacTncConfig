//
//  BatteryLevelValueTransformer.swift
//  Mobilinkd TNC Configuration
//
//  Created by Weston Bustraan on 6/19/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Foundation

class BatteryLevelValueTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        
        guard let levelNumber = value as? NSNumber else {
          return nil
        }
        
        let rawLevel = levelNumber.doubleValue
        return min(max(0, rawLevel - 3300.0) / 90.0, 10.0)
    }
    
}
