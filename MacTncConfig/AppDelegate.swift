//
//  AppDelegate.swift
//  MacTncConfig
//
//  Created by Weston Bustraan on 6/13/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Cocoa
import IOKit
import IOKit.usb
import SwiftyBeaver

let logger = SwiftyBeaver.self

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let connection = MobilinkdTncConnection()
    //    let connection = DummyConnection()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        

        
        let console = ConsoleDestination()
        console.minLevel = .debug        
        logger.addDestination(console)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {        
        try? connection.stop()
    }

    
}
