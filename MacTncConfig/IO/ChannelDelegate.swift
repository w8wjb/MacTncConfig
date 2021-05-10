//
//  ChannelDelegate.swift
//  MacTncConfig
//
//  Created by Weston Bustraan on 6/13/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Foundation

@objc protocol ChannelDelegate {
  
  @objc optional func willTransmit()
  @objc optional func didTransmit()
  @objc optional func willReceive()
  @objc optional func cancelReceive()
  @objc optional func didReceive(data: Data)
  
}

