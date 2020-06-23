//
//  MobilinkdTncConnection.swift
//  Mobilinkd TNC Configuration
//
//  Created by Weston Bustraan on 6/18/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Foundation
import CleanroomLogger


let TNC_API1_0: UInt16 = 0x0100
let TNC_API2_0: UInt16 = 0x0200


class MobilinkdTncConnection: KissSerialConnection {
    
    enum ModemType: UInt8, CaseIterable, CustomStringConvertible {
        case AFSK1200 = 1
        case AFSK300 = 2
        case FSK9600 = 3
        case PSK31 = 4
        case OFDM = 5
        case MFSK16 = 6
        
        var description: String {
            switch self {
            case .AFSK1200:
                return "1200 baud AFSK"
            case .AFSK300:
                return "300 baud AFSK"
            case .FSK9600:
                return "9600 baud FSK"
            case .PSK31:
                return "PSK31"
            case .OFDM:
                return "OFDM"
            case .MFSK16:
                return "MFSK16"
            }
        }
    }
    
    /**
     * Mobilinkd-specific KISS hardware commands
     */
    fileprivate enum HardwareCommand: UInt8 {
        // MARK: - KISS Hardware Commands
        case saveToEEPROM = 0
        
        /**
         * - API 1.0 : SET_OUTPUT_VOLUME - uint8
         * - API 2.0 : SET_OUTPUT_GAIN - uint16
         */
        case setOutputGain = 1
        
        
        /**
         *
         * - Version:API 1.0
         * - Parameter SET_INPUT_ATTEN: uint8
         *  Input volume attenuation.  Select this when a higher volume from the radio produces better results.
         *
         * - Version:API 2.0
         * - Parameter SET_INPUT_GAIN:uint16
         *  Select the audio input gain to maximize the dynamic range.
         */
        case setInputGain = 2
        /** Deprecated */
        case setSquelchLevel = 3
        /** One value */
        case pollInputLevel = 4
        /** Stream continuously */
        case streamInputLevel = 5
        case getBatteryLevel = 6
        case sendMark = 7
        case sendSpace = 8
        case sendBoth = 9
        case stopTX = 10
        case reset = 11
        case getOutputGain = 12
        /** - Requires: API 1.0 */
        //        case getInputAttenuation = 13
        //        /** - Requires: API 2.0 */
        case getInputGain = 13
        case getSquelchLevel = 14
        case getDCD = 15
        case setVerbosity = 16
        case getVerbosity = 17
        case setInputOffset = 18
        case getInputOffset = 19
        case setOutputOffset = 20
        case getOutputOffset = 21
        case setLowpassFreq = 22
        case getLowpassFreq = 23
        /**
         * Values 0-100
         * - Requires: API 2.0
         */
        case setInputTwist = 24
        /**
         * Values 0-100
         * - Requires: API 2.0
         */
        case getInputTwist = 25
        /**
         * Values 0-100
         * - Requires: API 2.0
         */
        case setOutputTwist = 26
        /** - Requires: API 2.0 */
        case getOutputTwist = 27
        case streamRawInput = 28
        case streamAmplifiedInput = 29
        case streamFilteredInput = 30
        case streamOutput = 31
        /** Acknowledge SET commands */
        case OK = 32
        case getTXDelay = 33
        case getPersistence = 34
        case getSlotTime = 35
        case getTXTail = 36
        case getDuplex = 37
        case getFirmwareVersion = 40
        case getHardwareVersion = 41
        case saveEEPROM = 42
        /**
         * API 2.0 Auto-adjust levels
         * - Requires: API 2.0
         */
        case adjustInputLevels = 43
        case pollInputTwist = 44
        case streamAvgInputTwist = 45
        case streamInputTwist = 46
        /** - Requires: API 2.0 */
        case getSerialNumber = 47
        case getMACAddress = 48
        /** - Requires: API 2.0 */
        case getDateTime = 49
        /**
         * Values BCD YMDWHMS
         * - Requires: API 2.0
         */
        case setDateTime = 50
        case getErrorMsg = 51
        case setBluetoothName = 65
        case getBluetoothName = 66
        /** - Warning: **Risk of being unable to pair! Danger Will Robinson!** */
        case setBluetoothPin = 67
        case getBluetoothPin = 68
        /** Bluetooth connection tracking */
        case setBTConnTrack = 69
        /** Bluetooth connection tracking */
        case getBTConnTrack = 70
        /** Bluetooth Major Class */
        case setBTMajorClass = 71
        /** Bluetooth Major Class */
        case getBTMajorClass = 72
        /** Power on when USB power available */
        case setUSBPowerOn = 73
        case getUSBPowerOn = 74
        /** Power off when USB power unavailable */
        case setUSBPowerOff = 75
        case getUSBPowerOff = 76
        /** Power off after n seconds w/o BT conn */
        case setBTPowerOff = 77
        case getBTPowerOff = 78
        /** Which PTT line to use (currently 0 or 1, multiplex or simplex) */
        case setPTTChannel = 79
        /** Which PTT line to use (currently 0 or 1, multiplex or simplex) */
        case getPTTChannel = 80
        /** Allow invalid CRC through when true (1) */
        case setPassall = 81
        /** Allow invalid CRC through when true (1) */
        case getPassall = 82
        
        /** < int8_t (may be negative). */
        case getMinOutputTwist = 119
        /** < int8_t (may be negative). */
        case getMaxOutputTwist = 120
        /**
         * < int8_t (may be negative).
         *
         * - Requires: API 2.0
         */
        case getMinInputTwist = 121
        /**
         * < int8_t (may be negative).
         *
         * - Requires: API 2.0
         */
        case getMaxInputTwist = 122
        /**
         * < uint16_t (major/minor)
         *
         * - Requires: API 2.0
         */
        case getAPIVersion = 123
        /**
         * < int8_t (may be negative/attenuated).
         *
         * - Requires: API 2.0
         */
        case getMinInputGain = 124
        
        /**
         * < int8_t (may be negative/attenuated).
         *
         * - Requires: API 2.0
         */
        case getMaxInputGain = 125
        /**
         * < Send all capabilities.
         */
        case getCapabilities = 126
        /**
         * < Send all settings & versions.
         */
        case getAllValues = 127
        
        // MARK: - Extended hardware commands
        
        /**
         * Extended commands are two+ bytes in length.  They start at 80:00
         * and go through BF:FF (14 significant bits), then proceed to C0:00:00
         * through CF:FF:FF (20 more significant bits).
         *
         * If needed, the commands can be extended to 9 nibbles (D0 - DF),
         * 13 nibbles (E0-EF) and 17 nibbles (F0-FF).
         */
        case extendedCmd = 128
        
        
    }
    
