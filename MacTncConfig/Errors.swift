//
//  Errors.swift
//  MacTncConfig
//
//  Created by Weston Bustraan on 6/13/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import Foundation
import AVFoundation

enum ConnectionError: Error, CustomStringConvertible {
  case ioFailed(String)
  
  var description: String {
    if case let .ioFailed(msg) = self {
      return msg
    }
    return ""
  }
}

enum ParsingError: Error, CustomStringConvertible {
  case noMoreBytes
  case unknownCharacterSet
  case conversionError
  case invalidDataFound(data: Data?)
  case missingInformation
  case couldNotParseNumber(string: String?)
  
  var description: String {
    switch self {
    case .noMoreBytes:
      return "No more bytes available"
    case .unknownCharacterSet:
      return "Unknown character set"
    case .conversionError:
      return "General conversion error"
    case .invalidDataFound(_):
      return "Invalid data found"
    case .missingInformation:
      return "Missing information"
    case .couldNotParseNumber(let string):
      return "Could not parse number from: [\(string ?? "")]"
    }
  }
}

//enum IOError: Error, CustomStringConvertible {
//  case pathNotFound(path: String)
//  case audioQueueError(status: OSStatus)
//  
//  var description: String {
//    if case let .pathNotFound(path) = self {
//      return "Could not find path: \(path)"
//    }
//    
//    if case let .audioQueueError(status) = self {
//      if status == noErr {
//        return ""
//      }
//      
//      switch status {
//      case kAudioQueueErr_InvalidBuffer:
//        return "The specified buffer does not belong to the audio queue."
//      case kAudioQueueErr_BufferEmpty:
//        return "The buffer is empty (that is, the mAudioDataByteSize field = 0)."
//      case kAudioQueueErr_DisposalPending:
//        return "The function cannot act on the audio queue because it is being asynchronously disposed of."
//      case kAudioQueueErr_InvalidProperty:
//        return "The specified property ID is invalid."
//      case kAudioQueueErr_InvalidPropertySize:
//        return "The size of the specified property is invalid."
//      case kAudioQueueErr_InvalidParameter:
//        return "The specified parameter ID is invalid."
//      case kAudioQueueErr_CannotStart:
//        return "The audio queue has encountered a problem and cannot start."
//      case kAudioQueueErr_InvalidDevice:
//        return "The device assigned to the queue could not be located."
//      case kAudioQueueErr_BufferInQueue:
//        return "The buffer cannot be disposed of when it is enqueued."
//      case kAudioQueueErr_InvalidRunState:
//        return "The queue is running but the function can only operate on the queue when it is stopped, or vice versa."
//      case kAudioQueueErr_InvalidQueueType:
//        return "The queue is an input queue but the function can only operate on an output queue, or vice versa."
//      case kAudioQueueErr_Permissions:
//        return "You do not have the required permissions to call the function"
//      case kAudioQueueErr_InvalidPropertyValue:
//        return "The specified property value is invalid."
//      case kAudioQueueErr_PrimeTimedOut:
//        return "During Prime, the queue's AudioConverter failed to convert the requested number of sample frames."
//      case kAudioQueueErr_CodecNotFound:
//        return "The required audio codec was not found."
//      case kAudioQueueErr_InvalidCodecAccess:
//        return "Access to the required codec is not permitted (possibly due to incompatible AudioSession settings on iPhoneOS)."
//      case kAudioQueueErr_QueueInvalidated:
//        return "On iPhoneOS, the audio server has exited, causing this audio queue to have become invalid."
//      case kAudioQueueErr_TooManyTaps:
//        return "There can only be one processing tap per audio queue."
//      case kAudioQueueErr_InvalidTapContext:
//        return "GetTapSourceAudio can only be called from the tap's callback."
//      case kAudioQueueErr_EnqueueDuringReset:
//        return "During Reset, Stop, or Dispose, it is not permitted to enqueue buffers."
//      case kAudioQueueErr_InvalidOfflineMode:
//        return "The operation requires the queue to be in offline mode but it isn't, or vice versa. (Offline mode is entered and exited via AudioQueueSetOfflineRenderFormat)."
//      default:
//        let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
//        return "Audio Queue Error: \(error)"
//      }
//    }
//    return ""
//  }
//}
