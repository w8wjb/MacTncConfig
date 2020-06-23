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
import CleanroomLogger

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let connection = MobilinkdTncConnection()
    //    let connection = DummyConnection()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        

        // Setup logging config
        let logConfig = XcodeLogConfiguration(debugMode: true,
                                              stdStreamsMode: .useExclusively,
                                              mimicOSLogOutput: false)
        Log.enable(configuration: logConfig)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {        
        try? connection.stop()
    }

    
}
