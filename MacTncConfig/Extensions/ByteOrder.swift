//
//  ByteOrder.swift
//  Mobilinkd TNC Configuration
//
//  Created by Weston Bustraan on 6/20/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Foundation


enum ByteOrder: CFByteOrder {
    case unknown = 0 // CFByteOrderUnknown
    case littleEndian = 1 // CFByteOrderLittleEndian
    case bigEndian = 2 // CFByteOrderBigEndian
    
    static func current() -> ByteOrder {
        return ByteOrder(rawValue: CFByteOrderGetCurrent())!
            
    }
}
