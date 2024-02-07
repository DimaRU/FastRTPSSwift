/////
////  RovTopic.swift
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import FastRTPSSwift

enum ReaderTopic: DDSReaderTopic {
    
    case rovDepth
    case rovPressureInternal

    var topicConfig: (name: String, typeName: String, durability: Durability, reliability: Reliability) {
        switch self {
        case .rovDepth: return ("rov_depth", "orov::msg::sensor::Depth", .volatile, .bestEffort)
        case .rovPressureInternal: return ("rov_pressure_internal", "orov::msg::sensor::Barometer", .volatile, .bestEffort)
        }
    }
    var name: String { topicConfig.name }
    var typeName: String { topicConfig.typeName }
    var readerProfile: RTPSReaderProfile {
        let config = topicConfig
        return .init(keyed: false,
                     reliability: config.reliability,
                     durability: config.durability)
    }
}
