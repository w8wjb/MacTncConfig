//
//  KissCommand.swift
//  MacTncConfig
//
//  Created by Weston Bustraan on 6/13/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Foundation

struct KissComand: CustomStringConvertible {
    
    public typealias Element = UInt8
    
    static let data: UInt8 = 0
    static let txDelay: UInt8 = 1
    static let persist: UInt8 = 2
    static let slot: UInt8 = 3
    static let txTail: UInt8 = 4
    static let duplex: UInt8 = 5
    static let hardware: UInt8 = 6
    
    let command: UInt8
    let subcommand: UInt8?
    let data: Data
    
    var value: UInt8 {
        return data[0]
    }
    
    /**
     * Gets the value of the KISS command converted to the specified type
     *  - Parameter type: Type to return value as
     *  - Parameter sourceByteOrder: byte order that the KISS payload is expected to be in. Defaults to big endian
     */
    func value<T>(as type: T.Type, sourceByteOrder: ByteOrder = .bigEndian) -> T {
        let byteCount = MemoryLayout<T>.size
        assert(data.count >= byteCount)
        var bytes = data.prefix(byteCount)
        if byteCount > 1 && ByteOrder.current() != sourceByteOrder {
            bytes.reverse()
        }
        return bytes.withUnsafeBytes { $0.bindMemory(to: type)[0] }
    }
    
    /**
     * Returns the KISS command payload as a UTF-8 string
     */
    var message: String? {
        return String(bytes: data, encoding: String.Encoding.utf8)
    }
    
    var description: String {
        let cmd = command
        let payload = message ?? data.hexEncoded
        
        if let subcmd = subcommand {
            return "KISS Command: \(cmd):\(subcmd) - \(payload)"
        }
        return "KISS Command: \(cmd) - \(payload)"
        
    }
    
    init(command: UInt8, subcommand: UInt8? = nil, value: UInt8?) {
        self.command = command
        self.subcommand = subcommand
        if let value = value {
            self.data = Data([value])
        } else {
            self.data = Data()
        }
    }
    
    init(command: UInt8, subcommand: UInt8? = nil, data: Data?) {
        self.command = command
        self.subcommand = subcommand
        self.data = data ?? Data()
    }
    
}
