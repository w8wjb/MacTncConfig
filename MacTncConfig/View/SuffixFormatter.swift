//
//  SuffixFormatter.swift
//  Mobilinkd TNC Configuration
//
//  Created by Weston Bustraan on 6/22/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Foundation

/**
 * Appends the specified suffix string to the number, once it has been formatted
 */
class SuffixFormatter: NumberFormatter {
    
    var suffix: String?
    
    override func string(for obj: Any?) -> String? {
        
        let numString = super.string(for: obj)
        
        if let suffix = self.suffix {
            return "\(numString ?? "") \(suffix)"
        }
        return numString
    }
    
}
