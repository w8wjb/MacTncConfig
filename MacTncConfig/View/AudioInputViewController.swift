//
//  AudioInputViewController.swift
//  Mobilinkd TNC Configuration
//
//  Created by Weston Bustraan on 6/13/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Cocoa

class AudioInputViewController: NSViewController {

    @objc dynamic weak var connection: MobilinkdTncConnection!
    
    @IBOutlet weak var sliderAudioInputGain: NSSlider!
    
    @IBOutlet weak var sliderAudioInputTwist: NSSlider!
    @IBOutlet weak var lblInputTwistMin: NSTextField!
    @IBOutlet weak var lblInputTwistMax: NSTextField!
    @IBOutlet weak var txtInputTwist: NSTextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.connection = (NSApplication.shared.delegate as! AppDelegate).connection
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = SuffixFormatter()
        formatter.suffix = "dB"
        lblInputTwistMin.formatter = formatter
        lblInputTwistMax.formatter = formatter
        txtInputTwist.formatter = formatter

        // There is no binding for the tick marks on a NSSlider, so we have to update it directly
        connection.addObserver(self, forKeyPath: "inputGainMin", options: [.initial, .new], context: nil)
        connection.addObserver(self, forKeyPath: "inputGainMax", options: [.initial, .new], context: nil)
        connection.addObserver(self, forKeyPath: "inputTwistMin", options: [.initial, .new], context: nil)
        connection.addObserver(self, forKeyPath: "inputTwistMax", options: [.initial, .new], context: nil)

    }

    deinit {
        connection.removeObserver(self, forKeyPath: "inputGainMin")
        connection.removeObserver(self, forKeyPath: "inputGainMax")
        connection.removeObserver(self, forKeyPath: "inputTwistMin")
        connection.removeObserver(self, forKeyPath: "inputTwistMax")
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()

        // Start streaming the volume level
        try? connection.requestStreamVolume()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()

        // Stop streaming volume level
        try? connection.requestPollVolume()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        switch keyPath {
        case "inputGainMin", "inputGainMax":
            DispatchQueue.main.async {
                self.sliderAudioInputGain.numberOfTickMarks = Int(self.connection.inputGainMax) - Int(self.connection.inputGainMin) + 1
            }
        case "inputTwistMin", "inputTwistMax":
            DispatchQueue.main.async {
                self.sliderAudioInputTwist.numberOfTickMarks = Int(self.connection.inputTwistMax) - Int(self.connection.inputTwistMin) + 1
            }
            
        default:
            break
        }
    }
    
    
    @IBAction func autoAdjust(_ sender: NSButton) {
        try? connection.requestAutoAdjustInput()
    }
    
}
