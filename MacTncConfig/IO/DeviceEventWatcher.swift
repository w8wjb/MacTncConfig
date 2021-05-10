//
//  DeviceEventWatcher.swift
//  Mobilinkd TNC Configuration
//
//  Created by Weston Bustraan on 6/18/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Foundation
import IOKit
import IOKit.usb
import IOKit.serial

protocol DeviceWatcherDelegate {
    func deviceAdded(_ device: IODevice)
    func deviceRemoved(_ device: IODevice)
}

/**
 * Watches for serial (USB) devices that are added or removed and notifies delegate
 */
class DeviceEventWatcher {
    
    let delegate: DeviceWatcherDelegate
    
    fileprivate let notificationPort = IONotificationPortCreate(kIOMasterPortDefault)
    fileprivate var addedIterator: io_iterator_t = 0
    fileprivate var removedIterator: io_iterator_t = 0
    
    init(delegate: DeviceWatcherDelegate) {
        self.delegate = delegate
        
        let query = IOServiceMatching(kIOSerialBSDServiceValue) as NSMutableDictionary
        
        let opaqueSelf = Unmanaged.passUnretained(self).toOpaque()
        
        IOServiceAddMatchingNotification(notificationPort, kIOMatchedNotification, query, handleDeviceNotification, opaqueSelf, &addedIterator)
        
        handleDeviceNotification(instance: opaqueSelf, addedIterator)
        
        IOServiceAddMatchingNotification(notificationPort, kIOTerminatedNotification, query, handleDeviceNotification, opaqueSelf, &removedIterator)
        
        handleDeviceNotification(instance: opaqueSelf, removedIterator)
        
        let runLoopSource = IONotificationPortGetRunLoopSource(notificationPort).takeUnretainedValue()
        
        // Add the notification to the main run loop to receive future updates.
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        
    }
    
    deinit {
        IOObjectRelease(addedIterator)
        IOObjectRelease(removedIterator)
        IONotificationPortDestroy(notificationPort)
    }
    
}

fileprivate func handleDeviceNotification(instance: UnsafeMutableRawPointer?, _ iterator: io_iterator_t) {
    let watcher = Unmanaged<DeviceEventWatcher>.fromOpaque(instance!).takeUnretainedValue()
    
    let handler: ((IODevice) -> Void)?
    
    switch iterator {
    case watcher.addedIterator: handler = watcher.delegate.deviceAdded
    case watcher.removedIterator: handler = watcher.delegate.deviceRemoved
    default: assertionFailure("received unexpected IOIterator"); return
    }
    
    while case let device = IOIteratorNext(iterator), device != IO_OBJECT_NULL {
        
        var props : Unmanaged<CFMutableDictionary>?
        let result = IORegistryEntryCreateCFProperties(device, &props, kCFAllocatorDefault, 0)
        
        if result == KERN_SUCCESS, let props = props  {
            let properties = props.takeRetainedValue() as NSDictionary
            
            let name = properties.value(forKey: "IOTTYDevice") as? String ?? ""
            let baseName = properties.value(forKey: "IOTTYBaseName") as? String ?? ""
            let suffix = properties.value(forKey: "IOTTYSuffix") as? String ?? ""
            let path = properties.value(forKey: "IOCalloutDevice") as? String ?? ""
            
            let ioDevice = IODevice(name: name, baseName: baseName, suffix: suffix, path: path)
            
            DispatchQueue.main.async {
                handler?(ioDevice)
            }
            
        } else {
            logger.error("Could not fetch properties \(result)")
        }
        
        IOObjectRelease(device)
    }
    
    
    
}

