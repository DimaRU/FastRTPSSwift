/////
////  ReaderDiscoveryInfo.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import FastRTPSWrapper
import CxxStdlib

public struct ReaderDiscoveryInfo {
    var info: UnsafeMutablePointer<BridgedReaderProxyData>

    init(info: UnsafeMutablePointer<BridgedReaderProxyData>) {
        self.info = info
    }

    public var topicName: String {
        String(cString: info.pointee.topicName())
    }
    
    public var typeName: String {
        String(cString: info.pointee.typeName())
    }

    public var durability: Durability {
        Durability(rawValue: info.pointee.durability())!
    }
    
    public var reliability: Reliability {
        Reliability(rawValue: info.pointee.reliability())!
    }
    
    public var keyed: Bool {
        info.pointee.keyed()
    }
    
    public var disablePositiveACKs: Bool {
        info.pointee.disable_positive_acks()
    }
    
    public var profile: RTPSWriterProfile {
        RTPSWriterProfile(
            keyed: keyed,
            reliability: reliability,
            durability: durability,
            disablePositiveACKs: disablePositiveACKs)
    }

    public var unicastLocators: String {
        return String(info.pointee.getUnicastLocators())
    }

    public var multicastLocators: String {
        return String(info.pointee.getMutlicastLocators())
    }
}
