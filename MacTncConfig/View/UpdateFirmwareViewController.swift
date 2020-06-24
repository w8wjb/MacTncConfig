//
//  UpdateFirmwareViewController.swift
//  Mobilinkd TNC Configuration
//
//  Created by Weston Bustraan on 6/18/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Cocoa

class UpdateFirmwareViewController: NSViewController {
    
    @objc dynamic weak var connection: MobilinkdTncConnection!
    
    @objc dynamic var firmwareFilepath = "" {
        didSet {
            validateFile()
        }
    }
    
    @objc dynamic var progress = 0
    
    @objc dynamic var readyToStart = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.connection = (NSApplication.shared.delegate as! AppDelegate).connection
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func validateFile() {
        
        if firmwareFilepath.isEmpty {
            readyToStart = false
            return
        }
        
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: firmwareFilepath, isDirectory: &isDir) else {
            readyToStart = false
            return
        }
        
        if isDir.boolValue {
            readyToStart = false
            return
        }
         
        readyToStart = true
        
    }
    
    @IBAction func browseFile(_ sender: NSButton) {
        
        let openPanel = NSOpenPanel()
        openPanel.title = "Select Firmware"
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["hex", "elf"]
        
        
        openPanel.beginSheetModal(for: self.view.window!) { (response) in
            if response == .OK {
                if let url = openPanel.url {
                    self.firmwareFilepath = url.path
                }
            }
        }
        
    }
    
    
    @IBAction func doUpdateFirmware(_ sender: Any) {
        // TODO: Implement firmware updating
    }
    
    
}
