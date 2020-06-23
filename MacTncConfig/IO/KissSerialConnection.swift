//
//  KissSerialConnection.swift
//  MacTncConfig
//
//  Created by Weston Bustraan on 6/13/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Foundation
import IOKit
import CleanroomLogger

class KissSerialConnection: Connection, KissConnection, ChannelDelegate {
    
    let MIN_PACKET_SIZE = 1
    
    @objc dynamic var devicePath: String?
    
    @objc dynamic var baud = 38400
    
      /** time between keying the radio and sending data, in milliseconds. The default start-up value is 50 (i.e., 500 ms). */
    @objc dynamic var txDelay: UInt8 = 50
    
    /**
     * the  persistence parameter,  p, scaled to the range 0 - 255 with the following formula: P = p * 256 - 1
     *
     * http://www.ax25.net/kiss.aspx
     */
    @objc dynamic var persistence: UInt8 = 63
    
    /**  slot interval in 10 ms units. */
    @objc dynamic var slotTime: UInt8 = 10
    
    /** time to hold up the TX after the FCS has been sent, in 10 ms units.  This command is obsolete, and is included  here only for  compatibility  with  some existing  implementations.*/
    @objc dynamic var txTail: UInt8 = 10
    
    @objc dynamic var duplex = false
    
    internal let queue: DispatchQueue
    
    private var channel: DispatchIO?
    private var deviceFile: FileHandle?
    