    fileprivate enum ExtendedHardwareCommand: UInt8 {
        case OK = 0
        case getModemType = 1
        case setModemType = 2
        /** < Return a list of supported modem types */
        case getModemTypes = 3
        /** < Number of aliases supported */
        case getAliases = 8
        /** < Alias number (uint8_t), 8 characters, 5 bytes (set, use, insert_id, preempt, hops) */
        case getAlias = 9
        /** < Alias number (uint8_t), 8 characters, 5 bytes (set, use, insert_id, preempt, hops) */
        case setAlias = 10
        /** < Number of beacons supported */
        case getBeacons = 12
        /** < Beacon number (uint8_t), uint16_t interval in seconds, 3 NUL terminated strings */
        case getBeacon = 13
        /** < Beacon number (uint8_t), uint16_t interval in seconds, 3 NUL terminated strings (callsign, path, text) */
        case setBeacon = 14
    }
    
    struct Capabilities: OptionSet {
        
        let rawValue: UInt16
        
        init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
        
        static let trackDCD = Capabilities(rawValue: 1 << 0)
        static let squelch = Capabilities(rawValue: 1 << 1)
        static let inputAtten = Capabilities(rawValue: 1 << 2)
        static let firmwareVersion = Capabilities(rawValue: 1 << 3)
        static let batteryLevel = Capabilities(rawValue: 1 << 4)
        static let blutoothConnectionTracking = Capabilities(rawValue: 1 << 5)
        static let blutoothNameChange = Capabilities(rawValue: 1 << 6)
        static let blutoothPinChange = Capabilities(rawValue: 1 << 7)
        static let verboseError = Capabilities(rawValue: 1 << 8)
        static let EEPROMSave = Capabilities(rawValue: 1 << 9)
        static let adjustInput = Capabilities(rawValue: 1 << 10)
        static let dfuFirmware = Capabilities(rawValue: 1 << 11)
    }
    
    
    private let log2 = log(Float(2.0))
    
    @objc dynamic var message = ""
    
