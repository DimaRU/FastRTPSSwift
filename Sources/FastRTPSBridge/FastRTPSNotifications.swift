/////
////  FastRTPSNotifications.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//


import Foundation
#if SWIFT_PACKAGE
import FastRTPSWrapper
#endif

extension RTPSNotification: CustomStringConvertible {
    public var description: String {
        switch self {
        case .readerMatchedMatching : return "readerMatchedMatching"
        case .readerRemovedMatching : return "readerRemovedMatching"
        case .readerLivelinessLost  : return "readerLivelinessLost"
        case .writerMatchedMatching : return "writerMatchedMatching"
        case .writerRemovedMatching : return "writerRemovedMatching"
        case .writerLivelinessLost  : return "writerLivelinessLost"
        @unknown default            : return "unknown"
        }
    }
}

extension RTPSReaderWriterNotification: CustomStringConvertible {
    public var description: String {
        switch self {
        case .discoveredReader : return "discoveredReader"
        case .changedQosReader : return "changedQosReader"
        case .removedReader    : return "removedReader"
        case .discoveredWriter : return "discoveredWriter"
        case .changedQosWriter : return "changedQosWriter"
        case .removedWriter    : return "removedWriter"
        @unknown default       : return "unknown"
        }
    }
}

extension RTPSParticipantNotification: CustomStringConvertible {
    public var description: String {
        switch self {
        case .discoveredParticipant : return "discoveredParticipant"
        case .changedQosParticipant : return "changedQosParticipant"
        case .removedParticipant    : return "removedParticipant"
        case .droppedParticipant    : return "droppedParticipant"
        @unknown default            : return "unknown"
        }
    }
}