    private lazy var codec: KissCodec = {
        return KissCodec(connection: self, delegate: self)
    }()
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case devicePath = "devicePath"
        case baud = "baud"
    }
    
    override init() {
        
        queue = DispatchQueue(label: "kissSerialConnection")
        super.init()
        self.codec = KissCodec(connection: self, delegate: self)
    }
    
    
    override func initChannel() throws {
        
        
        guard let devicePath = devicePath else {
            status = .unconfigured
            return
        }
        
        try openChannel(path: devicePath)
        try startRead()
        
        try super.initChannel()
        
        status = .started
    }
    
    override func stop() throws {
        
        if (status == .stopping || status == .stopped) {
            return
        }
        
        status = .stopping
        try shutdownChannel()
        
        // Overriding stop() so that the status is not marked as stopped
        // until after the cleanup
        //    status = .stopped
        
    }
    
    override func shutdownChannel() throws {
        guard let channel = self.channel else {
            cleanupAfterChannelClosed(0)
            return
        }
        queue.async {
            channel.close(flags: DispatchIO.CloseFlags.stop)
        }
        try super.shutdownChannel()
    }
    
    private func cleanupAfterChannelClosed(_ error: CInt) {
        self.codec.flushBuffer()
        self.channel = nil
        self.deviceFile?.closeFile()
        self.deviceFile = nil
        status = .stopped
    }
    
    private func openFile() throws -> FileHandle?  {
        
        guard let path = self.devicePath else {
            return nil
        }
        
        if let deviceFile = self.deviceFile {
            return deviceFile
        }
        
        guard let handle = FileHandle(forUpdatingAtPath: path) else {
            throw ConnectionError.ioFailed("Could not open device at path: \(path)")
        }
        deviceFile = handle
        return handle
    }
    
    private func openChannel(path: String) throws {
        
        guard self.channel == nil else {
            throw ConnectionError.ioFailed("Channel still open")
        }
        
        // Split these calls up per https://stackoverflow.com/questions/9550676/proper-disposal-of-a-grand-central-dispatch-i-o-channel
        guard let handle = try openFile() else {
            throw ConnectionError.ioFailed("Could not open device at path: \(path)")
        }
        
        setBaud(fd: handle.fileDescriptor, speed: baud)
        
        channel = DispatchIO(type: .stream, fileDescriptor: handle.fileDescriptor, queue: queue, cleanupHandler: cleanupAfterChannelClosed)
        
        // This is how I did it originally
        //    channel = DispatchIO(type: DispatchIO.StreamType.stream, path: path, oflag: O_RDWR | O_NOCTTY, mode: 0, queue: queue, cleanupHandler: cleanupAfterChannelClosed)
        
        guard let channel = self.channel else {
            throw ConnectionError.ioFailed("Channel could not be created")
        }
        
        channel.setLimit(lowWater: MIN_PACKET_SIZE)
        
    }
    
    private func startRead() throws {
        
        guard let channel = self.channel else {
            throw ConnectionError.ioFailed("Channel is not open")
        }
        
        channel.read(offset: 0, length: Int.max, queue: queue, ioHandler: handleIncomingData)
    }
    
    
    private func getBaud(fd: Int32) -> Int? {
        var options = termios()
        
        let ret = tcgetattr(fd, &options)
        if ret == -1 {
            Log.error?.message("Could not get file descriptor options")
            return nil
        }
        
        let ispeed = cfgetispeed(&options)
        return Int(ispeed)
    }
    
    func getBaud() throws -> Int? {
        
        if let channel = self.channel {
            if channel.fileDescriptor > -1 {
                return getBaud(fd: channel.fileDescriptor)
            }
        }
        
        if let handle = try openFile() {
            defer {
                handle.closeFile()
            }
            return getBaud(fd: handle.fileDescriptor)
        }
        return nil
    }
    
    func setBaud(speed: Int) throws {
        if let channel = self.channel {
            if channel.fileDescriptor > -1 {
                return setBaud(fd: channel.fileDescriptor, speed: speed)
            }
        }
        
        if let handle = try openFile() {
            defer {
                handle.closeFile()
            }
            
            return setBaud(fd: handle.fileDescriptor, speed: speed)
        }
    }
    
    private func setBaud(fd: Int32, speed: Int) {
        var options = termios()
        
        let ret = tcgetattr(fd, &options)
        if ret == -1 {
            Log.error?.message("Could not get file descriptor options")
            return
        }
        
        
        cfsetspeed(&options, speed_t(speed))
        
        if (tcsetattr(fd, TCSANOW, &options) == -1) {
            Log.error?.message("Could not set baud")
        }
        
    }
    
    func didTransmit() {
        
    }
    
    private func handleOutgoingData(_ done: Bool, dispatchData: DispatchData?, error: Int32) {
        if done {
            if error != 0 {
                Log.error?.message("Error writing data \(error)")
            } else {
                didTransmit()
            }
        }
        
    }
    
    
    private func handleIncomingData(_ done: Bool, dispatchData: DispatchData?, error: Int32) {
        if (done) {
            do {
                codec.flushBuffer()
                try stop()
            } catch {
                Log.error?.message("\(error)")
            }
            return
        }
        
        if (done && error > 0) {
            Log.error?.message("Error reading data \(error)")
            return
        }
        
        guard let data = dispatchData else {
            Log.debug?.message("handleIncomingData received no data")
            return
        }
        
        codec.decode(data)
    }
    
    func send(data: Data) throws {
        try start()
        let encoded = codec.encode(data)
        try write(encoded: encoded)
    }
    
    private func write(encoded: Data) throws {
        let dispatchData = encoded.withUnsafeBytes { DispatchData(bytes: $0) }
        channel?.write(offset: 0, data: dispatchData, queue: queue, ioHandler: handleOutgoingData)
    }
    
    func sendCommand(cmd: KissComand) throws {
        try start()
        let encoded = codec.encodeCommand(cmd)
        try write(encoded: encoded)
    }
    
    func setTxDelay(_ value: UInt8) throws {
        try sendCommand(cmd: KissComand(command: KissComand.txDelay, value: value))
    }
    
    func setPersistence(_ value: UInt8) throws {
        try sendCommand(cmd: KissComand(command: KissComand.persist, value: value))
    }
    
    func setSlotTime(_ value: UInt8) throws {
        try sendCommand(cmd: KissComand(command: KissComand.slot, value: value))
    }
    
    func setTxTail(_ value: UInt8) throws {
        try sendCommand(cmd: KissComand(command: KissComand.txTail, value: value))
    }
    
    func setDuplex(_ duplex: Bool) throws {
        try sendCommand(cmd: KissComand(command: KissComand.duplex, value: duplex ? 1 : 0))
    }
    
    
}