    @objc dynamic var apiVersion: UInt16 = TNC_API1_0
    
    @objc dynamic var inputLevel: Int = 0
    
    @objc dynamic var inputGain: Int16 = 0
    @objc dynamic var inputGainMin: Int16 = 0
    @objc dynamic var inputGainMax: Int16 = 0
    
    @objc dynamic var inputTwist: Int8 = 0
    @objc dynamic var inputTwistMin: Int8 = 0
    @objc dynamic var inputTwistMax: Int8 = 0
    
    @objc dynamic var outputGain: Int16 = 0
    @objc dynamic var outputGainMin: Int16 = 0
    @objc dynamic var outputGainMax: Int16 = 255
    
    @objc dynamic var outputTwist: Int8 = 0
    @objc dynamic var outputTwistMin: Int8 = 0
    @objc dynamic var outputTwistMax: Int8 = 100
    
    @objc dynamic var batteryLevel: UInt16 = 0
    @objc dynamic var inputAttenuation: Bool = false
    @objc dynamic var dcd: Bool = false
    @objc dynamic var firmwareVersion: String? = nil
    @objc dynamic var hardwareVersion: String? = nil
    @objc dynamic var macAddress: String? = nil
    @objc dynamic var serialNumber: String? = nil
    @objc dynamic var dateTime: Date? = nil
    @objc dynamic var bluetoothName: String = ""
    @objc dynamic var bluetoothConnectionTracking: Bool = false
    @objc dynamic var verbosity: Bool = false
    @objc dynamic var pttChannel: UInt8 = 0
    @objc dynamic var usbPowerOn: Bool = false
    @objc dynamic var usbPowerOff: Bool = false
    /** Allow invalid CRC through when true (1) */
    @objc dynamic var passall: Bool = false
    
    var modemType: ModemType = .AFSK1200 {
        didSet {
            changedProperties.insert("modemType")
            dirty = true
        }
    }
    
    var supprtedModemTypes = Set<ModemType>([.AFSK1200])
    
    @objc dynamic var canTrackDCD = false
    @objc dynamic var canSquelch = false
    @objc dynamic var canInputAtten = false
    @objc dynamic var canOutputTwist = false
    @objc dynamic var canFirmwareVersion = false
    @objc dynamic var canBatteryLevel = false
    @objc dynamic var canBTConnTrack = false
    @objc dynamic var canBTNameChange = false
    @objc dynamic var canBTPinChange = false
    @objc dynamic var canVerbose = false
    @objc dynamic var canEEPROMSave = false
    /** Can Auto-adjust input levels. */
    @objc dynamic var canAdjustInput = false
    /** DFU firmware style */
    @objc dynamic var canDeviceFirmwareUpdate = false
    @objc dynamic var canPassall = false
    
    
    /**
     * Set when a property value has changed and needs to be saved
     */
    @objc dynamic var dirty = false
    
    var changedProperties = Set<String>()
    
    private static let _keyPathsForValuesAffectingDirty = Set([
        "txDelay",
        "persistence",
        "slotTime",
        "txTail",
        "duplex",
        "inputGain",
        "inputTwist",
        "outputGain",
        "outputTwist",
        "inputAttenuation",
        "dcd",
        "bluetoothConnectionTracking",
        "verbosity",
        "pttChannel",
        "usbPowerOn",
        "usbPowerOff",
        "passall"
    ])
    
