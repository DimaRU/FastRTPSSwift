/////
////  ParticipantDiscoveryInfo.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import FastRTPSWrapper
import CxxStdlib

public struct ParticipantDiscoveryInfo {
    var info: UnsafeMutablePointer<BridgedParticipantProxyData>

    init(info: UnsafeMutablePointer<BridgedParticipantProxyData>) {
        self.info = info
    }
    
    public var name: String {
        String(cString: info.pointee.participantName())
    }

    public var unicastLocators: String {
        String(info.pointee.getUnicastLocators())
    }

    public var multicastLocators: String {
        String(info.pointee.getMutlicastLocators())
    }

    public var properties: [String:String] {
        var dict: [String:String] = [:]
        info.pointee.beginIteration()
        for _ in 0..<info.pointee.propertiesCount() {
            let pair = info.pointee.pair()
            dict[String(pair.first)] = String(pair.second)
            info.pointee.nextIteration()
        }
        return dict
    }
}
