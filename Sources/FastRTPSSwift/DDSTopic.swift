/////
////  DDSTopic.swift
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//


import Foundation

public protocol DDSTopic: RawRepresentable where RawValue == String {}

public protocol DDSReaderTopic: DDSTopic {
    var readerProfile: RTPSReaderProfile { get }
}

public protocol DDSWriterTopic: DDSTopic {
    var writerProfile: RTPSWriterProfile { get }
}

public extension RTPSReaderProfile {
    init(reliability: Reliability, durability: Durability) {
        self.init(keyed: false, reliability: reliability, durability: durability)
    }
}

public extension RTPSWriterProfile {
    init(reliability: Reliability, durability: Durability, disablePositiveACKs: Bool) {
        self.init(keyed: false, reliability: reliability, durability: durability, disablePositiveACKs: disablePositiveACKs)
    }
}
