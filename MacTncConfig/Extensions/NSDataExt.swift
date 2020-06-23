//
//  NSDataExt.swift
//  MacTncConfig
//
//  Created by Weston Bustraan on 6/13/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Foundation

extension Data {

  public var hexEncoded: String {
    return self.map({ String(format: "%02X", $0).lowercased() }).joined(separator: " ")
  }

}