    enum PTTMode: Int {
        case off
        case space
        case mark
        case both
    }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleIncomingKissCommand(notification:)), name: KissCodec.kissCommandReceived, object: self)
        reset()
    }
    
    func reset() {
        
        DispatchQueue.main.async {
            self.message = ""
            self.apiVersion = TNC_API1_0
            self.inputLevel = 0
            self.inputGain = 0
            self.inputGainMin = -3
            self.inputGainMax = 9
            self.inputTwist = 6
            self.inputTwistMin = 0
            self.inputTwistMax = 0
            self.outputGain = 0
            self.outputGainMax = 255
            self.outputTwist = 0
            self.outputTwistMin = 0
            self.outputTwistMax = 100
            self.batteryLevel = 0
            self.inputAttenuation = false
            self.dcd = false
            self.firmwareVersion = nil
            self.hardwareVersion = nil
            self.macAddress = nil
            self.serialNumber = nil
            self.dateTime = nil
            self.bluetoothName = ""
            self.bluetoothConnectionTracking = false
            self.verbosity = false
            self.pttChannel = 0
            self.usbPowerOn = false
            self.usbPowerOff = false
            self.passall = false
            self.modemType = .AFSK1200
            
            self.canTrackDCD = false
            self.canSquelch = false
            self.canInputAtten = false
            self.canOutputTwist = false
            self.canFirmwareVersion = false
            self.canBatteryLevel = false
            self.canBTConnTrack = false
            self.canBTNameChange = false
            self.canBTPinChange = false
            self.canVerbose = false
            self.canEEPROMSave = false
            self.canAdjustInput = false
            self.canDeviceFirmwareUpdate = false
            self.canPassall = false
            self.dirty = false
        }
        
        
    }
    
    override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        
        if MobilinkdTncConnection._keyPathsForValuesAffectingDirty.contains(key) {
            changedProperties.insert(key)
            self.dirty = true
            
        } else if key == "dirty" {
            if !dirty {
                changedProperties.removeAll()
            }
        }
    }
    
    @objc class func keyPathsForValuesAffectingDirty() -> Set<String> {
        return MobilinkdTncConnection._keyPathsForValuesAffectingDirty
    }
    
    override func initChannel() throws {
        try super.initChannel()
        
        try requestStopTransmitting()
        try requestSettings()
    }
    
    override func stop() throws {
        if (status == .stopping || status == .stopped || status == .unconfigured) {
            return
        }
        
        try requestStopTransmitting()
        try requestPollVolume()
        try super.stop()
        self.reset()
    }
    
    func saveSettings() throws {
        guard status == .started else {
            Log.debug?.message("Can't save when connection is not started")
            return
        }
        Log.debug?.message("Saving Mobilinkd settings")
        
        for prop in changedProperties {
            
            print("Saving \(prop)")
            switch prop {
            case "txDelay":
                try setTxDelay(self.txDelay)
            case "persistence":
                try setPersistence(self.persistence)
            case "slotTime":
                try setSlotTime(self.slotTime)
            case "txTail":
                try setTxTail(self.txTail)
            case "duplex":
                try setDuplex(self.duplex)
            case "inputGain":
                try setInputGain(value: self.inputGain)
            case "inputTwist":
                try setInputTwist(value: self.inputTwist)
            case "outputGain":
                try setOutputGain(value: self.outputGain)
            case "outputTwist":
                try setOutputTwist(value: self.outputTwist)
            case "inputAttenuation":
                try setInputAttenuation(on: self.inputAttenuation)
            case "dcd":
                try setDCD(self.dcd)
            case "bluetoothConnectionTracking":
                try setBTConnTrack(self.bluetoothConnectionTracking)
            case "verbosity":
                try setVerbosity(on: self.verbosity)
            case "pttChannel":
                try setPttChannel(value: self.pttChannel)
            case "usbPowerOn":
                try setUSBPowerOn(self.usbPowerOn)
            case "usbPowerOff":
                try setUSBPowerOff(self.usbPowerOff)
            case "passall":
                try setPassall(on: self.passall)
            case "modemType":
                try setModemType(modem: self.modemType)
            default:
                break
            }
            
        }
        
        DispatchQueue.main.async {
            self.dirty = false
        }
    }
    
    @objc func handleIncomingKissCommand(notification: Notification) {
        guard let packet = notification.userInfo?["packet"] as? KissComand else {
            Log.error?.message("Notification did not contain a KISS command")
            return
        }
        
        DispatchQueue.main.async {
            self.handleIncomingKissCommand(packet)
        }
    }
    
    func handleIncomingKissCommand(_ packet: KissComand) {
        
        if packet.command == KissComand.hardware {
            
            var resetDirty = true
            
            guard let hwCommand = HardwareCommand(rawValue: packet.subcommand!) else {
                Log.warning?.message("Unknown hardware command \(packet.subcommand!)")
                return
            }
            
            switch hwCommand {
                
            case .pollInputLevel:
                resetDirty = false
                let v = max(packet.value, 1)
                let vol = log(Float(v)) / log2
                // Transform it to a value between 0 and 10. Makes it easier to work with NSSlider
                self.inputLevel = min(10, Int(vol * 1.25 + 0.5))
                Log.debug?.message("hwPollInputLevel = \(self.inputLevel)")
                
            case .getOutputGain:
                
                if apiVersion == TNC_API1_0 {
                    self.outputGain = Int16(packet.value)
                } else {
                    self.outputGain = packet.value(as: Int16.self)
                }
                
                Log.debug?.message("hwGetOutputGain = \(self.outputGain)")
                
            case .getOutputTwist:
                outputTwist = Int8(packet.value)
                canOutputTwist = true
                Log.debug?.message("hwGetOutputTwist = \(self.outputTwist)")
                
            case .getBatteryLevel:
                resetDirty = false
                canBatteryLevel = true
                self.batteryLevel = packet.value(as: UInt16.self)
                Log.debug?.message("hwGetBatteryLevel = \(self.batteryLevel)")
                
            case .getInputGain:
                if apiVersion == TNC_API1_0 {
                    self.inputAttenuation = (packet.value != 0)
                    Log.debug?.message("hwGetInputAttenuation = \(self.inputAttenuation)")
                } else {
                    self.inputGain = packet.value(as: Int16.self)
                    Log.debug?.message("hwGetInputGain = \(self.inputGain)")
                }
                
            case .getInputTwist:
                self.inputTwist = packet.value(as: Int8.self)
                Log.debug?.message("getInputTwist = \(self.inputTwist)")
                
            case .getSquelchLevel:
                self.dcd = (packet.value == 0)
                Log.debug?.message("hwGetSquelchLevel = \(self.dcd)")
                
            case .getTXDelay:
                Log.debug?.message("hwGetTXDelay = \(Int(packet.value))")
                txDelay = packet.value
                
            case .getPersistence:
                persistence = packet.value
                Log.debug?.message("hwGetPersistence = \(persistence)")
                
            case .getSlotTime:
                slotTime = packet.value
                Log.debug?.message("hwGetSlotTime = \(slotTime)")
                
            case .getTXTail: //
                txTail = packet.value
                Log.debug?.message("hwGetTXTail = \(txTail)")
                
            case .getDuplex:
                duplex = (packet.value != 0)
                Log.debug?.message("hwGetDuplex = \(duplex)")
                
            case .getFirmwareVersion:
                resetDirty = false
                if let version = packet.message {
                    firmwareVersion = version
                }
                
            case .getHardwareVersion:
                resetDirty = false
                if let version = packet.message {
                    Log.debug?.message("hwGetHardwareVersion: \(version)")
                    hardwareVersion = version
                }
                
            case .getSerialNumber:
                resetDirty = false
                if let serial = packet.message {
                    Log.debug?.message("hwGetSerialNumber: = \(serial)")
                    serialNumber = serial
                }
                
            case .getMACAddress:
                resetDirty = false
                macAddress = packet.data.map({ String(format: "%02X", $0) }).joined(separator: ":")
                Log.debug?.message("hwGetMACAddress: = \(macAddress ?? "")")
                
            case .getDateTime:
                resetDirty = false
                var d = DateComponents()
                d.year = packet.data[0].decodeBCD() + 2000
                d.month = packet.data[1].decodeBCD()
                d.day = packet.data[2].decodeBCD()
                // let weekday = packet.data[3].decodeBCD()
                d.hour = packet.data[4].decodeBCD()
                d.minute = packet.data[5].decodeBCD()
                d.second = packet.data[6].decodeBCD()
                d.timeZone = TimeZone(identifier: "UTC")
                
                dateTime = d.date
                
            case .getBluetoothName:
                resetDirty = false
                if let name = packet.message {
                    Log.debug?.message("hwGetBluetoothName: = \(name)")
                    bluetoothName = name
                }
                
            case .getBTConnTrack:
                self.bluetoothConnectionTracking = (packet.value != 0)
                Log.debug?.message("hwGetBTConnTrack = \(self.bluetoothConnectionTracking)")
                
            case .getVerbosity:
                self.verbosity = (packet.value != 0)
                canVerbose = true
                Log.debug?.message("hwGetVerbosity = \(self.verbosity)")
                
            case .getPTTChannel:
                self.pttChannel = packet.value
                Log.debug?.message("hwGetPTTChannel = \(self.pttChannel)")
                
            case .getUSBPowerOn:
                self.usbPowerOn = (packet.value != 0)
                Log.debug?.message("hwGetUSBPowerOn = \(self.usbPowerOn)")
                
            case .getUSBPowerOff:
                self.usbPowerOff = (packet.value != 0)
                Log.debug?.message("hwGetUSBPowerOff = \(self.usbPowerOff)")
                
            case .getAPIVersion:
                resetDirty = false
                guard packet.data.count == 2 else { return }
                
                self.apiVersion = packet.value(as: UInt16.self)
                Log.debug?.message("hwGetAPIVersion = \(self.apiVersion)")
                
            case .pollInputTwist:
                // TODO: Ignoring POLL_INPUT_TWIST for now
                resetDirty = false
                
            case .getMinInputTwist:
                resetDirty = false
                self.inputTwistMin = packet.value(as: Int8.self)
                Log.debug?.message("hwGetMinInputTwist = \(self.inputTwistMin)")
                
            case .getMaxInputTwist:
                resetDirty = false
                self.inputTwistMax = packet.value(as: Int8.self)
                Log.debug?.message("hwGetMaxInputTwist = \(self.inputTwistMax)")
                
            case .getMinInputGain:
                resetDirty = false
                self.inputGainMin = packet.value(as: Int16.self)
                Log.debug?.message("hwGetMinInputGain = \(self.inputGainMin)")
                
            case .getMaxInputGain:
                resetDirty = false
                self.inputGainMax = packet.value(as: Int16.self)
                Log.debug?.message("hwGetMaxInputGain = \(self.inputGainMax)")
                
            case .getCapabilities:
                
                let rawValue = packet.value(as: UInt16.self, sourceByteOrder: .littleEndian)
                let capabilities = Capabilities(rawValue: rawValue)
                
                canTrackDCD = capabilities.contains(.trackDCD)
                canSquelch = capabilities.contains(.squelch)
                canInputAtten = capabilities.contains(.inputAtten)
                canFirmwareVersion = capabilities.contains(.firmwareVersion)
                canBatteryLevel = capabilities.contains(.batteryLevel)
                canBTConnTrack = capabilities.contains(.blutoothConnectionTracking)
                canBTNameChange = capabilities.contains(.blutoothNameChange)
                canBTPinChange = capabilities.contains(.blutoothPinChange)
                canVerbose = capabilities.contains(.verboseError)
                canEEPROMSave = capabilities.contains(.EEPROMSave)
                canAdjustInput = capabilities.contains(.adjustInput)
                
                // TODO: This is always disabled for now
                // canDeviceFirmwareUpdate = !capabilities.contains(.dfuFirmware)
                
                
            case .getDCD:
                // Per Rob: This can be safely ignored.  I'm not sure how meaningful it is right now.
                // I started to add DCD diagnostics but never completed it.
                resetDirty = false
                
            case .extendedCmd:
                
                let rawValue = packet.data[0]
                guard let extCmd = ExtendedHardwareCommand(rawValue: rawValue) else {
                    Log.warning?.message("Unknown extende command \(rawValue)")
                    return
                }
                
                switch extCmd {
                case .getModemTypes:
                    
                    self.supprtedModemTypes.removeAll()
                    for modemByte in packet.data.suffix(from: 1) {
                        guard let modem = ModemType(rawValue: modemByte) else {
                            continue
                        }
                        supprtedModemTypes.insert(modem)
                    }
                    
                case .getModemType:
                    self.modemType = ModemType(rawValue: packet.data[1]) ?? ModemType.AFSK1200
                    
                    
                default:
                    break
                }
                
                
            default:
                resetDirty = false
                let fullPacket = Data([packet.command, packet.subcommand!] + packet.data)
                Log.error?.message("Unknown command \(packet)" + fullPacket.hexEncoded)
                break
            }
            
            if resetDirty {
                dirty = false
            }
            
        } else if packet.command == 0x3d {
            
            if let msg = String(bytes: packet.data, encoding: String.Encoding.utf8) {
                message = msg
            }
            
        } else {
            Log.error?.message("Unknown packet: \(packet)")
        }
        
    }
    
    func requestSettings() throws {
        Log.debug?.message("Asking device for settings")
        try requestStopTransmitting()
        try requestAllValues()
        try requestCapabilities()
    }
    
    fileprivate func sendCommand(cmd: HardwareCommand, value: UInt8? = nil) throws {
        let kissCmd = KissComand(command: KissComand.hardware, subcommand: cmd.rawValue, value: value)
        try sendCommand(cmd: kissCmd)
    }
    
    fileprivate func sendExtCommand(cmd: ExtendedHardwareCommand, data: Data? = nil) throws {
        var extData = data ?? Data()
        extData.insert(cmd.rawValue, at: 0)
        let kissCmd = KissComand(command: KissComand.hardware, subcommand: HardwareCommand.extendedCmd.rawValue, data: extData)
        try sendCommand(cmd: kissCmd)
    }
    
    
    fileprivate func sendCommand(cmd: HardwareCommand, data: Data) throws {
        let kissCmd = KissComand(command: KissComand.hardware, subcommand: cmd.rawValue, data: data)
        try sendCommand(cmd: kissCmd)
    }
    
    func requestStopTransmitting() throws {
        try sendCommand(cmd: .stopTX)
    }
    
    func requestAllValues() throws {
        try sendCommand(cmd: .getAllValues)
    }
    
    func requestCapabilities() throws {
        try sendCommand(cmd: .getCapabilities)
    }
    
    func requestStreamVolume() throws {
        try sendCommand(cmd: .streamInputLevel)
    }
    
    func requestPollVolume() throws {
        try sendCommand(cmd: .pollInputLevel)
    }
    
    func requestBatteryLevel() throws {
        try sendCommand(cmd: .getBatteryLevel)
    }
    
    func requestOutputGain() throws {
        try sendCommand(cmd: .getOutputGain)
    }
    
    func requestSaveEEPROM() throws {
        if canEEPROMSave {
            try sendCommand(cmd: .saveEEPROM)
        }
    }
    
    func requestTransmitSignal(mode: PTTMode) throws {
        switch mode {
        case .mark:
            try sendCommand(cmd: .sendMark)
        case .space:
            try sendCommand(cmd: .sendSpace)
        case .both:
            try sendCommand(cmd: .sendBoth)
        default:
            try sendCommand(cmd: .stopTX)
        }
    }
    
    func requestModemType() throws {
        try sendExtCommand(cmd: .getModemType)
    }
    
    
    func requestModemTypes() throws {        
        try sendExtCommand(cmd: .getModemTypes)
    }
    
    func setDCD(_ on: Bool) throws {
        let value: UInt8 = (on ? 0 : 2)
        try sendCommand(cmd: .setSquelchLevel, value: value)
    }
    
    func setBTConnTrack(_ on: Bool) throws {
        let value: UInt8 = (on ? 1 : 0)
        try sendCommand(cmd: .setBTConnTrack, value: value)
    }
    
    func setVerbosity(on: Bool) throws {
        let value: UInt8 = (on ? 1 : 0)
        try sendCommand(cmd: .setVerbosity, value: value)
    }
    
    func setUSBPowerOn(_ on: Bool) throws {
        let value: UInt8 = (on ? 1 : 0)
        try sendCommand(cmd: .setUSBPowerOn, value: value)
    }
    
    func setUSBPowerOff(_ on: Bool) throws {
        let value: UInt8 = (on ? 1 : 0)
        try sendCommand(cmd: .setUSBPowerOff, value: value)
    }
    
    func setPttChannel(value: UInt8) throws {
        try sendCommand(cmd: .setPTTChannel, value: value)
    }
    
    func setPassall(on: Bool) throws {
        let value: UInt8 = (on ? 1 : 0)
        try sendCommand(cmd: .setPassall, value: value)
    }
    
    func saveEEPROM() throws {
        if canEEPROMSave {
            try sendCommand(cmd: .saveEEPROM)
        }
    }
    
    func setInputAttenuation(on: Bool) throws {
        let value: UInt8 = (on ? 2 : 0)
        try sendCommand(cmd: .setInputGain, value: value)
    }
    
    private func setInputGain(value: Int16) throws {
        let data = Data(value.bigEndian.toBytes)
        try sendCommand(cmd: .setInputGain, data: data)
    }
    
    private func setInputTwist(value: Int8) throws {
        try sendCommand(cmd: .setInputTwist, value: UInt8(bitPattern: value))
    }
    
    func setOutputGain(value: Int16) throws {
        
        var data = Data()
        if apiVersion == TNC_API1_0 {
            data.append(UInt8(value))
        } else {
            data.append(contentsOf: value.bigEndian.toBytes)
        }
        
        try sendCommand(cmd: .setOutputGain, data: data)
    }
    
    func setOutputTwist(value: Int8) throws {
        try sendCommand(cmd: .setOutputTwist, value: UInt8(bitPattern: value))
    }
    
    func setModemType(modem: ModemType) throws {
        let data = Data([modem.rawValue])
        try sendExtCommand(cmd: .setModemType, data: data)
    }
    
}
