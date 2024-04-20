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

    public var unicastLocators: String {
        return String(info.pointee.getUnicastLocators())
    }

    public var multicastLocators: String {
        return String(info.pointee.getMutlicastLocators())
    }

    public var properties: [String:String] {
        var dict: [String:String] = [:]
        info.pointee.beginIteration()
        for _ in 0..<info.pointee.propertieslength() {
            let pair = info.pointee.pair()
            dict[String(pair.first)] = String(pair.second)
            info.pointee.nextIteration()
        }
        return dict
    }
}
