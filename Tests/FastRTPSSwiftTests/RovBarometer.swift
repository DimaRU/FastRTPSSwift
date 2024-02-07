/////
////  RovBarometer.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import FastRTPSSwift

struct FluidPressure: Codable {
    let header: RovHeader

    let fluidPressure: Double
    let variance: Double
}

struct RovBarometer: DDSKeyed, Codable {
    let pressure: FluidPressure
    let id: String

    var key: Data { id.data(using: .utf8)! }
}
