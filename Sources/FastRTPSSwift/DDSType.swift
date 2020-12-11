/////
////  DDSType.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

import Foundation

/// Basic desctiption for DDS data types
public protocol DDSType: Codable {
    /// Defines DDS type name, 'DDS::String' for example
    static var ddsTypeName: String { get }
}

/// Describe keyed DDS data type
public protocol DDSKeyed: DDSType {
    /// Data for topic key generation
    var key: Data { get }
}

/// Describe unkeyed DDS data type
public protocol DDSUnkeyed: DDSType {}
