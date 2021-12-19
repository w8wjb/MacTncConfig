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
        return Int(((self / 16) * 10) + (self & 0x0F))
    }
    
}
