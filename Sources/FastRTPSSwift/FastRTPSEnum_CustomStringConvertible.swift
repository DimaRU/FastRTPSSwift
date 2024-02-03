/////
////  FastRTPSEnum_CustomStringConvertible.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//


import Foundation

extension RTPSStatus: CustomStringConvertible {
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

extension RTPSReaderStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .discoveredReader : return "discoveredReader"
        case .changedQosReader : return "changedQosReader"
        case .removedReader    : return "removedReader"
        case .ignoredReader    : return "ignoredReader"
        }
    }
}

extension RTPSWriterStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .discoveredWriter : return "discoveredWriter"
        case .changedQosWriter : return "changedQosWriter"
        case .removedWriter    : return "removedWriter"
        case .ignoredWriter    : return "ignoredWriter"
        }
    }
}

extension RTPSParticipantStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .discoveredParticipant : return "discoveredParticipant"
        case .changedQosParticipant : return "changedQosParticipant"
        case .removedParticipant    : return "removedParticipant"
        case .droppedParticipant    : return "droppedParticipant"
        case .ignoredParticipant    : return "ignoredParticipant"
        }
    }
}

extension Durability: CustomStringConvertible {
    public var description: String {
        switch self {
        case .volatile       : return "volatile"
        case .transientLocal : return "transientLocal"
        case .transient      : return "transient"
        case .persistent     : return "persistent"
        }
    }
}

extension Reliability: CustomStringConvertible {
    public var description: String {
        switch self {
        case .bestEffort : return "bestEffort"
        case .reliable   : return "reliable"
        }
    }
}
