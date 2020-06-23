//
//  UIntToBytesConvertable.swift
//  MacTncConfig
//
//  Created by Weston Bustraan on 6/13/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Foundation

protocol UIntToBytesConvertable {
    var toBytes: [UInt8] { get }
}

extension UIntToBytesConvertable {
    func toByteArr<T: BinaryInteger>(endian: T, count: Int) -> [UInt8] {
        var _endian = endian
        let bytePtr = withUnsafePointer(to: &_endian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        return [UInt8](bytePtr)
    }
}

extension UInt16: UIntToBytesConvertable {
    var toBytes: [UInt8] {
        return toByteArr(endian: self.littleEndian,
                         count: MemoryLayout<UInt16>.size)
    }
}

extension UInt32: UIntToBytesConvertable {
    var toBytes: [UInt8] {
        return toByteArr(endian: self.littleEndian,
                         count: MemoryLayout<UInt32>.size)
    }
}

extension UInt64: UIntToBytesConvertable {
    var toBytes: [UInt8] {
        return toByteArr(endian: self.littleEndian,
                         count: MemoryLayout<UInt64>.size)
    }
}

extension Int16: UIntToBytesConvertable {
    var toBytes: [UInt8] {
        return toByteArr(endian: self.littleEndian,
                         count: MemoryLayout<Int16>.size)
    }
}
