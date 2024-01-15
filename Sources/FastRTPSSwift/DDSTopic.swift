/////
////  DDSTopic.swift
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//


import Foundation

/// Common DDS reader/writer topic requirements. Must define topic name Raw value as string
public protocol DDSTopic: RawRepresentable where RawValue == String {}

/// Reader topic requirements
public protocol DDSReaderTopic: DDSTopic {
    /// Return profile which defines Reader parameters: durability and reliability QoS
    var readerProfile: RTPSReaderProfile { get }
}

/// Writer topic requirements
public protocol DDSWriterTopic: DDSTopic {
    /// Return profile which defines Writer parameters: durability, reliability and disablePositiveACKs QoS
    var writerProfile: RTPSWriterProfile { get }
}

public extension RTPSReaderProfile {
    /// Initializer for RTPSReaderProfile
    /// - Parameters:
    ///   - reliability: Reliability QoS
    ///   - durability: Durability QoS
    init(reliability: Reliability, durability: Durability) {
        self.init(keyed: false, reliability: reliability, durability: durability)
    }
}

public extension RTPSWriterProfile {
    /// Initializer for RTPRTPSWriterProfileSReaderProfile
    /// - Parameters:
    ///   - reliability: Reliability QoS
    ///   - durability: Durability QoS
    ///   - disablePositiveACKs: disablePositiveACKs QoS
    init(reliability: Reliability, durability: Durability, disablePositiveACKs: Bool) {
        self.init(keyed: false, reliability: reliability, durability: durability, disablePositiveACKs: disablePositiveACKs)
    }
}
