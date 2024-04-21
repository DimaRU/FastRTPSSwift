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

    /// Return discovered topic name
    public var topicName: String {
        String(cString: info.pointee.topicName())
    }
    
    /// Return discovered topic type
    public var typeName: String {
        String(cString: info.pointee.typeName())
    }
    
    /// Return discovered topic durability
    public var durability: Durability {
        Durability(rawValue: info.pointee.durability())!
    }
    
    /// Return discovered topic
    public var reliability: Reliability {
        Reliability(rawValue: info.pointee.reliability())!
    }
    
    /// Return true if discovered topic is keyed
    public var keyed: Bool {
        info.pointee.keyed()
    }
    
    /// Return true if disabled positive ask on discovered topic
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

    /// Return remote unicast locators list
    public var unicastLocators: String {
        return String(info.pointee.getUnicastLocators())
    }

    /// Return remote multicast locators list
    public var multicastLocators: String {
        return String(info.pointee.getMutlicastLocators())
    }
}
