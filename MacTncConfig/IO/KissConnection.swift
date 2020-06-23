//
//  KissConnection.swift
//  MacTncConfig
//
//  Created by Weston Bustraan on 6/13/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Foundation

protocol KissConnection {
  func sendCommand(cmd: KissComand) throws
}
