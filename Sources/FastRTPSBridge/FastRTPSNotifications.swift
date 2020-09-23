/////
////  FastRTPSNotifications.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//


import Foundation

extension RTPSNotification: CustomStringConvertible {
    public var description: String {
        switch self {
        case .readerMatchedMatching : return "readerMatchedMatching"
        case .readerRemovedMatching : return "readerRemovedMatching"
        case .readerLivelinessLost  : return "readerLivelinessLost"
        case .writerMatchedMatching : return "writerMatchedMatching"
        case .writerRemovedMatching : return "writerRemovedMatching"
        case .writerLivelinessLost  : return "writerLivelinessLost"
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
        }
    }
}
