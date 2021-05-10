//
//  KissCodec.swift
//  MacTncConfig
//
//  Created by Weston Bustraan on 6/13/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Foundation

class KissCodec {
  
  static let kissCommandReceived = NSNotification.Name("tnc.kissCommandReceived")
  
  
  // Frame  End
  static let FEND: UInt8 = 0xC0
  
  // Frame  Escape
  static let FESC: UInt8 = 0xDB
  
  // Transposed Frame End
  static let TFEND: UInt8 = 0xDC
  
  // Transposed Frame Escape
  static let TFESC: UInt8 = 0xDD
  
  enum State {
    case WaitFEND
    case WaitCommand
    case WaitHardwareCommand
    case WaitCommandData
    case WaitData
    case WaitEsc
    case WaitLF
  }
  
  unowned let connection: Connection
  unowned let delegate: ChannelDelegate
  
  var buffer = Data()
  
  var message = ""
  
  var escapedMode = false
  
  var bytesRead = 0
  
  var command: UInt8?
  
  var subcommand: UInt8?
  
  var state = State.WaitFEND
  
  init(connection: Connection, delegate: ChannelDelegate) {
    self.connection = connection
    self.delegate = delegate
  }
  
  func encodeCommand(_ cmd: KissComand) -> Data {    
    var data = cmd.data
    if let subcommand = cmd.subcommand {
      data.insert(subcommand, at: 0)
    }
    
    return encode(data, command: cmd.command)
  }
  
  func encode(_ data: Data, command: UInt8 = KissComand.data) -> Data {
    
    var encoded = Data()
    encoded.reserveCapacity(data.count + 2)
    
    encoded.append(KissCodec.FEND)
    encoded.append(command)
    for byte in data {
      if byte == KissCodec.FEND {
        encoded.append(KissCodec.FESC)
        encoded.append(KissCodec.TFEND)
      } else if byte == KissCodec.FESC {
        encoded.append(KissCodec.FESC)
        encoded.append(KissCodec.TFESC)
      } else {
        encoded.append(byte)
      }
    }
    encoded.append(KissCodec.FEND)
    
    return encoded
  }
  
  func decode(_ data: Data) {
    for byte in data {
      handleByte(byte)
    }
  }
  
  func decode(_ data: DispatchData) {
    for byte in data {
      handleByte(byte)
    }
  }
  
  
  private func handleByte(_ byte: UInt8) {
    
    switch state {
    case .WaitFEND:
      if byte == KissCodec.FEND {
        flushMessage()
        state = .WaitCommand
        
      } else if byte == ASCIIByte.carriageReturn {
        return
        
      } else if byte == ASCIIByte.lineFeed {
        flushMessage()
        
      } else {
        let c = Character(UnicodeScalar(byte))
        message.append(c)
      }
      
    case .WaitCommand:
      if byte == KissCodec.FEND {
        break
      }
      
      command = byte
      
      if command == KissComand.data {
        state = .WaitData
      } else if command == KissComand.hardware {
        state = .WaitHardwareCommand
      } else {
        state = .WaitCommandData
      }
      
    case .WaitHardwareCommand:
      subcommand = byte
      state = .WaitCommandData
      
    case .WaitEsc:
      
      switch byte {
      case KissCodec.TFEND:
        buffer.append(KissCodec.FEND)
        
      case KissCodec.TFESC:
        buffer.append(KissCodec.FESC)
        
      default:
        break
        // Receipt of any character other than TFESC or TFEND while in escaped mode is an error;
        // no action is taken and frame assembly continues.
      }
      
      state = .WaitData
      
    case .WaitData, .WaitCommandData, .WaitLF:
      
      if byte == KissCodec.FEND {
        flushBuffer()
        
        state = .WaitFEND
        
      } else if byte == KissCodec.FESC {
        state = .WaitEsc
        
      } else if byte == ASCIIByte.carriageReturn {
        break
        
      } else if byte == ASCIIByte.lineFeed {
        flushBuffer()
        
      } else {
        buffer.append(byte)
      }

    }
  }
  
  func flushBuffer() {
    if buffer.count > 0 {
      handleCompletePacketData(buffer)
    }
    buffer = Data()
    command = nil
    subcommand = 0
  }
  
  func flushMessage() {
    
    if !message.isEmpty {
      logger.debug(message.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
    }
    message = ""
  }
  
  
  func handleCompletePacketData(_ data: Data) {
    
    if command == KissComand.data {
      delegate.didReceive?(data: data)
      
    } else {
      
      let kissCommand = KissComand(command: command ?? 0xFF, subcommand: subcommand, data: data)
      let userInfo: [String: Any] = ["packet": kissCommand]

      DispatchQueue.main.async {
        NotificationCenter.default.post(name: KissCodec.kissCommandReceived, object: self.connection, userInfo: userInfo)
      }
      
    }
    
    
  }
  
}
