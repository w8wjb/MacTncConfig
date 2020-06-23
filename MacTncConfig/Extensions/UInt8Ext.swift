//
//  UInt8Ext.swift
//  Mobilinkd TNC Configuration
//
//  Created by Weston Bustraan on 6/19/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Foundation

extension UInt8 {
    
    func decodeBCD() -> Int {
        return Int(((Double(self) / 16) * 10) + Double(self & 0x0F))
    }
    
}
