//
//  ToggleFollowsValueButtonCell.swift
//
//  Created by Weston Bustraan on 10/26/21.
//

import Cocoa

/**
 By default, when a NSButton is configured to be a toggle, when clicked, it will change the button state regardless of what the bound value is.
 This subclass disables that behavior so that the state only changes once the bound value does.
 */
class ToggleFollowsValueButtonCell: NSButtonCell {
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        highlightsBy = .pushInCellMask
        showsStateBy = .contentsCellMask
    }
    
    override func setNextState() {
        // Do nothing
    }
    
}
