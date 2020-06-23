//
//  MainViewController.swift
//  MacTncConfig
//
//  Created by Weston Bustraan on 6/13/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import AppKit
import CleanroomLogger

class MainViewController: NSViewController {
    
    private static let tableCellIdentifier = NSUserInterfaceItemIdentifier("sectionSelectCell")
    
    var deviceEventWatcher: DeviceEventWatcher!
    
    @IBOutlet weak var btnSelectDevice: NSPopUpButton!
    
    @IBOutlet weak var spinConnectProgress: NSProgressIndicator!
    
    @IBOutlet weak var btnConnect: NSButton!
    
    @IBOutlet weak var btnSave: NSButton!
    
    @IBOutlet weak var tblConfigSections: NSTableView!
    
    @IBOutlet var deviceArrayController: NSArrayController!
    
    @objc dynamic weak var connection: MobilinkdTncConnection!
    
    weak var tabViewController: NSTabViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.connection = (NSApplication.shared.delegate as! AppDelegate).connection
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceArrayController.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        deviceArrayController.addObserver(self, forKeyPath: "selectedObjects", options: .new, context: nil)
        
        
        deviceEventWatcher = DeviceEventWatcher(delegate: self)
        
    }
    
    override func viewDidAppear() {
        connection.addObserver(self, forKeyPath: "dynamicStatus", options:[.old, .new], context: nil)
        connection.addObserver(self, forKeyPath: "canBatteryLevel", options: [.old, .new], context: nil)
        connection.addObserver(self, forKeyPath: "canDeviceFirmwareUpdate", options: [.old, .new], context: nil)

    }
    
    override func viewWillDisappear() {
        connection.removeObserver(self, forKeyPath: "dynamicStatus")
        connection.removeObserver(self, forKeyPath: "canBatteryLevel")
        connection.removeObserver(self, forKeyPath: "canDeviceFirmwareUpdate")
        
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        if let tabViewController = segue.destinationController as? NSTabViewController {
            self.tabViewController = tabViewController
        }
        
        if let selectedTab = tabViewController?.selectedTabViewItemIndex {
            tblConfigSections.selectRowIndexes([selectedTab], byExtendingSelection: false)
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        DispatchQueue.main.async {
            self.observeValue(forKeyPath: keyPath, of: object, change: change)
        }
    }
    
    /**
     * Internal version of observeValue(...). Expected to be executed on the main thread
     */
    private func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?) {
        switch keyPath {
        case "selectedObjects":
            self.onDeviceDidChange()

        case "dynamicStatus":
            self.handleConnectionStatusChange()
            
        case "canBatteryLevel":
            print("canBatteryLevel \(self.connection.canBatteryLevel)")
            if self.tblConfigSections.numberOfRows > 1 {

                tblConfigSections.beginUpdates()
                if self.connection.canBatteryLevel {
                   self.tblConfigSections.unhideRows(at: IndexSet([3]), withAnimation: [])
                } else {
                    self.tblConfigSections.hideRows(at: IndexSet([3]), withAnimation: [])
                }
                tblConfigSections.endUpdates()
            }
            
        case "canDeviceFirmwareUpdate":
            if self.tblConfigSections.numberOfRows == 7 {

                if self.connection.canDeviceFirmwareUpdate {
                    self.tblConfigSections.unhideRows(at: IndexSet([6]), withAnimation: [])
                } else {
                    self.tblConfigSections.hideRows(at: IndexSet([6]), withAnimation: [])
                }
            }
            
        default:
            break
        }
    }
    
    
    func onDeviceDidChange() {
        
        if let selectedDevice = deviceArrayController.selectedObjects.first as? IODevice {
            
            btnConnect.isEnabled = true
            if connection.devicePath != selectedDevice.path {
                do {
                    try connection.stop()
                    connection.devicePath = selectedDevice.path
                } catch {
                    presentError(error, modalFor: self.view.window!, delegate: nil, didPresent: nil, contextInfo: nil)
                }
            }
            
        } else {
            btnConnect.isEnabled = false
            connection.devicePath = nil
        }
        
    }
    
    func handleConnectionStatusChange() {
        
        switch connection.status {
        case .starting:
            spinConnectProgress.startAnimation(self)
            btnConnect.isEnabled = false
            
        case .started:
            spinConnectProgress.stopAnimation(self)
            btnConnect.isEnabled = true
            btnConnect.title = "Disconnect"
            tblConfigSections.reloadData()

        case .stopping:
            spinConnectProgress.startAnimation(self)
            btnConnect.isEnabled = false

        case .stopped:
            spinConnectProgress.stopAnimation(self)
            btnConnect.title = "Connect"
            btnConnect.isEnabled = true
            tblConfigSections.reloadData()
            tabViewController?.selectedTabViewItemIndex = 0

        case .error:
            spinConnectProgress.stopAnimation(self)
            
        case .unconfigured:
            break
        }
        
    }

    
    @IBAction func toggleConnect(_ sender: NSButton) {
        
        spinConnectProgress.startAnimation(self)
        
        // Start/stop the connection in the background so that it doesn't block the UI and lets the spinner spin
        DispatchQueue.global(qos: .background).async {
            do {
                try self.connection.toggleStatus()
            } catch {
                DispatchQueue.main.async {
                    self.presentError(error as NSError, modalFor: self.view.window!, delegate: nil, didPresent: nil, contextInfo: nil)
                }
            }
        }
    }
    
    @IBAction func doSave(_ sender: NSButton) {
        
        spinConnectProgress.startAnimation(self)
        
        // Do the save in the background so that it doesn't block the UI and lets the spinner spin
        DispatchQueue.global(qos: .background).async {
            do {
                try self.connection.saveSettings()
                DispatchQueue.main.async {
                    self.spinConnectProgress.stopAnimation(self)
                }
            } catch {
                self.presentError(error as NSError, modalFor: self.view.window!, delegate: nil, didPresent: nil, contextInfo: nil)
            }
        }
    }
    
    @IBAction func doDiscard(_ sender: NSButton) {
        do {
            connection.reset()
            try connection.requestSettings()
        } catch {
            DispatchQueue.main.sync {
                presentError(error, modalFor: self.view.window!, delegate: nil, didPresent: nil, contextInfo: nil)
            }
        }
    }
}

// MARK: - NSTableViewDelegate
extension MainViewController : NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let tabItem = self.tableView(tableView, objectValueFor: tableColumn, row: row) as? NSTabViewItem else {
            return nil
        }
        
        guard let tableCellView = tableView.makeView(withIdentifier: MainViewController.tableCellIdentifier, owner: self) as? NSTableCellView else {
            return nil
        }
        
        tableCellView.textField?.stringValue = tabItem.label
        tableCellView.imageView?.image = tabItem.image
        
        return tableCellView
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        tabViewController?.selectedTabViewItemIndex = tblConfigSections.selectedRow
    }
    
    
}

// MARK: - NSTableViewDataSource
extension MainViewController : NSTableViewDataSource {
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        guard let tabViewItems = tabViewController?.tabViewItems else {
            return nil
        }
        
        return tabViewItems[row]
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        guard let tabViewItems = tabViewController?.tabViewItems else {
            return 0
        }
        
        if !connection.connected {
            return 0
        }
        
        return tabViewItems.count
    }
    
    
}

// MARK: - DeviceWatcherDelegate
extension MainViewController: DeviceWatcherDelegate {
    
    func deviceAdded(_ device: IODevice) {
        deviceArrayController.addObject(device)
    }
    
    func deviceRemoved(_ device: IODevice) {
        deviceArrayController.removeObject(device)
    }
}
