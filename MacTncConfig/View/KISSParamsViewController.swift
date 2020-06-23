//
//  KISSParamsViewController.swift
//  Mobilinkd TNC Configuration
//
//  Created by Weston Bustraan on 6/13/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Cocoa

class KISSParamsViewController: NSViewController {
        
    @objc dynamic weak var connection: MobilinkdTncConnection!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.connection = (NSApplication.shared.delegate as! AppDelegate).connection
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
