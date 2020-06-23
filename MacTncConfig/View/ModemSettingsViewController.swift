//
//  ModemSettingsViewController.swift
//  Mobilinkd TNC Configuration
//
//  Created by Weston Bustraan on 6/18/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Cocoa

class ModemSettingsViewController: NSViewController {

    @IBOutlet weak var popModemType: NSPopUpButton!

    @objc dynamic weak var connection: MobilinkdTncConnection!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.connection = (NSApplication.shared.delegate as! AppDelegate).connection
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (i, type) in MobilinkdTncConnection.ModemType.allCases.enumerated() {
            popModemType.addItem(withTitle: type.description)
            if type == connection.modemType {
                popModemType.selectItem(at: i)
            }
        }
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        popModemType.removeAllItems()
        popModemType.addItem(withTitle: MobilinkdTncConnection.ModemType.AFSK1200.description)
        popModemType.isEnabled = false

        if connection.apiVersion > TNC_API1_0 {
            try? connection.requestModemType()
            try? connection.requestModemTypes()
        }
    }
    
    @IBAction func onModemTypeChange(_ sender: NSPopUpButton) {
        connection.modemType = MobilinkdTncConnection.ModemType.allCases[sender.indexOfSelectedItem]        
    }
}
