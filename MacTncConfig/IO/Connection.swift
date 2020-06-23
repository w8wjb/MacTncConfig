//
//  Connection.swift
//  MacTncConfig
//
//  Created by Weston Bustraan on 6/13/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Foundation

class Connection: NSObject {
    
    static let connectionStatusError = NSNotification.Name("tnc.connectionStatusError")
    static let connectionStatusStopped = NSNotification.Name("tnc.connectionStatusStopped")
    static let connectionStatusStarting = NSNotification.Name("tnc.connectionStatusStarting")
    static let connectionStatusStopping = NSNotification.Name("tnc.connectionStatusStopping")
    static let connectionStatusStarted = NSNotification.Name("tnc.connectionStatusStarted")
    
    enum Status: Int8 {
        case error = -2
        case unconfigured = -1
        case stopped = 0
        case starting = 1
        case stopping = 2
        case started = 3
    }
    
    @objc dynamic var dynamicStatus = Status.unconfigured.rawValue
    
    @objc dynamic var connected = false
    
    var status = Status.stopped {
        didSet {
            
            guard oldValue != status else {
                // No need to post notifications if the status did not change
                return
            }
            
            if status == .started {
                connected = true
            } else {
                connected = false
            }
            
            dynamicStatus = status.rawValue
            
            var name: NSNotification.Name
            switch status {
            case .error:
                name = Connection.connectionStatusError
            case .stopped:
                name = Connection.connectionStatusStopped
            case .starting:
                name = Connection.connectionStatusStarting
            case .stopping:
                name = Connection.connectionStatusStopping
            case .started:
                name = Connection.connectionStatusStarted
            default:
                return
            }
            
            NotificationCenter.default.post(name: name, object: self)
        }
    }
    
    
    func toggleStatus() throws {
        
        do {
            switch status {
            case .error, .stopped, .stopping:
                try start()
            case .started, .starting:
                try stop();
            default:
                break
            }
        } catch {
            status = .error
            throw error
        }
    }
    
    
    func initChannel() throws {
        
    }
    
    /**
     * Start the connection
     */
    func start() throws {
        
        if (status == .started || status == .starting) {
            return
        }
        
        status = .starting
        
        try initChannel()
        status = .started
    }
    
    
    /**
     * Stop the connection
     */
    func stop() throws {
        
        if (status == .stopping || status == .stopped) {
            return
        }
        
        status = .stopping
        try shutdownChannel()
        status = .stopped
        
    }
    
    func shutdownChannel() throws {
        
    }
    
}
