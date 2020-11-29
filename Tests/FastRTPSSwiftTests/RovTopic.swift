/////
////  RovTopic.swift
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import FastRTPSSwift

enum ReaderTopic: String, DDSReaderTopic {
    
    case rovDepth                    = "rov_depth"                         // orov::msg::sensor::Depth
    case rovPressureInternal         = "rov_pressure_internal"             // orov::msg::sensor::Barometer

    var readerProfile: ReaderProfile {
        ReaderProfile(keyed: true, reliability: .bestEffort, durability: .volatile, ipv4Locator: nil)
    }
}
