/////
////  FastRTPSEnum.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import Foundation

public enum RTPSReaderDiscoveryStatus: UInt32 {
    case discovered = 0
    case changedQos
    case removed
    case ignored
}

public enum RTPSWriterDiscoveryStatus: UInt32 {
    case discovered = 0
    case changedQos
    case removed
    case ignored
}

public enum RTPSParticipantDiscoveryStatus: UInt32 {
    case discovered = 0
    case changedQos
    case removed
    case dropped
    case ignored
}

public enum RTPSReaderStatus: UInt32 {
    case matchedMatching = 0
    case removedMatching
    case livelinessLost
}

public enum RTPSWriterStatus: UInt32 {
    case matchedMatching = 0
    case removedMatching
    case livelinessLost
}

public enum Durability: UInt8 {
        case volatile = 0
        case transientLocal
        case transient
        case persistent
}

public enum Reliability: UInt8 {
        case bestEffort = 1
        case reliable = 2
}


public enum FastRTPSLogLevel: UInt32 {
    case error = 0
    case warning
    case info
}

public struct ParticipantFilter: OptionSet {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let disabled = ParticipantFilter([])
    public static let differentHost = ParticipantFilter(rawValue: 0x1)
    public static let differentProcess = ParticipantFilter(rawValue: 0x2)
    public static let sameProcess = ParticipantFilter(rawValue: 0x4)
}

public struct RTPSReaderProfile {
    let keyed: Bool
    let reliability: Reliability
    let durability: Durability
    
    public init(keyed: Bool, reliability: Reliability, durability: Durability) {
        self.keyed = keyed
        self.reliability = reliability
        self.durability = durability
    }
}

public struct RTPSWriterProfile {
    let keyed: Bool
    let reliability: Reliability
    let durability: Durability
    let disablePositiveACKs: Bool
    
    public init(keyed: Bool, reliability: Reliability, durability: Durability, disablePositiveACKs: Bool) {
        self.keyed = keyed
        self.reliability = reliability
        self.durability = durability
        self.disablePositiveACKs = disablePositiveACKs
    }
}

public struct RTPSParticipantProfile {
    let leaseDurationAnnouncementperiod: Double
    let leaseDuration: Double
    let participantFilter: ParticipantFilter
    
    public init(leaseDurationAnnouncementperiod: Double, leaseDuration: Double, participantFilter: ParticipantFilter) {
        self.leaseDurationAnnouncementperiod = leaseDurationAnnouncementperiod
        self.leaseDuration = leaseDuration
        self.participantFilter = participantFilter
    }
}
