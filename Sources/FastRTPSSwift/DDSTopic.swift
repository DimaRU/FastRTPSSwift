/////
////  DDSTopic.swift
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//

import Foundation

/// Common DDS reader/writer topic requirements. Must define topic name Raw value as string
public protocol DDSTopic {
    var name: String { get }
    var typeName: String { get }
}

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
