/////
////  FastRTPSEnum_CustomStringConvertible.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//


import Foundation

extension RTPSReaderStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .matchedMatching : return "readerMatchedMatching"
        case .removedMatching : return "readerRemovedMatching"
        case .livelinessLost  : return "readerLivelinessLost"
        }
    }
}

extension RTPSWriterStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .matchedMatching : return "writerMatchedMatching"
        case .removedMatching : return "writerRemovedMatching"
        case .livelinessLost  : return "writerLivelinessLost"
        }
    }
}

extension RTPSReaderDiscoveryStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .discovered : return "discoveredReader"
        case .changedQos : return "changedQosReader"
        case .removed    : return "removedReader"
        case .ignored    : return "ignoredReader"
        }
    }
}

extension RTPSWriterDiscoveryStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .discovered : return "discoveredWriter"
        case .changedQos : return "changedQosWriter"
        case .removed    : return "removedWriter"
        case .ignored    : return "ignoredWriter"
        }
    }
}

extension RTPSParticipantDiscoveryStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .discovered : return "discoveredParticipant"
        case .changedQos : return "changedQosParticipant"
        case .removed    : return "removedParticipant"
        case .dropped    : return "droppedParticipant"
        case .ignored    : return "ignoredParticipant"
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
