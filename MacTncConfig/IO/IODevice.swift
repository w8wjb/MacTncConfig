//
//  IODevice.swift
//  Mobilinkd TNC Configuration
//
//  Created by Weston Bustraan on 6/18/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//


import Foundation

class IODevice: NSObject {
    
    @objc let name: String
    @objc let baseName: String
    @objc let suffix: String
    @objc let path: String
    
    init(name: String, baseName: String, suffix: String, path: String) {
        self.name = name
        self.baseName = baseName
        self.suffix = suffix
        self.path = path
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let that = object as? IODevice else {
            return false
        }
        
        return self == that
    }
    
}

extension IODevice {
    static func == (left: IODevice, right: IODevice) -> Bool {
        return left.path == right.path
    }
}
