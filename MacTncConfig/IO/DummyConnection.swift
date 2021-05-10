//
//  DummyConnection.swift
//  MacTncConfig
//
//  Created by Weston Bustraan on 6/13/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//


import Foundation

/**
 *
 */
class DummyConnection: MobilinkdTncConnection {
    
    private var timer: Timer!
    private var counter = 0
    
    override init() {
        super.init()
        initialize()
    }
    
    private func initialize() {
        status = .stopped
    }
    
    override func start() throws {
        
        if (status == .started || status == .starting) {
            return
        }

        logger.info("Starting dummy connection")
        status = .starting
        
        try initChannel()
        
    }
    
    
    override func initChannel() throws {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            logger.info("Started dummy connection")
            
            self.hardwareVersion = "D1"
            self.firmwareVersion = "0.1.2.3"
            self.macAddress = "00:11:22:33:44:55"
            self.serialNumber = "ABCDEF"
            self.dateTime = Date()
            
            self.status = .started
        }
    }
    
    override func stop() throws {
        if (status == .stopping || status == .stopped) {
            return
        }

        logger.info("Stopping dummy connection")
        status = .stopping
        
        try shutdownChannel()
        
        if let timer = self.timer {
            timer.invalidate()
        }
        timer = nil
    }
    
    override func shutdownChannel() throws {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
            logger.info("Stopped dummy connection")

            self.hardwareVersion = ""
            self.firmwareVersion = ""
            self.macAddress = ""
            self.serialNumber = ""
            self.dateTime = nil

            self.status = .stopped
        }
    }
    
    override func reset() {
        counter = 0
    }
    
    
    func sendPacket() {
    }
    
    
}
