/////
////  DDSType.swift
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

import Foundation

/// Keyed DDS data type requirements
public protocol DDSKeyed {
    /// Data for topic key generation
    var key: Data { get }
}
