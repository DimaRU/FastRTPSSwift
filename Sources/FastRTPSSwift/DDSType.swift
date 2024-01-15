/////
////  DDSType.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

import Foundation

/// DDS data types requirements
public protocol DDSType: Codable {
    /// Defines DDS type name, 'DDS::String' for example
    static var ddsTypeName: String { get }
}

/// Keyed DDS data type requirements
public protocol DDSKeyed: DDSType {
    /// Data for topic key generation
    var key: Data { get }
}

/// Unkeyed DDS data type requirements
public protocol DDSUnkeyed: DDSType {}
