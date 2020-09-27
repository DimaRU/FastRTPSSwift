/////
////  DDSType.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

import Foundation

/// Basic desctiption for DDS data types
public protocol DDSType: Codable {
    static var ddsTypeName: String { get }
}

/// Describe keyed DDS data type
public protocol DDSKeyed: DDSType {
    var key: Data { get }
}

/// Describe unkeyed DDS data type
public protocol DDSUnkeyed: DDSType {}
