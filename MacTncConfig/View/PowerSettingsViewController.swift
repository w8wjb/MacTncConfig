//
//  PowerSettingsViewController.swift
//  Mobilinkd TNC Configuration
//
//  Created by Weston Bustraan on 6/18/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Cocoa

class PowerSettingsViewController: NSViewController {

    @objc dynamic weak var connection: MobilinkdTncConnection!
    
    
    @IBOutlet weak var indBatteryLevel: NSLevelIndicator!
    
    @IBOutlet weak var txtBatteryVoltage: NSTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.connection = (NSApplication.shared.delegate as! AppDelegate).connection
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indBatteryLevel.bind(.value, to: self , withKeyPath: "connection.batteryLevel", options: [NSBindingOption.valueTransformer : BatteryLevelValueTransformer()])
        
        txtBatteryVoltage.formatter = UnitFormatter(unit: UnitElectricPotentialDifference.millivolts)
        txtBatteryVoltage.bind(.value, to: self , withKeyPath: "connection.batteryLevel", options: nil)
        
    }
    
    deinit {
        indBatteryLevel.unbind(.value)
        txtBatteryVoltage.unbind(.value)
    }
    
}
