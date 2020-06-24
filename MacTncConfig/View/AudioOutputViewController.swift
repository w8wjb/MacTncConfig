//
//  AudioOutputViewController.swift
//  Mobilinkd TNC Configuration
//
//  Created by Weston Bustraan on 6/13/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Cocoa

class AudioOutputViewController: NSViewController {
    
    @objc dynamic weak var connection: MobilinkdTncConnection!
    
    @IBOutlet weak var stackOutput: NSStackView!
    
    @IBOutlet weak var segRadioTone: NSSegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.connection = (NSApplication.shared.delegate as! AppDelegate).connection
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connection.addObserver(self, forKeyPath: "canOutputTwist", options: [.initial, .new], context: nil)
    }
    
    deinit {
        connection.removeObserver(self, forKeyPath: "canOutputTwist")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        switch keyPath {
        case "canOutputTwist":
            DispatchQueue.main.async {
                self.stackOutput.arrangedSubviews[1].isHidden = !self.connection.canOutputTwist
            }
            
        default:
            break
        }
        
        
    }
    
    
    @IBAction func transmit(_ sender: NSButton) {
        
        let sendMark = segRadioTone.isSelected(forSegment: 0)
        let sendSpace = segRadioTone.isSelected(forSegment: 1)
        
        
        do {
            if sender.state == .off {
                try connection.requestTransmitSignal(mode: .off)
            } else {
                
                if sendMark && sendSpace {
                    try connection.requestTransmitSignal(mode: .both)
                } else if sendMark {
                    try connection.requestTransmitSignal(mode: .mark)
                } else if sendSpace {
                    try connection.requestTransmitSignal(mode: .space)
                } else {
                    try connection.requestTransmitSignal(mode: .off)
                }
            }
        } catch {
            presentError(error, modalFor: self.view.window!, delegate: nil, didPresent: nil, contextInfo: nil)
        }
        
    }

}
