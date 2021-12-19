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
    @IBOutlet var modemTypeArrayController: NSArrayController!
    
    @objc dynamic var connection: MobilinkdTncConnection? {
        willSet {
            if let conn = self.connection {
                conn.removeObserver(self, forKeyPath: "modemType")
            }
        }
        
        didSet {
            if let conn = self.connection {
                conn.addObserver(self, forKeyPath: "modemType", options: [.initial, .new], context: nil)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.connection = (NSApplication.shared.delegate as! AppDelegate).connection
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modemTypeArrayController.addObserver(self, forKeyPath: "selectedObjects", options: [.new], context: nil)
    }
    
    deinit {
        modemTypeArrayController.removeObserver(self, forKeyPath: "selectedObjects")
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if let conn = self.connection {
            if conn.apiVersion > TNC_API1_0 {
                try? conn.requestModemType()
                try? conn.requestModemTypes()
            }
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let arrayController = object as? NSArrayController  {
            if keyPath == "selectedObjects" {
                if arrayController == modemTypeArrayController {
                    onModemTypeDidChange()
                }
            }
        }
        
        if let conn = object as? MobilinkdTncConnection {
            modemTypeArrayController.setSelectedObjects([conn.modemType])
        }
        
    }
    
    func onModemTypeDidChange() {
        if let selectedModem = modemTypeArrayController.selectedObjects.first as? ModemType {
            if connection?.modemType != selectedModem {
                connection?.modemType = selectedModem
            }
        }
    }

}
