/////
////  RovDepth.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import FastRTPSSwift

struct RovTime: Codable {
    let sec: Int32
    let nanosec: UInt32
}

struct RovHeader: Codable {
    let stamp: RovTime
    let frameId: String
}

struct RovDepth: DDSKeyed, Codable {
    let pressure: FluidPressure
    let id: String      // @key
    let depth: Float    // Unit: meters
    
    var key: Data { id.data(using: .utf8)! }
}
